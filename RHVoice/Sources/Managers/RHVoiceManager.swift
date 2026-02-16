//
//  RHVoiceManager.swift
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
import Combine
import AVFoundation

import RHVoice
import ZIPFoundation

class RHVoiceManager: NSObject, ObservableObject {
    
    @Published var isPlaying: Bool
    
    private var audioPlayer: AVPlayer?
#if USE_RHVOICE_SYNTHESIZER
    private var synthesizer: RHSpeechSynthesizer = {
        return RHSpeechSynthesizer()
    }()
#else
    private var synthesizer: AVSpeechSynthesizer = {
        return AVSpeechSynthesizer()
    }()
#endif
    private let dataFolder: URL

    private weak var apiConnector: APIConnectorInterface?

    var installedVoices: [RHSpeechSynthesisVoice] {
#if os(macOS)
        guard let supportedVoices = SettingsStore.shared.supportedVoices else {
            return []
        }
        
        let supportedVoicesIds = Set(supportedVoices.map { voice in
            voice.identifier
        })
#endif
        return RHSpeechSynthesisVoice.speechVoices()
#if os(macOS)
            .filter { voice in
                return supportedVoicesIds.contains(voice.identifier)
            }
#endif
    }
    
    private static let disabledVoicesKey = "BundledDisabledVoices"

    var disabledVoiceIDs: Set<String> {
        get {
            if let ids = UserDefaults.standard.array(forKey: RHVoiceManager.disabledVoicesKey) as? [String] {
                return Set(ids)
            }
            return Set()
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: RHVoiceManager.disabledVoicesKey)
        }
    }

    func isVoiceEnabled(_ voiceId: String) -> Bool {
        return !disabledVoiceIDs.contains(voiceId.lowercased())
    }

    func setVoiceEnabled(_ voiceId: String, enabled: Bool) {
        var ids = disabledVoiceIDs
        if enabled {
            ids.remove(voiceId.lowercased())
        } else {
            ids.insert(voiceId.lowercased())
        }
        disabledVoiceIDs = ids
        Task {
            await updateSharedVoicesStoreForBundled()
        }
    }

    func updateSharedVoicesStoreForBundled() async {
        let disabled = disabledVoiceIDs
        let allVoices = RHSpeechSynthesisVoice.speechVoices()
        let enabledVoices = allVoices.filter { !disabled.contains($0.identifier.lowercased()) }
        let avVoices = enabledVoices.rhAVVoices
        SettingsStore.shared.supportedVoices = avVoices
        SettingsStore.shared.supportedVoicesExtension = avVoices
        AppManager.shared.audioUnit.installedVoices = avVoices
        notifySystemAboutVoiceNumberChange()
        Log.info("Updated bundled voices store. Enabled count: \(avVoices.count)")
    }

    func playBundledSample(voiceName: String, demo: String) {
        stopPlaying()
        setAudioSession(active: true)
        let allVoices = RHSpeechSynthesisVoice.speechVoices()
        guard let rhVoice = allVoices.first(where: { $0.name.lowercased() == voiceName.lowercased() }) else {
            Log.error("Can not find bundled voice: \(voiceName)")
            return
        }
        let avVoice = rhVoice.avVoice
        playInstalledSample(voice: avVoice, demo: demo)
    }

    @discardableResult func getLanguagesAndUpdate() async -> [Language] {
        guard let languages = await apiConnector?.languages() else {
            return []
        }
        
        if !AppManager.isBundledMode && SettingsStore.shared.automaticUpdates {
            if let info = await AppManager.shared.reachability.getInfo() {
                if info.canBeUsedForUpdates {
                    Log.debug("Updating languages and voices because automaticUpdates is enabled and network connection is suitable for downloading.")
                    await updateLanguagesAndVoices(languages: languages)
                }
            }
        }
        
        return languages
    }
    
    init(dataPath: URL?, pkgPath: URL?, apiConnector: APIConnectorInterface) {
        if let dataPath {
            self.dataFolder = dataPath
        } else {
            Log.error("Can't find shared folder between extension and main app. Speech synthesizer outside application will not work!. Fallbacking to Documents folder.")
            self.dataFolder = FileManager.default.rhvoiceDataPathURLInDocuments
        }
        self.apiConnector = apiConnector
        self.isPlaying = false
        super.init()

        let initParams = RHVoiceBridgeParams.iOSDefault
        let dataFolderPath = dataFolder.path(percentEncoded: false)
        initParams.dataPath = hasData ? dataFolderPath : ""
        
        if let pkgPath {
            do {
                let path = pkgPath.path(percentEncoded: false)
                if !FileManager.default.fileExists(atPath: path) {
                    try FileManager.default.createDirectory(at: pkgPath, withIntermediateDirectories: true)
                }
                initParams.pkgPath = path
            } catch {
                Log.error("Can't create folder for package data")
            }
        }
        
        initParams.logger = self
        
        RHVoiceBridge.sharedInstance().params = initParams

        activatePlaybackMode()
        synthesizer.delegate = self
        updateEngineAndSystem()
    }

    func playInstalledSample(voice: RHSpeechSynthesisProviderVoice?, demo: String) {
        stopPlaying()
        setAudioSession(active: true)

        guard let voice else {
            Log.error("Trying to play installed sample for not installed voice. Exiting")
            return
        }
        
#if USE_RHVOICE_SYNTHESIZER
        let utterance = RHSpeechUtterance(text: demo)
        utterance.set(voice:
                        RHSpeechSynthesisVoice.speechVoices().first(where: { rhVoice in
            return rhVoice.name == voice.name
        }))
#else
        guard let avVoice = avVoice(for: voice.identifier) else {
            Log.error("Can not find proper voice. Exiting")
            Task {
                Log.debug("Attempting to update engine and system")
                await updateEngineAndSystemAsync()
                await AppManager.shared.audioUnit.play(text: demo, voice: voice.name)
                stopPlaying()
            }
            return
        }

        let utterance = AVSpeechUtterance(string: demo)
        utterance.voice = avVoice
 #endif
        synthesizer.speak(utterance)
    }
    
    func playNotInstalledSample(voice: Voice) {
        stopPlaying()
        setAudioSession(active: true)
        
        guard let url = URL(string: voice.demoUrl) else {
            Log.error("Can not play sample for voice:\(voice.name) because can not construct URL object")
            return
        }
        
        let item = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEndTime(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        audioPlayer = AVPlayer(playerItem: item)
        audioPlayer?.volume = 1.0
        audioPlayer?.play()
    }
    func updateLanguagesAndVoices(languages: [Language]) async {
        
        for language in languages {
            if !language.isInstalled {
                continue
            }
            
            if language.hasUpdate {
                await update(language: language)
            }
            
            for voice in language.voices where voice.hasUpdate {
                await update(voice: voice, for: language)
            }
        }
    }
    
    func update(voice: Voice, for language: Language) async {
        Log.debug("Updating Voice:\(String(describing: voice.currentFolderName))")
        await remove(voice: voice, with: language)
        await download(voice: voice, for: language)
        Log.debug("Updated Voice:\(voice.newFolderName)")
        await updateEngineAndSystemAsync()
    }
    
    func update(language: Language) async {
        Log.debug("Updated Language:\(language.newFolderName)")
        await remove(language: language)
        await download(language: language)
        Log.debug("Updating Language:\(String(describing: language.currentFolderName))")
        await updateEngineAndSystemAsync()
    }
    
    func download(voice: Voice, for language: Language? = nil, shouldApperInSystem: Bool = true) async {
        if let language {
            await downloadIfNeeded(language: language)
        }
        
        await download(languageSwitchingProfiles: voice.switchingProfiles)
        
        Log.debug("Downloading Voice:\(voice.newFolderName)")
        await apiConnector?.download(voice: voice, unzipTo: voicesFolder)
        Log.debug("Downloaded Voice:\(voice.newFolderName)")
        
        await updateEngineAndSystemAsync()

        SettingsStore.shared.setInitialSetting(for: voice)
    }
    
    func download(language: Language) async {
        Log.debug("Downloading Language:\(language.newFolderName)")
        await apiConnector?.download(language: language, unzipTo: languagesFolder)
        Log.debug("Downloaded Language:\(language.newFolderName)")
    }
    
    func download(languageSwitchingProfiles: [LanguageSwitchingProfile]) async {
        for profile in languageSwitchingProfiles {
            Log.debug("Downloading Profile:\(profile.profile ?? "no name")")
            for voice in profile.voices where !voice.isInstalled || voice.hasUpdate {
                await download(voice: voice, shouldApperInSystem: false)
            }
            for language in profile.languages where !language.isInstalled || language.hasUpdate {
                await downloadIfNeeded(language: language)
            }
            Log.debug("Downloaded Profile:\(profile.profile ?? "no name")")
        }
    }
    
    func downloadIfNeeded(language: Language) async {
        if !language.isInstalled {
            await download(language: language)
        } else if language.hasUpdate {
            await update(language: language)
        } else {
            Log.debug("Language(id:\(language.identifier)) is already installed. Do nothing. ")
        }
    }
    
    func remove(voice: Voice, with language: Language) async {
        
        if let installedLanguage = language.installedLanguage {
            if installedLanguage.voices.count == 1 {
                Log.debug("Removing language\(language.name) since it was last voice assotiated with it.")
                await remove(language: language)
            }
        }
        
        guard let folderName = voice.currentFolderName else {
            Log.error("Can not find folder for voice:\(voice.name). Nothing to remove. Exiting.")
            return
        }
        
        let voiceFolder = voicesFolder.appendingPathComponent(folderName)
        Log.debug("Removing Voice:\(folderName)")
        do {
            try FileManager.default.removeItem(at: voiceFolder)
        } catch {
            Log.error("Error happened during removing voice:\(error)")
        }
        await updateEngineAndSystemAsync()
    }
    
    func remove(language: Language) async {
        
        guard let folderName = language.currentFolderName else {
            Log.error("Can not find folder for language:\(language.name). Nothing to remove. Exiting.")
            return
        }
        
        Log.debug("Removing Language:\(folderName)")
        let languageFolder = languagesFolder.appendingPathComponent(folderName)
        do {
            try FileManager.default.removeItem(at: languageFolder)
        } catch {
            Log.error("Error happened during removing Language:\(error)")
        }
    }
}

extension RHVoiceManager {
    var voicesFolder: URL {
        return FileManager.voicesFolder(dataFolder)
    }
    
    var languagesFolder: URL {
        return FileManager.languagesFolder(dataFolder)
    }
    
    var hasData: Bool {
        do {
            let rootFolderContent = try FileManager.default.contentsOfDirectory(at: dataFolder, includingPropertiesForKeys: nil)
            for subfolder in rootFolderContent {
                let isFolder = try subfolder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
                if !isFolder {
                    continue
                }
                let subfolderContent = try FileManager.default.contentsOfDirectory(at: subfolder, includingPropertiesForKeys: nil)
                if !subfolderContent.isEmpty {
                    return true
                }
            }
        } catch {
            Log.error("Failed to get folder content. Assuming no data.")
        }
        return false
    }
    @MainActor
    func updateEngineAndSystemAsync() async {
        Log.debug("Updating Engine and System")
        RHVoiceBridge.sharedInstance().params.dataPath = hasData ? dataFolder.path(percentEncoded: false) : ""
        RHVoiceBridge.sharedInstance().recreateEngine()
        await updateSharedVoicesStore()
        notifySystemAboutVoiceNumberChange()
    }

    func updateEngineAndSystem() {
        Task { [weak self] in
            await self?.updateEngineAndSystemAsync()
        }
    }

    func updateSharedVoicesStore() async {
        if AppManager.isBundledMode {
            await updateSharedVoicesStoreForBundled()
            return
        }
        guard let languages = await apiConnector?.languages() else {
            return
        }
        let allVoices = RHSpeechSynthesisVoice.speechVoices()
        let speechVoices = allVoices.filter { voice in
            return languages.contains(where: {
                $0.code == voice.language.code
            })
        }
        let installedAVVoices = speechVoices.rhAVVoices
        
        SettingsStore.shared.supportedVoices = installedAVVoices
        AppManager.shared.audioUnit.installedVoices = installedAVVoices
        Log.info("Updated UserDefaults Voices store. New voice count:\(String(describing: AppManager.shared.audioUnit.installedVoices?.count))")
    }
    
    func notifySystemAboutVoiceNumberChange() {
        AVSpeechSynthesisProviderVoice.updateSpeechVoices()
    }

    @objc func playerItemDidPlayToEndTime(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        stopPlaying()
    }
    
    func stopPlaying() {
        audioPlayer?.pause()
        audioPlayer = nil
#if USE_RHVOICE_SYNTHESIZER
        synthesizer.stopAndCancel()
#else
        synthesizer.stopSpeaking(at: .immediate)
#endif
        setAudioSession(active: false)
    }
}
