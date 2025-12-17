//
//  RHVoiceManager+Synthesizer.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/19/25.
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
import AVFoundation
import RHVoice

extension RHVoiceManager {
    func activatePlaybackMode() {
#if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch let error {
            Log.error("Error happened during activating playback. Error:\(error)")
        }
#endif
    }
    
    func setAudioSession(active: Bool) {
        self.isPlaying = active
#if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch let error {
            Log.error("Error happened during setting audio session active status:\(active)  Error:\(error)")
        }
#endif
    }
}

#if USE_RHVOICE_SYNTHESIZER
// MARK: - RHSpeechSynthesizerDelegate
extension RHVoiceManager: RHSpeechSynthesizerDelegate {
    func speechSynthesizer(_ speechSynthesizer: RHSpeechSynthesizer, didFinish utterance: RHSpeechUtterance) {
        stopPlaying()
    }
    
    func speechSynthesizer(_ speechSynthesizer: RHSpeechSynthesizer, didFailToSynthesize utterance: RHSpeechUtterance, withError error: Error?) {
        stopPlaying()
    }
}
#else
// MARK: - AVSpeechSynthesizerDelegate
extension RHVoiceManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        stopPlaying()
    }
}
#endif
