//
//  RHVoiceUITests.swift
//  RHVoiceUITests
//
//  Created by Ihor Shevchuk on 24.04.2023.
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

final class RHVoiceUITests: BaseTestCase {

    func testAppPreviews() throws {
        setupSnapshot(application)
        application.launch()
        var mainScreen = LanguagesScreen(application: application)
        mainScreen.waitForAppearance(timeout: 5)
        if mainScreen.isActive() {

            mainScreen.snapshot()

            let languages = mainScreen.languages
            guard let language = languages.first else {
                XCTFail("No languages")
                return
            }
            guard let voicesScreen = mainScreen.open(language: language) else {
                XCTFail("Failed to open language:\(language)")
                return
            }

            voicesScreen.snapshot()

            XCTAssertFalse(voicesScreen.voices.isEmpty, "Voices list can not be empty")
            mainScreen = voicesScreen.backToLanguages()

            let settingScreen = mainScreen.openSetting()
            settingScreen.snapshot()

            _ = settingScreen.closeSettings()
        } else {
            let voicesScreen = VoicesScreen(application: application)
            voicesScreen.waitForAppearance(timeout: 5)
            XCTAssertFalse(voicesScreen.voices.isEmpty, "Voices list can not be empty")
            voicesScreen.snapshot()
            let settingScreen = voicesScreen.openSetting()
            settingScreen.snapshot()
            _ = settingScreen.closeSettings()
        }
    }
}
