//
//  VoicesScreen.swift
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

class VoicesScreen: ScreenBase {
    override var keyUIElement: XCUIElement {
        return staticTextTitle
    }

    var staticTextTitle: XCUIElement {
        return app.navigationBars.firstMatch.staticTexts[language]
    }

    var language: String

    init(language: String, application: XCUIApplication = XCUIApplication()) {
        self.language = language
        super.init(application: application)
    }

    override init(application: XCUIApplication = XCUIApplication()) {
        self.language = application.navigationBars.firstMatch.staticTexts.firstMatch.label
        super.init(application: application)
    }

    var backButton: XCUIElement {
        return app.navigationBars.firstMatch.buttons["languages".localized]
    }

    var installedVoices: [String] {
        let voicesContainers = app.collectionViews.descendants(matching: .other).matching(NSPredicate.uninstall(voice: "*"))

        var result: [String] = []
        let queryIterator = XCUIElementQueryIterator(query: voicesContainers)
        for element in queryIterator {
            let label = element.staticTexts.firstMatch.label
            var components = label.components(separatedBy: " ")
            components.removeLast()
            let voiceName = components.joined(separator: " ")
            result.append(voiceName)
        }

        return result
    }

    var availableVoices: [String] {
        let voicesContainers = app.collectionViews.descendants(matching: .other).matching(NSPredicate.install(voice: "*"))

        var result: [String] = []
        let queryIterator = XCUIElementQueryIterator(query: voicesContainers)
        for element in queryIterator {
            let voiceName = element.staticTexts.firstMatch.label
            result.append(voiceName)
        }

        return result
    }

    var voices: [String] {
        return installedVoices + availableVoices
    }

    func install(voice: String) {
        let installElement = app.collectionViews.descendants(matching: .other).matching(NSPredicate.install(voice: voice)).firstMatch
        _ = installElement.waitForExistence(timeout: 5)
        installElement.tap()
        let uninstallElement = app.collectionViews.descendants(matching: .other).matching(NSPredicate.uninstall(voice: voice)).firstMatch
        _ = uninstallElement.waitForExistence(timeout: 30)
        let uninstallButton = uninstallElement.buttons["Trash"]
        _ = uninstallButton.waitForExistence(timeout: 5)
    }

    func uninstall(voice: String) {

    }

    func backToLanguages() -> LanguagesScreen {
        backButton.tap()
        let result = LanguagesScreen(application: app)
        result.waitForAppearance()
        return result
    }
}

fileprivate extension NSPredicate {
    class func install(voice: String) -> NSPredicate {
        let localizedLabel = "ios_install_voice".localized
        return NSPredicate(format: "label LIKE '\(localizedLabel.replacingOccurrences(of: "%@", with: voice))'")
    }

    class func uninstall(voice: String) -> NSPredicate {
        let localizedLabel = "ios_uninstall_voice".localized
        return NSPredicate(format: "label LIKE '\(localizedLabel.replacing("%@", with: voice, maxReplacements: 1))'")
    }
}
