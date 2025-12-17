//
//  XCTestCase.swift
//  RHVoiceAppTests
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

@testable import RHVoiceApp

extension XCTestCase {

    enum UnitTestErrors: Error {
        case installFailed
        case versionUpdateFailed
        case cantGetValue
    }

    var languages: [Language]? {
        var result: [Language]?
        let languagesLoaded = expectation(description: "Languages Loaded")
        AppManager.mock.taskSerializer.run {
            result = await AppManager.mock.apiConnector.languages()
            languagesLoaded.fulfill()
        }
        wait(for: [languagesLoaded], timeout: 1)
        return result
    }

    func install(voice: Voice, for language: Language) {
        let voiceInstalled = expectation(description: "Voice Install Finished")
        AppManager.mock.taskSerializer.run {
            await AppManager.mock.voiceManager.download(voice: voice, for: language)
            voiceInstalled.fulfill()
        }
        wait(for: [voiceInstalled], timeout: 1)
    }

    func remove(voice: Voice, for language: Language) {
        let voiceRemoved = expectation(description: "Voice Remove Finished")
        AppManager.mock.taskSerializer.run {
            await AppManager.mock.voiceManager.remove(voice: voice, with: language)
            voiceRemoved.fulfill()
        }
        wait(for: [voiceRemoved], timeout: 1)
    }

    func updateVoice(voice: Voice, for language: Language) {
        let voiceUpdated = expectation(description: "Voice Update Finished")
        AppManager.mock.taskSerializer.run {
            await AppManager.mock.voiceManager.update(voice: voice, for: language)
            voiceUpdated.fulfill()
        }
        wait(for: [voiceUpdated], timeout: 1)
    }

    func instalAnyVoice() throws -> (Voice, Language) {
        let language: Language? = languages?.first
        let voice = language?.voices.first
        XCTAssertNotNil(voice, "Voice can't be nil. Do not proceed with testing.")
        guard let voice, let language else {
            XCTFail("Voice:\(String(describing: voice)) and Language:\(String(describing: language)) can't be nil")
            throw UnitTestErrors.installFailed
        }
        install(voice: voice, for: language)

        XCTAssertTrue(language.isInstalled)
        XCTAssertTrue(voice.isInstalled)

        return (voice, language)
    }

    func newVoiceValue(for voice: Voice) throws -> Voice {

        guard let languages else {
            throw UnitTestErrors.cantGetValue
        }

        let voices = languages.flatMap { $0.voices }

        guard let result = voices.first(where: { object in
            return object.id == voice.id
        }) else {
            throw UnitTestErrors.cantGetValue
        }
        return result
    }

    func newLanguageValue(for language: Language) throws -> Language {

        guard let languages else {
            throw UnitTestErrors.cantGetValue
        }

        guard let result = languages.first(where: { object in
            return object.id == language.id
        }) else {
            throw UnitTestErrors.cantGetValue
        }
        return result
    }

    func removeAllInstlledVoicesAndLangauges() {
        try? FileManager.default.removeItem(at: FileManager.default.rhvoiceDataPathURLInDocuments)
        if let rhvoiceDataPathURL = FileManager.default.rhvoiceDataPathURL {
            try? FileManager.default.removeItem(at: rhvoiceDataPathURL)
        }
        AppManager.mock.voiceManager.updateEngineAndSystem()
    }
}
