//
//  RHVoiceExtensionAudioUnitTests.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 11/18/24.
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
import XCTest

import AVFoundation

@testable import RHVoiceApp

final class RHVoiceExtensionAudioUnitTests: XCTestCase {
    
    var audioUnit: RHVoiceExtensionAudioUnit?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        removeAllInstlledVoicesAndLangauges()
        audioUnit = try RHVoiceExtensionAudioUnit(componentDescription: AudioComponentDescription())
        try audioUnit?.allocateRenderResources()
    }

    override func tearDown() {
        removeAllInstlledVoicesAndLangauges()
        audioUnit?.deallocateRenderResources()
        audioUnit = nil
        super.tearDown()
    }
    
    func testSpeechVoices() throws {
        let (voice, _) = try instalAnyVoice()
        XCTAssertEqual(audioUnit?.speechVoices.count, 1)
        let speechVoice = audioUnit?.speechVoices.first
        XCTAssertEqual(speechVoice?.identifier, voice.name)
    }
    
    func testRendering() throws {
        let (voice, _) = try instalAnyVoice()
        
        guard let avVoice = voice.installedVoice?.avVoice else {
            XCTFail("No Voice installed")
            return
        }
        
        guard let audioUnit else {
            XCTFail("No Audio unit installed")
            return
        }
        
        let request = AVSpeechSynthesisProviderRequest(ssmlRepresentation: "<speak>This output speech uses SSML</speak>",
                                                       voice: avVoice)
        
        audioUnit.synthesizeSpeechRequest(request)
        
        let renderBlock = audioUnit.internalRenderBlock
               
        var actionFlags = AudioUnitRenderActionFlags()
        var timestamp = AudioTimeStamp()
        let frameCount: AUAudioFrameCount = 512
        let outputBusNumber: Int = 0
               
        var audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: frameCount * 4, mData: malloc(Int(frameCount) * 4))
        var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
        defer { free(audioBuffer.mData) }
               
        let result = renderBlock(&actionFlags, &timestamp, frameCount, outputBusNumber, &bufferList, nil, nil)
        XCTAssertEqual(result, noErr, "Render block failed with error code: \(result)")
        
        audioUnit.cancelSpeechRequest()
    }
}
