//
//  VoiceHostModel.swift
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

import Foundation
import RHVoice
import Combine

class VoiceHostModel: BaseHostModel, @unchecked Sendable {
    
    @Published private(set) var viewModel: VoiceViewModel
    
    var stopPlayingCancellable: AnyCancellable?
    
    init(voice: Voice, language: Language) {
        self.viewModel = VoiceViewModel(voice: voice, language: language)
        super.init()
        stopPlayingCancellable =  AppManager.shared.voiceManager.$isPlaying.sink { [weak self] isPlaying in
            guard let self = self else {
                return
            }
            
            if !isPlaying {
                self.viewModel.isPlaying = false
                self.publishUpdate()
            }
        }
    }
    
    deinit {
        AppManager.shared.voiceManager.stopPlaying()
    }
    
    func download(voice: Voice) {
        viewModel.showActivityIndicator = true
        publishUpdate()
        AppManager.shared.taskSerializer.run { [weak self] in
            await self?.doDownload(voice: voice)
        }
    }
    
    private func doDownload(voice: Voice) async {
        let language = viewModel.language
        await AppManager.shared.voiceManager.download(voice: voice, for: language)
        viewModel.showActivityIndicator = false
        if !viewModel.language.supportedBySystem && AppManager.shared.storageManager.shouldShowUnsupportedLanguageHelpMessage(language: viewModel.language) {
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.shouldShowUnsupportedLanguageMessage = true
                AppManager.shared.storageManager.notifyAboutShownUnsupportedLanguageHelpMessage(language: language)
            }
        }
        publishUpdate()
    }
    
    func remove(voice: Voice) {
        viewModel.showActivityIndicator = true
        publishUpdate()
        AppManager.shared.taskSerializer.run { [weak self] in
            await self?.doRemove(voice: voice)
        }
    }
    
    private func doRemove(voice: Voice) async {
        await AppManager.shared.voiceManager.remove(voice: voice, with: viewModel.language)
        viewModel.showActivityIndicator = false
        publishUpdate()
    }
    
    func playNotInstalledSample(voice: Voice) {
        AppManager.shared.voiceManager.playNotInstalledSample(voice: voice)
        viewModel.isPlaying = true
        publishUpdate()
    }
    
    func playInstalledSample(voice: RHSpeechSynthesisProviderVoice?) {
        AppManager.shared.voiceManager.playInstalledSample(voice: voice, demo: viewModel.language.testMessage)
        viewModel.isPlaying = true
        publishUpdate()
    }
    
    func stopPlaying() {
        AppManager.shared.voiceManager.stopPlaying()
        viewModel.isPlaying = false
        publishUpdate()
    }
    
    let howToUseVoiceURL = URL(string: "https://rhvoice.com/apple_support#use-voice")
    
    var canOpenHowToUseVoice: Bool {
        howToUseVoiceURL != nil
    }
    
    func openHowToUseVoice() {
        howToUseVoiceURL?.open()
    }
}
