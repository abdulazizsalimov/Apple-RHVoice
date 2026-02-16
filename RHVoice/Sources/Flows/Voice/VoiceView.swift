//
//  VoiceView.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 21.05.2023.
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

struct VoiceView: View {
    
    @StateObject var hostModel: VoiceHostModel
    
    @State private var showingDeleteAlert = false
    
    var voice: Voice {
        return hostModel.viewModel.voice
    }

    var installedVoice: RHSpeechSynthesisProviderVoice? {
        return hostModel.viewModel.voice.installedVoice
    }
    
    private var voiceName: String {
        guard let voiceVersion else {
            return voice.name
        }
        
        return String.localized("\(voice.name) \(voiceVersion)",
                                comment: "This string shouldn't be localized.")
    }
    
    private var voiceVersion: String? {
        guard let installedVoice else {
            return nil
        }
        let languageVersionSuffix = if let languageVersion = hostModel.viewModel.language.installedLanguage?.version?.string() {
            "." + languageVersion
        } else {
            ""
        }
        return installedVoice.version + languageVersionSuffix
    }
    
    private var accessibilityLabelString: String {
        if hostModel.viewModel.showActivityIndicator == true {
            return String.localized("ios_installing_voice",
                                    comment: "Accessibility label message pronounced to the user while voice is being installed.",
                                    arguments: [voice.name])
        }
        
        if installedVoice != nil {
            var versionInfoString = ""
            if let voiceVersion {
                versionInfoString = String.localized("ios_voice_version",
                                                     comment: "Voice version string.",
                                                     arguments: [voiceVersion])
            }
            return String.localized("ios_uninstall_voice",
                                    comment: "Accessibility label message pronounced to the user for uninstall voice action.",
                                    arguments: [voice.name + " " + versionInfoString])
        }
        
        return String.localized("ios_install_voice",
                                comment: "Accessibility label message pronounced to the user for download voice action.",
                                arguments: [voice.name])
    }
    
    private var accessibilityHintString: String {
        if installedVoice != nil {
            return String.localized("ios_uninstall_voice_hint",
                                    comment: "Accessibility hint message pronounced to the user for uninstall voice action.",
                                    arguments: [voice.name])
        }
        return String.localized("ios_install_voice_hint",
                                comment: "Accessibility hint message pronounced to the user for install voice action.",
                                arguments: [voice.name])
    }
    
    private var accessibilityValueString: AttributedString {
        guard let htmlLicenceInfoString else {
            return ""
        }
        
        let licenceBeginning = String.localized("ios_license",
                                                comment: "Licence beginning. It will be followed with html licence text.")
        
        return AttributedString(licenceBeginning) + AttributedString(htmlLicenceInfoString)
    }
    
    @State private var htmlLicenceInfoString: NSAttributedString?
    private func updateLicenceInfoString() {
        DispatchQueue.main.async {
            if  let licenceInfo = voice.installedRHVoice?.licenceInfo,
                let attributedText = NSAttributedString(html: licenceInfo, textAlignment: .left) {
                htmlLicenceInfoString = attributedText
            } else {
                htmlLicenceInfoString = nil
            }
        }
    }
    
    @ViewBuilder
    private func buttonImageView(systemName: String) -> some View {
        let buttonSize = 50.0
        Image(systemName: systemName)
            .resizable()
            .imageScale(.large)
            .frame(width: buttonSize, height: buttonSize)
            .foregroundColor(.accentColor)
    }
    
    @ViewBuilder
    private func downloadVoiceView() -> some View {
        Button {
            hostModel.download(voice: voice)
        } label: {
            buttonImageView(systemName: "arrow.down.circle")
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func removeVoiceView() -> some View {
        Button {
            showingDeleteAlert.toggle()
        } label: {
            buttonImageView(systemName: "trash.circle")
        }
        .buttonStyle(PlainButtonStyle())
        .alert("voice_remove_question", isPresented: $showingDeleteAlert) {
            Button(String.localized("ios_yes",
                         comment: "'Yes' button on uninstall voice confrimation alert."), role: .destructive) {
                hostModel.remove(voice: voice)
            }
            Button(String.localized("ios_no",
                          comment: "'No' button on uninstall voice confrimation alert."), role: .cancel) {}
        }
    }
    
    @ViewBuilder
    private func progressView() -> some View {
        ProgressView()
            .scaleEffect(2.0)
            .progressViewStyle(.circular)
            .imageScale(.large)
            .frame(width: 50.0, height: 50.0)
    }
    
    @ViewBuilder
    private func toggleVoiceView() -> some View {
        Button {
            hostModel.toggleVoice()
        } label: {
            buttonImageView(systemName: hostModel.viewModel.isEnabled ? "checkmark.circle.fill" : "circle")
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func playDemo() -> some View {
        Button {
            if AppManager.isBundledMode {
                hostModel.playBundledSample()
            } else if let installedVoice {
                hostModel.playInstalledSample(voice: installedVoice)
            } else {
                hostModel.playNotInstalledSample(voice: voice)
            }
        } label: {
            buttonImageView(systemName: "play.circle")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func stopPlaying() -> some View {
        Button {
            hostModel.stopPlaying()
        } label: {
            buttonImageView(systemName: "stop.circle")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func download() -> some View {
        if AppManager.isBundledMode {
            toggleVoiceView()
        } else if hostModel.viewModel.showActivityIndicator == true {
            progressView()
        } else {
            let voiceInstalled = installedVoice != nil
            if voiceInstalled {
                removeVoiceView()
                    .onAppear {
                        updateLicenceInfoString()
                    }
            } else {
                downloadVoiceView()
                    .onAppear {
                        updateLicenceInfoString()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func installedVoiceInfo() -> some View {
        if let htmlLicenceInfoString {
            Text(AttributedString(htmlLicenceInfoString))
        }
    }
    
#if os(iOS) && !targetEnvironment(macCatalyst)
    @State var isPresentedUserGuide = false
#endif
    @ViewBuilder
    private func howToUseVoiceButton() -> some View {
        if hostModel.canOpenHowToUseVoice {
            HStack {
                Spacer()
                Button {
#if os(iOS) && !targetEnvironment(macCatalyst)
                    self.isPresentedUserGuide = true
#else
                    hostModel.openHowToUseVoice()
#endif
                    
                } label: {
                    buttonImageView(systemName: "info.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityElement()
                .accessibilityLabel(String.localized("ios_voice_help_button"))
                .accessibilityAddTraits(.isButton)
            }
#if os(iOS) && !targetEnvironment(macCatalyst)
            .sheet(isPresented: $isPresentedUserGuide) {
                if let userGuideURL = hostModel.howToUseVoiceURL {
                    SafariView(url: userGuideURL)
                }
            }
#endif
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                        .frame(width: 10)
                    
                    Text(voiceName)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .font(.title2)
                    if hostModel.viewModel.isPlaying {
                        stopPlaying()
                            .accessibilityElement()
                            .accessibilityLabel(String.localized("ios_stop_sample"))
                            .accessibilityAddTraits(.isButton)
                    } else {
                        playDemo()
                            .accessibilityElement()
                            .accessibilityLabel(String.localized("ios_play_sample"))
                            .accessibilityAddTraits(.isButton)
                    }
                    download()
                        .accessibilityElement()
                        .accessibilityAddTraits(.isButton)
                        .accessibilityVoice(label: accessibilityLabelString,
                                            hint: accessibilityHintString,
                                            licence: accessibilityValueString)
                }
                .fixedSize(horizontal: false, vertical: true)
                howToUseVoiceButton()
                if let about = voice.about {
                    Text(about)
                        .font(.title3)
                        .padding(.vertical, 8)
                }
                installedVoiceInfo()
            }
            .padding()
            Divider()
        }
        .alert("", isPresented: .init(get: {
            return hostModel.viewModel.shouldShowUnsupportedLanguageMessage
        }, set: { _ in
        }), actions: {
            Button(String.localized("ios_ok"), role: .cancel) {
                hostModel.viewModel.shouldShowUnsupportedLanguageMessage = false
            }
        }, message: {
            Text(String.localized("ios_unsupported_language_alert_message"))
        })
    }
}

fileprivate extension View {

    func accessibilityVoice(label: String, hint: String, licence: AttributedString) -> some View {
        return accessibilityLabel(label)
            .accessibilityHint(Text(hint))
            .accessibilityValue(Text(licence))
    }
}

#if DEBUG
 struct VoiceView_Previews: PreviewProvider {
     
    static var previews: some View {
        List {
            VoiceView(hostModel: VoiceHostModel(voice: Language.previewData.voices.first!, language: Language.previewData))
        }
#if !os(macOS)
        .listStyle(.insetGrouped)
#endif
    }
 }
#endif
