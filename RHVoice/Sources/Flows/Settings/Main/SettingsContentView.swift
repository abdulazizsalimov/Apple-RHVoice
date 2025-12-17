//
//  SettingsContentView.swift
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

struct QualitySelectionView: View {
    var items: [RHSpeechUtteranceQuality]
    @Binding var selectedItem: RHSpeechUtteranceQuality
    
    var body: some View {
        List(items) { item in
            HStack {
                Text(item.string)
                Spacer()
                if self.selectedItem == item {
                    Image(systemName: "checkmark")
                }
            }
            .accessibilityElement()
            .accessibilityLabel(item.string)
            .accessibilityHint((self.selectedItem == item ? "" : String.localized("ios_select_quality_voiceover_hint",
                                                                        comment: "Accessibility hint message pronounced to the user when selecting language quality setting.")))
            .accessibilityAddTraits(self.selectedItem == item ? .isSelected : .isButton)
            .contentShape(Rectangle())
            .onTapGesture {
                self.selectedItem = item
            }
        }
        .navigationTitle("speech_quality")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

struct SettingsContentView: View {
    @StateObject var hostModel: SettingsHostModel
    @Binding var isPresented: Bool
#if !os(macOS)
    @State var isPresentedUserGuide = false
#endif
    
    @ViewBuilder
    private func speechEngineStatusView() -> some View {
        HStack {
            Text("ios_speech_engine")
            Spacer()
            Text(hostModel.viewModel.audioUnitStatus.string)
        }
    }
    
    @ViewBuilder
    private func installedLanguagesSection() -> some View {
        Section("ios_languages_settings") {
            ForEach(hostModel.viewModel.installedLanguages, id: \.self) { language in
                
                let hasSomeUpdates = language.hasSomeUpdates
                
                NavigationLink {
                    LanguageSettingsContentView(hostModel: LanguageSettingsHostModel(language: language))
                } label: {
                    HStack {
                        Text(language.localizedName)
                        if hasSomeUpdates {
                            Spacer()
                            Circle()
                                .foregroundColor(.accentColor)
                                .frame(maxHeight: 15)
                        }
                    }
                }
                .accessibilityLabel(language.localizedName)
                .accessibilityHint(hasSomeUpdates ? String.localized("ios_has_updates") : "")
            }
        }
    }
    
    private func openUserGuideButton() -> some View {
        Section {
            Button {
#if os(iOS) && !targetEnvironment(macCatalyst)
                self.isPresentedUserGuide = true
#else
                hostModel.openUserGuide()
#endif
            } label: {
                Text("ios_user_guide")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(String.localized("ios_automatic_updates_on_wifi", comment: ""), isOn: $hostModel.viewModel.automaticUpdatesOnWiFi)
                } footer: {
                    Text("ios_automatic_updates_on_wifi_description".localized)
                }
                
                Section {
                    Toggle("ios_language_switching_name", isOn: $hostModel.viewModel.languageSwitching)
                }
                
                Section {
#if !os(macOS)
                    NavigationLink {
                        QualitySelectionView(items: RHSpeechUtteranceQuality.allCases, selectedItem: .init(get: {
                            return hostModel.viewModel.speachQuality
                        }, set: { quality in
                            hostModel.viewModel.speachQuality = quality
                        }))
                    } label: {
                        HStack {
                            Text("speech_quality")
                            Spacer()
                            Text(hostModel.viewModel.speachQuality.shortString)
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel(String.localized("speech_quality") + ".")
                    .accessibilityValue(hostModel.viewModel.speachQuality.string)
                    .accessibilityHint(String.localized("ios_select_quality_voiceover_hint"))
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityAddTraits(.isButton)
 #else
                    Picker(selection: .init(get: {
                        return hostModel.viewModel.speachQuality
                    }, set: { quality in
                        hostModel.viewModel.speachQuality = quality
                    })) {
                        ForEach(RHSpeechUtteranceQuality.allCases, id: \.self) {
                            Text($0.string)
                        }
                    } label: {
                        HStack {
                            Text("speech_quality")
                            Spacer()
                        }
                    }
                    .pickerStyle(.menu)
#endif
                }
                if !hostModel.viewModel.installedLanguages.isEmpty {
                    installedLanguagesSection()
                }
                
                openUserGuideButton()
                
                Section("ios_versions") {
                    HStack {
                        Text("ios_application")
                        Spacer()
                        Text(hostModel.viewModel.appVersion)
                    }
                    .accessibilityElement()
                    .accessibilityLabel(String.localized("ios_application_version_voiceover_label", arguments: [hostModel.viewModel.appVersion]))
                    
                    HStack {
                        Text("RHVoice", comment: "Application name")
                        Spacer()
                        Text(hostModel.viewModel.rhVoiceVersion)
                    }
                    .accessibilityElement()
                    .accessibilityLabel(String.localized("ios_engine_version_voiceover_label", arguments: [hostModel.viewModel.rhVoiceVersion]))
                }
                
                Section {
                    if hostModel.viewModel.audioUnitStatus == .connected {
                        speechEngineStatusView()
                    } else {
                        Button {
                            hostModel.connectAudioUnit()
                        } label: {
                            speechEngineStatusView()
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        LicensesContentView(hostModel: LicensesHostModel())
                    } label: {
                        Text("ios_licenses")
                    }
                } footer: {
                    HStack {
                        Spacer()
                        VStack {
                            Text("ios_credit_line1")
                            Text("ios_credit_line2")
                        }
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .navigationTitle(Text("settings".localized))
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("ios_done".localized)
                            .bold()
                    }
                }
            }
            .sheet(isPresented: $isPresentedUserGuide) {
                if let userGuideURL = hostModel.userGuideURL {
                    SafariView(url: userGuideURL)
                }
            }
#endif
        }
    }
}

#if DEBUG
 struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView(hostModel: SettingsHostModel(languages: nil), isPresented: .constant(true))
    }
 }
#endif
