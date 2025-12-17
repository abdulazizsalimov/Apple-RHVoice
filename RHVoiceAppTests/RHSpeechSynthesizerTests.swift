//
//  RHSpeechSynthesizerTests.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 04.05.2023.
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

import RHVoice
@testable import RHVoiceApp

final class RHSpeechSynthesizerTests: XCTestCase {

    var synthesizerUnderTest: RHSpeechSynthesizer?
    var utteranceClient: RHSpeechUtteranceClient?

    var synthesizerFinishedSuccess: ((RHSpeechUtterance) -> Void)?
    var synthesizerFinishedFail: ((RHSpeechUtterance, Error?) -> Void)?
    var clientReceivedMarker: (([RHSpeechSynthesisMarker]) -> Void)?

    override func setUpWithError() throws {
       try super.setUpWithError()
        removeAllInstlledVoicesAndLangauges()
        synthesizerUnderTest = RHSpeechSynthesizer()
        synthesizerUnderTest?.delegate = self
    }

    override func tearDownWithError() throws {
        synthesizerUnderTest = nil
        utteranceClient = nil
        removeAllInstlledVoicesAndLangauges()
        synthesizerFinishedSuccess = nil
        synthesizerFinishedFail = nil
        clientReceivedMarker = nil
        try super.tearDownWithError()
    }

    func testSynthesizeToFile() throws {
        let (voice, _) = try instalAnyVoice()
        let installedVoice = voice.installedVoice
        guard let installedVoice else {
            XCTFail("InstalledVoice:\(String(describing: installedVoice)) can't be nil")
            return
        }

        for test in RHSpeechSynthesizerTestData.data {
            try verifySynthesizeToFile(text: test.text, voice: installedVoice)
        }
    }

    func verifySynthesizeToFile(text: String, voice: RHSpeechSynthesisVoice?) throws {

        let outputFilePath = FileManager.default.tempFile(with: "wav")

        let utterance = RHSpeechUtterance(text: text)
        utterance.set(voice: voice)

        let finished = expectation(description: "Synthesizer Finished")
        synthesizerFinishedSuccess = { _ in
            finished.fulfill()
        }

        synthesizerUnderTest?.synthesizeUtterance(utterance, toFileAtPath: outputFilePath)

        wait(for: [finished], timeout: 3)

        let audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: outputFilePath))

        XCTAssertEqual(audioFile.fileFormat.channelCount, 1)
        XCTAssertEqual(audioFile.fileFormat.sampleRate, 24000.0)
        XCTAssertEqual(audioFile.fileFormat.commonFormat, .pcmFormatInt16)
        XCTAssertEqual(audioFile.fileFormat.isInterleaved, true)
        XCTAssertEqual(audioFile.fileFormat.settings[AVFormatIDKey] as? AudioFormatID, kAudioFormatLinearPCM)

        try FileManager.default.removeItem(atPath: outputFilePath)
    }

    func testSynthesizeToClient() throws {

        let (voice, _) = try instalAnyVoice()
        let installedVoice = voice.installedVoice
        guard let installedVoice else {
            XCTFail("InstalledVoice:\(String(describing: installedVoice)) can't be nil")
            return
        }

        for test in RHSpeechSynthesizerTestData.data {
            try verifySynthesizeToClient(text: test.text, voice: installedVoice, expectedMarkers: test.markers)
        }
    }

    func verifySynthesizeToClient(text: String, voice: RHSpeechSynthesisVoice?, expectedMarkers: [RHSpeechMarker]) throws {
        let utterance = RHSpeechUtterance(text: text)
        utterance.set(voice: voice)

        let finished = expectation(description: "Synthesizer Finished")
        synthesizerFinishedSuccess = { _ in
            finished.fulfill()
        }

        var internalIndex = 0

        let receivedMarkerExp = expectation(description: "Client Received Markers")
        receivedMarkerExp.assertForOverFulfill = false

        clientReceivedMarker = { markers in
            receivedMarkerExp.fulfill()

            let markersIn = markers as NSArray

            for index in 0..<markersIn.count {
                guard let rhMarker = markersIn[index] as? RHSpeechSynthesisMarker else {
                    XCTFail("Marker at index:\(index) is not RHSpeechSynthesisMarker")
                    continue
                }

                if internalIndex >= expectedMarkers.count {
                    XCTFail("Not enough expected markers provided. Missing marker info:\nmark:\(rhMarker.mark)\nbyteSampleOffset:\(rhMarker.byteSampleOffset)\ntextRange:\(rhMarker.textRange)")
                    continue
                }
                
                let avMarker = AVSpeechSynthesisMarker(markerType: expectedMarkers[internalIndex].mark.avMark,
                                                       forTextRange: expectedMarkers[internalIndex].textRange,
                                                       atByteSampleOffset: Int(expectedMarkers[internalIndex].byteSampleOffset * 2))
                XCTAssertEqual(avMarker.textRange, rhMarker.avMarker.textRange)
                XCTAssertEqual(avMarker.mark, rhMarker.avMarker.mark)
                internalIndex += 1
            }
        }

        utteranceClient = RHSpeechUtteranceClient(audioBufferSize: 20)
        utteranceClient?.markerDelegate = self
        synthesizerUnderTest?.synthesizeUtterance(utterance, client: utteranceClient!)

        wait(for: [finished, receivedMarkerExp], timeout: 3)
    }
}

extension RHSpeechSynthesizerTests: RHSpeechSynthesizerDelegate {
    func speechSynthesizer(_ speechSynthesizer: RHSpeechSynthesizer, didFinish utterance: RHSpeechUtterance) {
        synthesizerFinishedSuccess?(utterance)
    }

    func speechSynthesizer(_ speechSynthesizer: RHSpeechSynthesizer, didFailToSynthesize utterance: RHSpeechUtterance, withError error: Error?) {
        synthesizerFinishedFail?(utterance, error)
    }
}

extension RHSpeechSynthesizerTests: RHSpeechUtteranceClientMarkerDelegate {
    func utteranceClientDidReceive(_ markers: [RHSpeechSynthesisMarker]) {
        clientReceivedMarker?(markers)
    }
    func utteranceClientDidReceiveSamples(_ samples: UnsafePointer<Int16>, withSize count: Int) {
    }
}
