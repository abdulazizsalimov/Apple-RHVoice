//
//  VoiceTests.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 08.01.2023.
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

@testable import RHVoiceApp

final class VoiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        removeAllInstlledVoicesAndLangauges()
    }

    override func tearDown() {
        removeAllInstlledVoicesAndLangauges()
        super.tearDown()
    }

    func testInstallAndRemoveVoice() throws {

        let language: Language? = languages?.first

        XCTAssertNotNil(language, "Language can't be nil. Do not proceed with testing.")
        guard let language else {
            return
        }

        XCTAssertFalse(language.isInstalled)
        XCTAssertFalse(language.hasUpdate)

        let voice = language.voices.first
        XCTAssertNotNil(voice, "Voice can't be nil. Do not proceed with testing.")
        guard let voice else {
            return
        }

        XCTAssertFalse(voice.isInstalled)
        XCTAssertFalse(voice.hasUpdate)
        XCTAssertFalse(language.isInstalled)
        XCTAssertFalse(language.hasUpdate)
        XCTAssertFalse(language.hasSomeUpdates)

        XCTAssertNil(language.currentFolderName)
        XCTAssertNil(voice.currentFolderName)
        let newLanguageFolder = language.newFolderName
        XCTAssertEqual(newLanguageFolder, "language" + "-" + language.code + "-" + language.name + "-" + "v" + language.version.string)
        let newVoiceFolder = voice.newFolderName
        XCTAssertEqual(newVoiceFolder, "voice" + "-" + voice.ctry2code + "-" + voice.name + "-" + "v" + voice.version.string)

        install(voice: voice, for: language)

        XCTAssertTrue(language.isInstalled)
        XCTAssertFalse(language.hasUpdate)

        XCTAssertTrue(voice.isInstalled)
        XCTAssertFalse(voice.hasUpdate)

        XCTAssertEqual(language.currentFolderName, newLanguageFolder)
        XCTAssertEqual(voice.currentFolderName, newVoiceFolder)
        XCTAssertEqual(newLanguageFolder, language.newFolderName)
        XCTAssertEqual(newVoiceFolder, voice.newFolderName)

        remove(voice: voice, for: language)

        XCTAssertFalse(language.isInstalled)
        XCTAssertFalse(language.hasUpdate)
        XCTAssertFalse(language.hasSomeUpdates)

        XCTAssertFalse(voice.isInstalled)
        XCTAssertFalse(voice.hasUpdate)
    }

    func testUpdateVoice() throws {
        let (voice, language) = try instalAnyVoice()
        XCTAssertFalse(voice.hasUpdate)

        guard let voiceInstalledVersion = voice.installedVersion else {
            XCTFail("voiceInstalledVersion can't be nil")
            return
        }

        try AppManager.mock.connectorMock?.set(version: Version(major: voiceInstalledVersion.major, minor: voiceInstalledVersion.minor + 1), for: voice)

        let newVoice = try newVoiceValue(for: voice)
        let newLanguage = try newLanguageValue(for: language)

        XCTAssertTrue(newVoice.hasUpdate)
        let newFolder = newVoice.newFolderName
        XCTAssertEqual(newFolder, "voice" + "-" + voice.ctry2code + "-" + voice.name + "-" + "v" + newVoice.version.string)
        XCTAssertEqual(newVoice.currentFolderName, "voice" + "-" + voice.ctry2code + "-" + voice.name + "-" + "v" + voice.version.string)
        XCTAssertFalse(newLanguage.hasUpdate)
        XCTAssertTrue(newLanguage.hasSomeUpdates)

        updateVoice(voice: newVoice, for: newLanguage)

        XCTAssertEqual(newVoice.currentFolderName, newFolder)
        XCTAssertFalse(newVoice.hasUpdate)
    }
}
