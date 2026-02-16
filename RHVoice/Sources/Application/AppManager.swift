//
//  AppManager.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 14.09.2022.
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

import Foundation

class AppManager {
    static let shared = AppManager()
    let apiConnector: APIConnectorInterface
    let voiceManager: RHVoiceManager
    let storageManager = StorageManager()
    let reachability = ReachabilityManager()
    let taskSerializer = SerialTasks(name: "AppManager")
    let backgroundTasks = BackgroundTasksManager()
    let audioUnit: RHVoiceAudioUnit

    static var isBundledMode: Bool {
        return Bundle.main.path(forResource: Constants.RHVoiceDataFolderName, ofType: nil) != nil
    }

    init(apiConnector: APIConnectorInterface? = nil,
         dataPath: URL? = FileManager.default.rhvoiceDataPathURL,
         packagePath: URL? = FileManager.default.rhvoicePackagePathURL) {
        let resolvedDataPath: URL?
        let resolvedConnector: APIConnectorInterface

        if AppManager.isBundledMode,
           let bundlePath = Bundle.main.path(forResource: Constants.RHVoiceDataFolderName, ofType: nil) {
            resolvedDataPath = URL(fileURLWithPath: bundlePath)
            resolvedConnector = apiConnector ?? BundledAPIConnector()
        } else {
            resolvedDataPath = dataPath
            resolvedConnector = apiConnector ?? APIConnector()
        }

        self.apiConnector = resolvedConnector
        self.voiceManager = RHVoiceManager(dataPath: resolvedDataPath, pkgPath: packagePath, apiConnector: self.apiConnector)
        self.audioUnit = RHVoiceAudioUnit(taskSerializer: taskSerializer)
    }
}
