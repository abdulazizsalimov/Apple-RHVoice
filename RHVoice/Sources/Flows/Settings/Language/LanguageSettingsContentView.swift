//
//  LanguageSettingsContentView.swift
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

struct LanguageSettingsContentView: View {
    @StateObject var hostModel: LanguageSettingsHostModel
    
    var body: some View {
        List {
            Section("speech_volume") {
                HStack {
                    Image(systemName: "speaker.fill")
                        .accessibilityHidden(true)
                    Slider(value: $hostModel.viewModel.volume, in: LanguageSettings.volumeRange)
                        .accessibilityLabel("speech_volume")
                    Image(systemName: "speaker.wave.3.fill")
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
            }
            
            Section("speech_rate") {
                HStack {
                    Image(systemName: "tortoise")
                        .accessibilityHidden(true)
                    Slider(value: $hostModel.viewModel.rate, in: LanguageSettings.rateRange)
                        .accessibilityLabel("speech_rate")
                    Image(systemName: "hare")
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
            }
            
            if hostModel.language.hasSomeUpdates {
                Section {
                    Button {
                        hostModel.update()
                    } label: {
                        ZStack {
                            HStack {
                                Text("ios_update".localized)
                                Spacer()
                            }
                            
                            if hostModel.viewModel.isUpdating {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .imageScale(.large)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .disabled(hostModel.viewModel.isUpdating)
                }
            }
        }
        .navigationTitle(hostModel.viewModel.country)
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}
