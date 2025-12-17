//
//  SettingsHostModel.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 20.11.2022.
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

import SwiftUI
import Combine
import RHVoice

class SettingsHostModel: BaseHostModel {
    let settingsStore = SettingsStore.shared
    
    @Published var viewModel: SettingsViewModel
    private var settingsUpdatedObservation: AnyCancellable?
    private var audioUnitObservationObservation: AnyCancellable?
    var userGuideURL: URL? {
        let userGuideURLString = String.localized("ios_userguide_link")
        return URL(string: userGuideURLString)
    }
    
    init(languages: [Language]?) {
        
        let installedLanguages = languages?.filter { lng in
            guard let installedLanguage = lng.installedLanguage else {
                return false
            }
            
            return !installedLanguage.voices.isEmpty
        }
        
        viewModel = SettingsViewModel(speachQuality: settingsStore.quality,
                                      automaticUpdatesOnWiFi: settingsStore.automaticUpdates,
                                      languageSwitching: settingsStore.languageSwitching,
                                      installedLanguages: installedLanguages ?? [],
                                      appVersion: Bundle.main.applicationVersion,
                                      rhVoiceVersion: RHVoiceBridge.sharedInstance().version())
        super.init()
        
        settingsUpdatedObservation = $viewModel.sink { [weak self] newValue in
            self?.settingsStore.quality = newValue.speachQuality
            self?.settingsStore.automaticUpdates = newValue.automaticUpdatesOnWiFi
            self?.settingsStore.languageSwitching = newValue.languageSwitching
        }
        
        AppManager.shared.audioUnit.attpemtToConnect()
        audioUnitObservationObservation = AppManager.shared.audioUnit.$status.sink { [weak self] status in
            guard let self else { return }
            self.viewModel.audioUnitStatus = status
            self.publishUpdate()
        }
    }

    func openUserGuide() {
        guard let userGuideURL else {
            Log.error("Can not create userGuideURL")
            return
        }
        userGuideURL.open()
    }
    
    func connectAudioUnit() {
        AppManager.shared.audioUnit.attpemtToConnect()
    }
}
