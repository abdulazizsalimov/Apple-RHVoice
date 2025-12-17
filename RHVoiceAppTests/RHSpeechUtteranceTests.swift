//
//  RHSpeechUtteranceTests.swift
//  RHVoiceUITests
//
//  Created by Ihor Shevchuk on 01.05.2023.
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
import Foundation

import RHVoice
@testable import RHVoiceApp

final class RHSpeechUtteranceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        removeAllInstlledVoicesAndLangauges()
    }

    override func tearDown() {
        removeAllInstlledVoicesAndLangauges()
        super.tearDown()
    }

    func testSetVoice() throws {

        let (voice, language) = try instalAnyVoice()

        SettingsStore.shared.setLanguageSettings(for: language.code, languageSettings: LanguageSettings())
        SettingsStore.shared.quality = RHSpeechUtteranceQualityStandart

        let installedVoice = voice.installedVoice
        guard let installedVoice else {
            XCTFail("InstalledVoice:\(String(describing: installedVoice)) can't be nil")
            return
        }

        let systemUnderTest = RHSpeechUtterance(text: "Test")

        XCTAssertEqual(systemUnderTest.volume, 1.0)
        XCTAssertEqual(systemUnderTest.rate, 1.0)
        XCTAssertEqual(systemUnderTest.quality, RHSpeechUtteranceQualityStandart)
        XCTAssertEqual(systemUnderTest.bilingual, false)

        systemUnderTest.set(voice: installedVoice)

        XCTAssertEqual(systemUnderTest.volume, 1.0)
        XCTAssertEqual(systemUnderTest.rate, 1.0)
        XCTAssertEqual(systemUnderTest.quality, RHSpeechUtteranceQualityStandart)
        XCTAssertEqual(systemUnderTest.bilingual, false)

        let settings = LanguageSettings()
        settings.bilingual = true
        settings.rate = 2.0
        settings.volume = 1.5
        SettingsStore.shared.setLanguageSettings(for: language.code, languageSettings: settings)
        SettingsStore.shared.quality = RHSpeechUtteranceQualityMax

        systemUnderTest.set(voice: nil)

        XCTAssertEqual(systemUnderTest.volume, 1.0)
        XCTAssertEqual(systemUnderTest.rate, 1.0)
        XCTAssertEqual(systemUnderTest.quality, RHSpeechUtteranceQualityStandart)
        XCTAssertEqual(systemUnderTest.bilingual, false)

        systemUnderTest.set(voice: installedVoice)

        XCTAssertEqual(systemUnderTest.volume, 1.5)
        XCTAssertEqual(systemUnderTest.rate, 2.0)
        XCTAssertEqual(systemUnderTest.quality, RHSpeechUtteranceQualityMax)
        XCTAssertEqual(systemUnderTest.bilingual, true)

        SettingsStore.shared.setLanguageSettings(for: language.code, languageSettings: LanguageSettings())
        SettingsStore.shared.quality = RHSpeechUtteranceQualityStandart
    }

    func testIsEmpty() {
        XCTAssertTrue(RHSpeechUtterance(text: "").isEmpty)
        XCTAssertTrue(RHSpeechUtterance(text: nil).isEmpty)
        XCTAssertTrue(RHSpeechUtterance(ssml: "").isEmpty)
        XCTAssertTrue(RHSpeechUtterance(ssml: nil).isEmpty)

        XCTAssertFalse(RHSpeechUtterance(text: "Test").isEmpty)
        XCTAssertFalse(RHSpeechUtterance(ssml: "Test").isEmpty)
        XCTAssertFalse(RHSpeechUtterance(ssml: "<speak>Test</speak>").isEmpty)
    }

    func testSSM() {
        XCTAssertEqual(RHSpeechUtterance(text: "").ssml, "<speak></speak>")
        XCTAssertEqual(RHSpeechUtterance(text: nil).ssml, "<speak></speak>")
        XCTAssertEqual(RHSpeechUtterance(ssml: "").ssml, "")
        XCTAssertEqual(RHSpeechUtterance(ssml: nil).ssml, nil)

        XCTAssertEqual(RHSpeechUtterance(text: "Test").ssml, "<speak>Test</speak>")
        XCTAssertEqual(RHSpeechUtterance(ssml: "Test").ssml, "Test")
        XCTAssertEqual(RHSpeechUtterance(ssml: "<speak>Test</speak>").ssml, "<speak>Test</speak>")
    }
}
