//
//  Language.swift
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
import RHVoice
import AVFAudio

extension Language: Identifiable {
    var id: String {
        return code + "_" + version.string
    }
}

extension Language: Equatable {
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.id == rhs.id
        && lhs.version == rhs.version
        && lhs.voices == rhs.voices
    }
}

extension Language: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension Language {
    var installedLanguage: RHLanguage? {
        return RHVoiceBridge.sharedInstance().languages().first { lang in
            return lang.code == code
        }
    }
    
    var voicesByCountryCode: [String: [Voice]] {
        return Dictionary(grouping: voices, by: {$0.ctry2code})
    }
    
    var localizedName: String {
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? name
    }
    
    var supportedBySystem: Bool {
        let avVoice = AVSpeechSynthesisVoice.speechVoices().first { voice in
            return voice.language.starts(with: code) && voice.identifier.starts(with: "com.apple.")
        }
        return avVoice != nil
    }
}

extension Language: Versionable {
    var installedVersion: Version? {
        return installedLanguage?.version?.modelVersion
    }
}

extension Language: VersionableResourse {
    static var resourseType: String {
        return "language"
    }

    var countryCode: String {
        return code
    }
}

extension Language {
    var hasSomeUpdates: Bool {
        if hasUpdate {
            return true
        }

        for voice in voices where voice.hasUpdate {
                return true
        }

        return false
    }
}

#if DEBUG
extension Language {
    static var previewData: Language {
        let json = """
              {
                    "lang2code": "en",
                    "lang3code": "eng",
                    "testMessage": "If you can hear this message, then the voice is installed and working.",
                    "name": "English",
                    "version": {
                        "major": 2,
                        "minor": 8
                    },
                    "dataUrl": "https://rhvoice.org/download/RHVoice-language-English-v2.8.zip",
                    "dataMd5": "eFptOFRVOVxhPpzLuoj2OQ==",
                    "id": "english",
                    "voices": [
                        {
                            "name": "Alan",
                            "ctry2code": "GB",
                            "ctry3code": "GBR",
                            "accent": "Scotland",
                            "demoUrl": "https://rhvoice.org/download/demo_android_alan.ogg",
                            "version": {
                                "major": 4,
                                "minor": 0
                            },
                            "dataUrl": "https://rhvoice.org/download/RHVoice-voice-English-Alan-v4.0.zip",
                            "dataMd5": "Kt8qf8WHum+Kcbetp4HtZQ==",
                            "id": "alan"
                        },
                        {
                            "name": "BDL",
                            "ctry2code": "US",
                            "ctry3code": "USA",
                            "demoUrl": "https://rhvoice.org/download/demo_android_bdl.ogg",
                            "version": {
                                "major": 4,
                                "minor": 1
                            },
                            "dataUrl": "https://rhvoice.org/download/RHVoice-voice-English-BDL-v4.1.zip",
                            "dataMd5": "E3/pQyFc64MEABd73bHlCQ==",
                            "id": "bdl"
                        }
                    ]
                }
        """

        let jsonData = json.data(using: .utf8)!
        // swiftlint:disable:next force_try
        let result = try! JSONDecoder().decode(Language.self, from: jsonData)
        return result
    }
}
#endif
