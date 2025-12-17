//
//  RHVoiceApp.swift
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

@main
struct RHVoiceApp: App {
    private var hostModel = MainHostModel()
#if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: RHVoiceApplicationDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: RHVoiceApplicationDelegate
#endif

    var body: some Scene {
        WindowGroup {
            MainContentView(hostModel: self.hostModel)
#if os(macOS)
                .frame(idealWidth: 450,
                       maxWidth: 450,
                       idealHeight: 450,
                       maxHeight: 450)
#endif
#if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { (_) in
                    AppManager.shared.backgroundTasks.scheduleUpdate()
                    AppManager.shared.voiceManager.stopPlaying()
                }
#endif
        }
#if os(macOS)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
#endif
#if os(macOS)
        Settings {
            SettingsContentView( hostModel: SettingsHostModel(languages: hostModel.viewModel.languages), isPresented: .constant(true))
        }
#endif
    }
}
