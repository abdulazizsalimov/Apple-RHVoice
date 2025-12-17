//
//  MainContentView.swift
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

#if os(iOS)
import UIKit
private let backGroundColor = UIColor.secondarySystemBackground
#elseif os(macOS)
import AppKit
private let backGroundColor = NSColor.controlBackgroundColor
#endif

struct MainContentView: View {
    @StateObject var hostModel: MainHostModel
    @State var showSettingsModalView = false

    @ViewBuilder
    private func languagesList() -> some View {
        if let languages = hostModel.viewModel.languages {
            switch languages.count {
            case 0:
                Text("ios_no_languages".localized)
            case 1:
                if let language = languages.first {
                    LanguageContentView(hostModel: LanguageHostModel(language: language))
                } else {
                    Text("ios_no_languages".localized)
                        .font(.title)
                }
            default:
                List(languages) { language in
                    NavigationLink {
                        LanguageContentView(hostModel: LanguageHostModel(language: language))
                    } label: {
                        Text(language.localizedName)
                            .font(.title2)
                    }
                }
            }
        }
    }

    private func jailbreakWarning() -> some View {
        Text("ios_app_jailbreak_warning".localized)
            .foregroundColor(.orange)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    var body: some View {
        NavigationStack {
            VStack {

                if hostModel.viewModel.showLoadingIndicator {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .background()
                } else {
                    if hostModel.viewModel.showJailbreakWarning {
                        jailbreakWarning()
                    }

                    if hostModel.viewModel.showSideLoadedWarning {
                    }
 
                    languagesList()
                }
            }
            .navigationTitle("languages".localized)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if hostModel.viewModel.languages != nil {
                    Button {
                        showSettingsModalView = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(String.localized("settings",
                                                         comment: "Settings title"))
                }
            }
#endif

        }
        .onAppear {
            if hostModel.viewModel.languages?.count ?? 0 > 1 {
#if !os(macOS)
                UIAccessibility.post(notification: .announcement, argument: String.localized( "ios_main_screen_voiceover_message", comment: "Message pronused to user when main screen opens."))
#endif
            }
        }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsContentView( hostModel: SettingsHostModel(languages: hostModel.viewModel.languages), isPresented: $showSettingsModalView)
        }
#if !os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            hostModel.updateLanguages()
        }
#endif
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(hostModel: MainHostModel())
    }
}
#endif
