//
//  RHVoiceExtensionAudioUnit.swift
//  RHVoiceExtension
//
//  Created by Ihor Shevchuk on 12.09.2022.
//
//  Copyright (C) 2022–2024 Ihor Shevchuk
//  Copyright (C) 2025 Non-Routine LLC
//  Contact: contact@nonroutine.com
//
//  SPDX-License-Identifier: GPL-3.0-or-later
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Accelerate
import AVFoundation
import CoreAudio
import RHVoice

public final class RHVoiceExtensionAudioUnit: AVSpeechSynthesisProviderAudioUnit {
    
    private var outputBus: AUAudioUnitBus
    private var _outputBusses: AUAudioUnitBusArray!
    
    private var request: AVSpeechSynthesisProviderRequest?

    private var format: AVAudioFormat
    private let sampleRate = 24000.0
    private let outputRecurseCallNumberMax: UInt32 = 200
    private let baseDelayMicroseconds: UInt32 = 500
    
    @objc override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions) throws {
        
        self.format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: true)!
        
        outputBus = try AUAudioUnitBus(format: self.format)
        try super.init(componentDescription: componentDescription, options: options)
        _outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])
    }

    public override var outputBusses: AUAudioUnitBusArray {
        return _outputBusses
    }
    
    public override func allocateRenderResources() throws {
        try super.allocateRenderResources()
        initRHVoice()
    }
    
    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
        cleanUp()
        synthesizer = nil
    }
    
    private var outputDataQueue = DispatchQueue(label: "RHVoiceExtensionAudioUnit.outputDataQueue", qos: .userInteractive)
    private var outputData: [Float] = []
    private var outputOffset = 0
    private var outputRecurseCallNumber = 0
    private var currentSubscriptionsHash: Int = 0
    private var currentVoicesSettingsHash: Int = 0
    private var supportedVoices: [RHSpeechSynthesisProviderVoice] {
        if let settingsVoices = SettingsStore.shared.supportedVoicesExtension {
            Log.debug(type: .synthesizer, "Supported Voices. Using Extesnsion Settings JSON:\(settingsVoices.count)")
            return settingsVoices
        }

        if let settingsVoices = SettingsStore.shared.supportedVoices {
            Log.debug(type: .synthesizer, "Supported Voices. Using Settings JSON:\(settingsVoices.count)")
            SettingsStore.shared.supportedVoicesExtension = settingsVoices
            return settingsVoices
        }
        let rhAVVoices = rhSpeechVoices.rhAVVoices
        SettingsStore.shared.supportedVoicesExtension = rhAVVoices
        Log.debug(type: .synthesizer, "Supported Voices. Using RHVoice data files:\(rhAVVoices.count)")
        return rhAVVoices
    }

	// MARK: - Rendering
	/*
	 NOTE:- It is only safe to use Swift for audio rendering in this case, as Audio Unit Speech Extensions process offline.
	 (Swift is not usually recommended for processing on the realtime audio thread)
	 */
    public override var internalRenderBlock: AUInternalRenderBlock { self.performRender }

    // swiftlint:disable:next function_parameter_count
    private func performRender(
      actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
      timestamp: UnsafePointer<AudioTimeStamp>,
      frameCount: AUAudioFrameCount,
      outputBusNumber: Int,
      outputAudioBufferList: UnsafeMutablePointer<AudioBufferList>,
      renderEvents: UnsafePointer<AURenderEvent>?,
      renderPull: AURenderPullInputBlock?
    ) -> AUAudioUnitStatus {
        return doPerformRender(actionFlags: actionFlags, timestamp: timestamp, frameCount: frameCount, outputBusNumber: outputBusNumber, outputAudioBufferList: outputAudioBufferList, renderEvents: renderEvents, renderPull: renderPull)
    }
    
    // swiftlint:disable:next function_parameter_count
    private func doPerformRender(
      actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
      timestamp: UnsafePointer<AudioTimeStamp>,
      frameCount: AUAudioFrameCount,
      outputBusNumber: Int,
      outputAudioBufferList: UnsafeMutablePointer<AudioBufferList>,
      renderEvents: UnsafePointer<AURenderEvent>?,
      renderPull: AURenderPullInputBlock?
    ) -> AUAudioUnitStatus {
        guard let utteranceClient else {
            actionFlags.pointee = .unitRenderAction_PostRenderError
            Log.debug(type: .synthesizer, "Utterance Client is nil while request for rendering came.")
            return kAudioComponentErr_InstanceInvalidated
        }
        
        let intFrameCount = Int(frameCount)
        var outputDataCount = 0
        outputDataQueue.sync { [weak self] in
            outputDataCount = self?.outputData.count ?? 0
        }
        let coutOfDataAvailable = min(outputDataCount - outputOffset, intFrameCount)
        
        if coutOfDataAvailable < intFrameCount {
            let completedRendering = utteranceClient.completed()
            if completedRendering && coutOfDataAvailable <= 0 {
                Log.debug(type: .synthesizer, "Completed rendering")
                actionFlags.pointee = .offlineUnitRenderAction_Complete
                self.cleanUp()
                return noErr
            }
            
            outputRecurseCallNumber += 1
            if outputRecurseCallNumber < outputRecurseCallNumberMax && !completedRendering {
                Log.error(type: .synthesizer, "Rendering in progress no data. Trying one more time: \(outputRecurseCallNumber)")
                pauseUntil(maxDelayFactor: outputRecurseCallNumberMax) {
                    utteranceClient.completed()
                }
                return doPerformRender(actionFlags: actionFlags, timestamp: timestamp, frameCount: frameCount, outputBusNumber: outputBusNumber, outputAudioBufferList: outputAudioBufferList, renderEvents: renderEvents, renderPull: renderPull)
            }
            Log.error(type: .synthesizer, "Tryied \(outputRecurseCallNumber), without luck. Returning what have currently")
        }
        
        outputRecurseCallNumber = 0
        
        outputAudioBufferList.pointee.mNumberBuffers = 1
        var unsafeBuffer = UnsafeMutableAudioBufferListPointer(outputAudioBufferList)[0]
        let frames = unsafeBuffer.mData!.assumingMemoryBound(to: Float32.self)
        frames.update(repeating: 0, count: intFrameCount)
        unsafeBuffer.mNumberChannels = 1
        
        unsafeBuffer.mDataByteSize = UInt32(coutOfDataAvailable * MemoryLayout<Float32>.size)
        
        var outputFrames: [Float] = []
        outputDataQueue.sync { [weak self] in
            guard let self else {
                return
            }
            if self.outputOffset >= 0
            && self.outputOffset < self.outputData.count
            && (coutOfDataAvailable + self.outputOffset) <= self.outputData.count {
                outputFrames = Array(self.outputData[self.outputOffset..<(coutOfDataAvailable + self.outputOffset)])
            }
        }
        
        for (index, frame) in outputFrames.enumerated() {
            frames[index] = frame
        }
        self.outputOffset += coutOfDataAvailable
        actionFlags.pointee = .offlineUnitRenderAction_Render
        
        Log.debug(type: .synthesizer, "Rendered: \(coutOfDataAvailable) outputOffset: \(outputOffset).")
        
        return noErr
    }
    
    private func pauseUntil(maxDelayFactor: UInt32, or condition: @escaping () -> Bool) {
        let maxDelaySeconds = Double(baseDelayMicroseconds * maxDelayFactor) / 1_000_000
        let checkIntervalSeconds = maxDelaySeconds / 5.0

        let startTime = Date()
        
        while !condition() && Date().timeIntervalSince(startTime) < maxDelaySeconds {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(checkIntervalSeconds))
        }
    }

    public override func synthesizeSpeechRequest(_ speechRequest: AVSpeechSynthesisProviderRequest) {
        self.cancelSpeechRequest()
        self.request = speechRequest

        let ssml = speechRequest.rhVoiceSSML

        Log.debug(type: .synthesizer, "[In] New rendering request: \(ssml)")
        defer {
            Log.debug(type: .synthesizer, "[Out] New rendering request: \(ssml)")
        }
        
        updateSettingsIfNeeded()

        let utterance = RHSpeechUtterance(ssml: ssml)
        if let voice = rhVoiceFromSystem(voice: speechRequest.voice) {
            utterance.set(voice: voice)
        }

        let client = RHSpeechUtteranceClient(audioBufferSize: 50)
        client.markerDelegate = self
        self.utteranceClient = client
        synthesizer?.synthesizeUtterance(utterance, client: client)
    }
    
    public override func cancelSpeechRequest() {
        synthesizer?.stopAndCancel()
        cleanUp()
        Log.debug(type: .synthesizer, "Cancel speech request.")
    }
    
    public override var speechVoices: [AVSpeechSynthesisProviderVoice] {
        get {
            Log.debug(type: .synthesizer, "Number of voices. In")
            let result = supportedVoices.avVoices
            Log.debug(type: .synthesizer, "Number of voices. Out:\(result.count)")
            return result
        }
        set {
            Log.error(type: .synthesizer, "Unexpected setting of voices:\(newValue.count)")
        }
    }

    public override var canProcessInPlace: Bool {
        return true
    }
    
    func cleanUp() {
        utteranceClient?.cancel()
        request = nil
        metaDataMarkers = []
        outputDataQueue.sync { [weak self] in
            guard let self else { return }
            self.outputData = []
        }
        outputOffset = 0
        utteranceClient = nil
    }

    // MARK: - RHVoice

    func initRHVoice() {
        Log.debug(type: .synthesizer, "initRHVoice")
        let initParams = RHVoiceBridgeParams.iOSDefault
        initParams.logger = self
        let rhVoiceBridge = RHVoiceBridge.sharedInstance()
        rhVoiceBridge.params = initParams
        synthesizer = RHSpeechSynthesizer()
        updateSettingsIfNeeded()
    }
    
    private func updateSettingsIfNeeded() {
        let voicesSettingsHash = SettingsStore.shared.voicesSettings.hashValue
        if currentVoicesSettingsHash != voicesSettingsHash {
            currentVoicesSettingsHash = voicesSettingsHash
        }
    }
    
    var synthesizer: RHSpeechSynthesizer?
    var utteranceClient: RHSpeechUtteranceClient?
    var metaDataMarkers: [AVSpeechSynthesisMarker] = []
    
    var rhSpeechVoices: [RHSpeechSynthesisVoice] {
        synthesizer = nil
        initRHVoice()
        RHVoiceBridge.sharedInstance().recreateEngine()
        let result = RHSpeechSynthesisVoice.speechVoices()
        return result
    }

    func doGetRHVoiceFromSystem(voice: AVSpeechSynthesisProviderVoice) -> RHSpeechSynthesisVoice? {
        return RHSpeechSynthesisVoice.speechVoices().first(where: { rhVoice in
            return rhVoice.name == voice.name
        })
    }
    
    func rhVoiceFromSystem(voice: AVSpeechSynthesisProviderVoice) -> RHSpeechSynthesisVoice? {
        
        if let voice = doGetRHVoiceFromSystem(voice: voice) {
            return voice
        }
        
        RHVoiceBridge.sharedInstance().recreateEngine()
        return doGetRHVoiceFromSystem(voice: voice)
    }
}

extension RHVoiceExtensionAudioUnit: RHSpeechUtteranceClientMarkerDelegate {
    public func utteranceClientDidReceiveSamples(_ samples: UnsafePointer<Int16>, withSize count: Int) {
        let buf = UnsafeBufferPointer(start: samples, count: count)
        let array = Array(buf)
        outputDataQueue.async { [weak self] in
            guard let self else {
                return
            }
            let resampled = vDSP.multiply(Float(1.0/32767.0), vDSP.integerToFloatingPoint(array, floatingPointType: Float.self))
            self.outputData.append(contentsOf: resampled)
        }
    }
    
    public func utteranceClientDidReceive(_ markers: [RHSpeechSynthesisMarker]) {
        guard let speechSynthesisOutputMetadataBlock = self.speechSynthesisOutputMetadataBlock else {
            return
        }
        
        guard let request = self.request else {
            return
        }
        
        speechSynthesisOutputMetadataBlock(markers.map({ marker in return marker.avMarker }), request)
    }
    
    public func utteranceClientDidStart(_ marker: RHSpeechSynthesisMarker) {

    }
    
    public override func messageChannel(for channelName: String) -> AUMessageChannel {
        Log.debug("Creating message channel for \(channelName)")
        return RHVoiceMessageChannel(delegate: self)
    }
}

extension RHVoiceExtensionAudioUnit: RHVoiceMessageChannelDelegate {
    func getVoices() -> [RHSpeechSynthesisProviderVoice]? {
        return supportedVoices
    }
    func set(voices: [RHSpeechSynthesisProviderVoice]?) {
        Log.debug("Setting voices:\(voices?.count ?? 0)")
        SettingsStore.shared.supportedVoicesExtension = voices
    }
    func isSynthesizingMessage() -> String {
        let result = utteranceClient != nil || self.request != nil
        return String(result)
    }
}

extension RHVoiceExtensionAudioUnit: RHVoiceLoggerProtocol {
    public func log(at level: RHVoiceLogLevel, message: String!) {
        switch level {
        case RHVoiceLogLevelInfo:
            Log.info(type: .synthesizer, message)
        case RHVoiceLogLevelDebug, RHVoiceLogLevelTrace:
            Log.debug(type: .synthesizer, message)
        case RHVoiceLogLevelError:
            Log.error(type: .synthesizer, message)
        case RHVoiceLogLevelWarning:
            Log.warning(type: .synthesizer, message)
        default:
            Log.debug(type: .synthesizer, message)
        }
    }
}
