//
//  ScreenBase.swift
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

class ScreenBase {

    var app: XCUIApplication

    init(application: XCUIApplication = XCUIApplication()) {
        app = application
    }

    func isActive() -> Bool {
        return keyUIElement.exists
    }

    @discardableResult func waitForAppearance(timeout: TimeInterval = 30) -> Bool {
        return keyUIElement.waitForExistence(timeout: timeout)
    }

    var keyUIElement: XCUIElement {
        return app.tables.textFields["doesn't exists"]
    }

    func snapshot() {
        Snapshot.snapshot("\(String(describing: type(of: self)))")
    }
}

extension ScreenBase {
    var settingsButton: XCUIElement {
        return app.navigationBars.firstMatch.buttons["settings".localized]
    }

    func openSetting() -> SettingsScreen {
        settingsButton.tap()
        let result = SettingsScreen(application: app)
        result.waitForAppearance()
        return result
    }
}
