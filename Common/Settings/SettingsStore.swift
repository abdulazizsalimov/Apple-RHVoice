//
//  SettingsStore.swift
//
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

import Foundation
import Combine
import RHVoice

class SettingsStore {
    
    var quality: RHSpeechUtteranceQuality {
        get {
            return settings.quality
        }
        set {
            settings.quality = newValue
            setValuesToStore()
        }
    }
    
    var automaticUpdates: Bool {
        get {
            return settings.automaticUpdates
        }
        
        set {
            settings.automaticUpdates = newValue
            setValuesToStore()
        }
    }
    
    var languageSwitching: Bool {
        get {
            return settings.languageSwitching
        }
        
        set {
            settings.languageSwitching = newValue
            setValuesToStore()
        }
    }
    
    var voicesSettings: [VoiceSettings] {
        return Array(settings.voicesSettings.values)
    }
    
    public static let shared = SettingsStore()
    
    private var userDefaults = UserDefaults(suiteName: GeneratedConstants.applicationGroupIdentifier)
    
    private var settings = SettingsItems()
    
    private var settingsUpdatedObservation: AnyCancellable?
    
    init() {
        updateValuses()
        settingsUpdatedObservation = UserDefaults.standard.publisher(for: \.settingsData)
            .sink(receiveValue: { [weak self] _ in
                self?.updateValuses()
            })
    }
    
    private func setValuesToStore() {
        userDefaults?.settings = settings
    }
    
    func updateValuses() {
        if let settings = userDefaults?.settings {
            self.settings = settings
        } else {
            Log.info("There are no setting stored in user defaults. Using default values")
            self.settings = SettingsItems()
        }
    }
    
    func languageSettings(for code: String) -> LanguageSettings {
        return settings.languageSettings(for: code)
    }
    
    func setLanguageSettings(for code: String, languageSettings: LanguageSettings) {
        settings.setLanguageSettings(for: code, languageSettings: languageSettings)
        userDefaults?.settings = settings
    }
    
    func voiceSettings(for voiceId: String) -> VoiceSettings {
        return settings.voicesSettings(for: voiceId)
    }
    
    func setVoiceSettings(for voiceId: String, voiceSettings: VoiceSettings) {
        settings.setVoicesSettings(for: voiceId, voiceSettings: voiceSettings)
        userDefaults?.settings = settings
    }
    
    func removeVoiceSettings(for voiceId: String) {
        settings.removeVoicesSettings(for: voiceId)
        userDefaults?.settings = settings
    }

    @FileBacked(
        default: [],
        urlProvider: { FileManager.default.rhvoiceSupportedVoicesDataFileURL },
        makeUnprotected: true
    )
    var supportedVoices: [RHSpeechSynthesisProviderVoice]?
    
    @FileBacked(
        default: [],
        urlProvider: { FileManager.default.documentsDirectoryURL
            .appendingPathComponent(Constants.SupportedVoicesDataFile) },
        makeUnprotected: true
    )
    var supportedVoicesExtension: [RHSpeechSynthesisProviderVoice]?
}

fileprivate extension UserDefaults {
    
    private static let userDefaultsSettingsKey = "RHVoiceSettings"
    
    @objc dynamic var settingsData: Data? {
        get {
            synchronize()
            return object(forKey: UserDefaults.userDefaultsSettingsKey) as? Data
        }
        set {
            guard let newValue else {
                removeObject(forKey: UserDefaults.userDefaultsSettingsKey)
                return
            }
            set(newValue, forKey: UserDefaults.userDefaultsSettingsKey)
            synchronize()
        }
    }
    
    var settings: SettingsItems {
        get {
            if let settingsData {
                let decoder = JSONDecoder()
                if let settings = try? decoder.decode(SettingsItems.self, from: settingsData) {
                   return settings
                }
            }
            return SettingsItems()
        }
        
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                settingsData = encoded
            }
        }
    }
}
