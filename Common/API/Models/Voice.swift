//
//  Voice.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 12/29/24.
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

final class Voice: Decodable, Sendable {
    let name: String
    let ctry2code: String
    let demoUrl: String
    let about: String?
    let version: Version
    
    let dataUrl: String
    let id: String
    private let license_needed: Bool?
    var licenseNeeded: Bool { license_needed ?? false }
    var switchingProfiles: [LanguageSwitchingProfile] {
        return languageSwitchingProfiles ?? []
    }
    
    var voiceProfile: String? {
        guard let firstProfile = switchingProfiles.first else {
            return nil
        }
        
        if let profile = firstProfile.profile {
            return profile
        }
        
        if firstProfile.voices.isEmpty {
            return nil
        }
        
        let separator = "+"
        
        let voiceIds = firstProfile.voices.map { $0.id }
        let profileString = voiceIds.joined(separator: separator)
        return id + separator + profileString
    }
    
    private let languageSwitchingProfiles: [LanguageSwitchingProfile]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case ctry2code
        case demoUrl
        case version
        case about
        case dataUrl
        case id
        case license_needed
        case languageSwitchingProfiles = "iosLanguageSwitchingProfiles"
    }

    init(name: String, ctry2code: String, demoUrl: String, version: Version, dataUrl: String, id: String) {
        self.name = name
        self.ctry2code = ctry2code
        self.demoUrl = demoUrl
        self.version = version
        self.dataUrl = dataUrl
        self.id = id
        self.license_needed = false
        self.languageSwitchingProfiles = nil
        self.about = nil
    }
}
