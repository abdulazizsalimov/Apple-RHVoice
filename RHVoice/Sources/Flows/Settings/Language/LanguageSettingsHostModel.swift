//
//  LanguageSettingsHostModel.swift
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

class LanguageSettingsHostModel: ObservableObject, @unchecked Sendable {
    let settingsStore = SettingsStore.shared
    
    let language: Language
    @Published var viewModel: LanguageSettingsViewModel
    
    private var settingsUpdatedObservation: AnyCancellable?
    
    init(language: Language) {
        
        let settings = settingsStore.languageSettings(for: language.code)
        
        self.viewModel = LanguageSettingsViewModel(volume: settings.volume,
                                                   rate: settings.rate,
                                                   country: language.localizedName,
                                                   isUpdating: false)
        self.language = language
        
        settingsUpdatedObservation = $viewModel.sink { [weak self] newValue in
            
            guard let self else {
                return
            }
            
            let settings = self.settingsStore.languageSettings(for: self.language.code)
            settings.rate = newValue.rate
            settings.volume = newValue.volume
            self.settingsStore.setLanguageSettings(for: self.language.code, languageSettings: settings)
        }
    }
    
    func update() {
        viewModel.isUpdating = true
        AppManager.shared.taskSerializer.run { [weak self] in
            await self?.doUpdate()
        }
    }
    
    private func doUpdate() async {
        if language.hasUpdate {
            await AppManager.shared.voiceManager.update(language: language)
        }

        for voice in language.voices where voice.hasUpdate {
            await AppManager.shared.voiceManager.update(voice: voice, for: language)
        }

        DispatchQueue.main.async { [weak self] in
            self?.viewModel.isUpdating = false
        }
    }
}
