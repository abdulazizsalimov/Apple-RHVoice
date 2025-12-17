//
//  LanguageContentView.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 12.09.2022.
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

struct LanguageContentView: View {
    @StateObject var hostModel: LanguageHostModel
    
    var body: some View {
        let languageName = hostModel.viewModel.language.localizedName
        VStack {
            let voices = hostModel.viewModel.language.voices
            if voices.isEmpty {
                Text("ios_no_voices".localized)
            } else {
                let installedLanguage = hostModel.viewModel.language.installedLanguage
                let sections = hostModel.viewModel.language.voicesByCountryCode
                let keys = Array(sections.keys).sorted(using: .localized)
                
                ScrollView {
                    ForEach(keys, id: \.self) { sectionName in
                        if let voices = sections[sectionName] {
                            
                            let sectionTitle = Locale.current.localizedString(forRegionCode: sectionName) ?? ""
                            HStack {
                                Text("\(languageName) (\(sectionTitle))")
                                    .font(.title)
                                    .padding()
                                Spacer()
                            }
                    
                            ForEach(voices, id: \.id) { voice in
                                VoiceView(hostModel: VoiceHostModel(voice: voice, language: hostModel.viewModel.language))
                            }
                        }
                    }
                }

                if let languageVersion = installedLanguage?.version?.string() {
                    Text(languageVersion)
                        .accessibilityElement()
                        .accessibilityLabel(String.localized("ios_language_name_and_version", comment: "Language's name followed by language's version. 'Shown' only when there is at least one voice of this language downloaded", arguments: [languageVersion]))
                        .accessibilityAddTraits(.isStaticText)
                        .padding()
                }
            }
        }
        .navigationTitle(languageName)
        .onAppear {
#if !os(macOS)
            UIAccessibility.post(notification: .announcement, argument: Text("ios_language_screen_voiceover_message".localized))
#endif
        }
    }
}

#if DEBUG
 struct VoiceContentView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageContentView(hostModel: LanguageHostModel(language: Language.previewData))
    }
 }
#endif
