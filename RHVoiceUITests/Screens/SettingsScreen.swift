//
//  SettingsScreen.swift
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
import Foundation

class SettingsScreen: ScreenBase {

    override var keyUIElement: XCUIElement {
        return rhVoiceText
    }

    var rhVoiceText: XCUIElement {
        return app.staticTexts["RHVoice"]
    }

    var doneButton: XCUIElement {
        return app.buttons["ios_done".localized]
    }

    func closeSettings() -> ScreenBase {
        doneButton.tap()
        var result: ScreenBase = LanguagesScreen(application: app)
        result.waitForAppearance(timeout: 5)
        if result.isActive() {
            return result
        }

        result = VoicesScreen(application: app)
        result.waitForAppearance(timeout: 5)
        return result
    }
}
