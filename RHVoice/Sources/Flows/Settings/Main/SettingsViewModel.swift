//
//  SettingsViewModel.swift
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
import RHVoice

struct SettingsViewModel {
    var speachQuality: RHSpeechUtteranceQuality
    var automaticUpdatesOnWiFi: Bool
    var languageSwitching: Bool
    var installedLanguages: [Language] = []
    var appVersion: String = ""
    var rhVoiceVersion: String = ""
    var audioUnitStatus: RHVoiceAudioUnit.Status = .disconnected
}

extension RHVoiceAudioUnit.Status {
    var string: String {
        switch self {
        case .disconnected:
            return "ios_disconnected".localized
        case .connected:
            return "ios_connected".localized
        case .failedToConnect:
            return "ios_failed_to_connect".localized
        }
    }
}
