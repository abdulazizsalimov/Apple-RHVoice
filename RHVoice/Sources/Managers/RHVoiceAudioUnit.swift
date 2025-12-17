//
//  RHVoiceAudioUnit.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 06.06.2025.
//
//  Copyright (C) 2025  Non-Routine LLC (contact@nonroutine.com)

import AVFAudio
import Combine

class RHVoiceAudioUnit {
    
    enum Status {
        case connected
        case disconnected
        case failedToConnect
    }
    
    @Published private(set) var status: RHVoiceAudioUnit.Status = .disconnected
    private var audioUnit: AVAudioUnit?
    private var messageChannel: AUMessageChannel?
    private let engine = AVAudioEngine()
    
    private let taskSerializer: SerialTasks
    
    func loadAudioUnit(with description: AudioComponentDescription) async throws -> AVAudioUnit {
        try await withCheckedThrowingContinuation { continuation in
            AVAudioUnit.instantiate(with: description, options: [.loadOutOfProcess]) { audioUnit, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let audioUnit = audioUnit {
                    continuation.resume(returning: audioUnit)
                } else {
                    continuation.resume(throwing: NSError(domain: NSOSStatusErrorDomain, code: Int(kAudioUnitErr_ExtensionNotFound), userInfo: [:]))
                }
            }
        }
    }
    
    private func connect() async {
        Log.debug("Connecting audio unit...")
        let componentDescription = AudioComponentDescription(componentType: kAudioUnitType_SpeechSynthesizer,
                                                             componentSubType: GeneratedConstants.audioComponentSubtype.audioComponentOSType,
                                                             componentManufacturer: GeneratedConstants.audioComponentManufacturer.audioComponentOSType,
                                                             componentFlags: AudioComponentFlags([.sandboxSafe, .isV3AudioUnit]).rawValue,
                                                             componentFlagsMask: AudioComponentFlags([.sandboxSafe, .isV3AudioUnit]).rawValue
                                                             )
        do {
            guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: true) else {
                self.status = .failedToConnect
                return
            }
            let audioUnit = try await loadAudioUnit(with: componentDescription)
            self.messageChannel = audioUnit.auAudioUnit.messageChannel(for: "\(Self.Type.self)")
            
            if engine.isRunning {
                engine.stop()
            }
            self.engine.attach(audioUnit)
            self.engine.connect(audioUnit, to: engine.outputNode, format: format)
            self.engine.prepare()
            self.engine.isAutoShutdownEnabled = true
            self.audioUnit = audioUnit
            self.status = .connected
            Log.debug("Connected audio unit successfully.")
        } catch {
            Log.error("Failed to connect audio unit: \(error)")
            self.status = .failedToConnect
        }
    }
    
    private func disconnect() async {
        if !isConnectedAndAudioUnitLoaded {
            return
        }
        
        Log.debug("Disconnecting audio unit...")
        
        self.messageChannel = nil
        self.audioUnit?.reset()
        self.audioUnit = nil
        self.status = .disconnected
        Log.debug("Disconnected audio unit successfully.")
    }
    
    func reconnect() async {
        await disconnect()
        await connect()
    }
    
    func play(text: String, voice: String) async {
        
        guard let audioUnit else {
            Log.error("Audio unit is nil. Can't play text.")
            return
        }
        
        let auAudioUnit = audioUnit.auAudioUnit
        if !auAudioUnit.renderResourcesAllocated {
            try? auAudioUnit.allocateRenderResources()
        }
        
        try? self.engine.start()
        let request = AVSpeechSynthesisProviderRequest(
          ssmlRepresentation: "<speak>\(text)</speak>",
          voice: .init(name: voice.lowercased(), identifier: "", primaryLanguages: [], supportedLanguages: [])
        )
        
        if auAudioUnit.responds(to: #selector(AVSpeechSynthesisProviderAudioUnit.synthesizeSpeechRequest(_:))) {
            auAudioUnit.perform(#selector(AVSpeechSynthesisProviderAudioUnit.synthesizeSpeechRequest(_:)), with: request)
        } else {
            Log.error("Audio unit does not support synthesizeSpeechRequest. Did we connect to the correct audio unit?")
            return
        }
        
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                return
            }
            while self.isSynthesizing {
                RunLoop.current.run(until: Date().addingTimeInterval(1.0))
            }
            RunLoop.current.run(until: Date().addingTimeInterval(1.0))
            continuation.resume()
        }
    }
    
    private var isConnectedAndAudioUnitLoaded: Bool {
        status == .connected && audioUnit != nil
    }
    
    private func send<T: Codable>(message: Message) -> T? {
        if !isConnectedAndAudioUnitLoaded {
            Log.error("Not Connected. Can't send messages.")
            return nil
        }
        guard let messageChannel else {
            Log.error("Message channel is nil. Can't send messages")
            return nil
        }
        
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(message) else {
            Log.error("Failed to encode message to Data.")
            return nil
        }
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            Log.error( "Failed to convert Data to String. Can't send nil string")
            return nil
        }
        
        guard let responseObject = messageChannel.callAudioUnit?([Message.key: jsonString]) else {
            return nil
        }
        guard let responseJson = responseObject[MessageResponse.key] as? String else {
            Log.error("No response json found")
            return nil
        }
        
        guard let jsonData = responseJson.data(using: .utf8) else {
            Log.error( "Failed to convert String to Data. Can't send nil string")
            return nil
        }
        
        let jsonDecoder = JSONDecoder()
        guard let responseMessage = try? jsonDecoder.decode(MessageResponse.self, from: jsonData) else {
            Log.error("Failed to decode response json to MessageResponse.")
            return nil
        }
        
        guard let jsonResponseData = responseMessage.json?.data(using: .utf8) else {
            Log.debug("No response object found")
            return nil
        }
        
        guard let response = try? jsonDecoder.decode(T.self, from: jsonResponseData) else {
            Log.error("Failed to decode response json to \(T.self).")
            return nil
        }
        
        return response
    }
    
    func attpemtToConnect() {
        if isConnectedAndAudioUnitLoaded {
            return
        }
        
        taskSerializer.run {
            await self.connect()
        }
    }
    
    var installedVoices: [RHSpeechSynthesisProviderVoice]? {
        get {
            let message = Message(type: .getVoices, object: GetVoicesMessage())
            return send(message: message)
        }
        set {
            let message = Message(type: .setVoices, object: SetVoicesMessage(voices: newValue))
            let _: String? = send(message: message)
        }
    }
    
    var isSynthesizing: Bool {
        let message = Message(type: .isSynthesizing, object: IsSynthesizingMessage())
        let boolString: String? = send(message: message)
        guard let boolString else {
            return false
        }
        return Bool(boolString) ?? false
    }
    
    init(taskSerializer: SerialTasks) {
        self.taskSerializer = taskSerializer
        attpemtToConnect()
    }
}
