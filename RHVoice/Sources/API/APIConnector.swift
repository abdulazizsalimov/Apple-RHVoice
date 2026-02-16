//
//  APIConnector.swift
//  RHVoice
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
import ZIPFoundation

actor APIConnector {
    func downloadFile(url: URL?, unzipTo: URL) async {
        guard let url = url else {
            Log.error("Can't start downloading with nil url")
            return
        }
        
        do {
            let (localURL, _) = try await URLSession.shared.download(from: url)
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: unzipTo)
            } catch {
                Log.debug("Error happened during removing: \(error)")
            }
            try fileManager.createDirectory(at: unzipTo, withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.none])
            try fileManager.unzipItem(at: localURL, to: unzipTo)
            try fileManager.removeItem(at: localURL)
        } catch {
            Log.error("Error happened during downloading and unziping: \(error)")
        }
    }
    
    func copyCACertIfNeeded() {
#if !os(macOS)
        struct Token {
            static let once: Void = {
                let certFileName = "cacert.pem"
                let fileManager = FileManager.default
                let packagePath = RHVoiceBridge.sharedInstance().params.pkgPath
                let destinationCertPath: String = packagePath.appending("/\(certFileName)")
                
                if !fileManager.fileExists(atPath: destinationCertPath) {
                    if let caPath = Bundle.main.path(forResource: certFileName, ofType: "") {
                        do {
                            try fileManager.copyItem(atPath: caPath, toPath: destinationCertPath)
                        } catch {
                            Log.error("Error happened during copying CA: \(error)")
                        }
                    }
                }
            }()
        }
        _ = Token.once
#endif
    }

}

extension APIConnector: APIConnectorInterface {
    
    func languages() async -> [Language] {
        copyCACertIfNeeded()
        let packages = RHVoiceApiBridge.package
        return packages?.languages ?? []
    }
    
    func download(voice: Voice, unzipTo: URL) async {
        copyCACertIfNeeded()
        await downloadFile(url: URL(string: voice.dataUrl), unzipTo: unzipTo.appendingPathComponent(voice.newFolderName))
    }
    
    func download(language: Language, unzipTo: URL) async {
        copyCACertIfNeeded()
        await downloadFile(url: URL(string: language.dataUrl), unzipTo: unzipTo.appendingPathComponent(language.newFolderName))
    }
}

actor BundledAPIConnector: APIConnectorInterface {

    private static let testMessages: [String: String] = [
        "ru": "Если вы слышите это сообщение, значит голос установлен и работает.",
        "en": "If you can hear this message, then the voice is installed and working.",
        "uk": "Якщо ви чуєте це повідомлення, голос встановлено і він працює.",
        "be": "Калі вы чуеце гэта паведамленне, голас усталяваны і працуе.",
        "uz": "Agar siz bu xabarni eshitayotgan bo'lsangiz, ovoz o'rnatilgan va ishlayapti.",
        "pl": "Jeśli słyszysz tę wiadomość, głos jest zainstalowany i działa.",
        "cs": "Pokud slyšíte tuto zprávu, hlas je nainstalován a funguje.",
        "sk": "Ak počujete túto správu, hlas je nainštalovaný a funguje.",
        "hr": "Ako čujete ovu poruku, glas je instaliran i radi.",
        "sq": "Nëse e dëgjoni këtë mesazh, zëri është instaluar dhe po punon.",
        "mk": "Ако ја слушате оваа порака, гласот е инсталиран и работи.",
        "ka": "თუ ამ შეტყობინებას გესმით, ხმა დაინსტალირებულია და მუშაობს.",
        "ky": "Эгер сиз бул кабарды угуп жатсаңыз, үн орнотулган жана иштеп жатат.",
        "tt": "Әгәр сез бу хәбәрне ишетсәгез, тавыш урнаштырылган һәм эшли.",
        "pt": "Se você pode ouvir esta mensagem, a voz está instalada e funcionando.",
        "eo": "Se vi povas aŭdi ĉi tiun mesaĝon, la voĉo estas instalita kaj funkcias.",
        "lb": "Wann Dir dës Noriicht héiert, ass d'Stëmm installéiert a funktionéiert.",
        "tr": "Bu mesajı duyabiliyorsanız, ses yüklenmiş ve çalışıyor demektir.",
        "bg": "Ако чувате това съобщение, гласът е инсталиран и работи.",
        "mn": "Хэрэв та энэ мессежийг сонсож байвал дуу хоолой суулгагдсан бөгөөд ажиллаж байна.",
        "fa": "اگر این پیام را می‌شنوید، صدا نصب شده و کار می‌کند."
    ]

    func languages() async -> [Language] {
        let engineLanguages = RHVoiceBridge.sharedInstance().languages() as? [RHLanguage] ?? []
        return engineLanguages.compactMap { rhLang -> Language? in
            let langCode = rhLang.code ?? ""
            guard !langCode.isEmpty else { return nil }

            let rhVoices = rhLang.voices as? [RHSpeechSynthesisVoice] ?? []
            let voices: [Voice] = rhVoices.map { rhVoice in
                let langCodeFull = rhVoice.languageCode ?? ""
                let ctry2code: String
                if langCodeFull.contains("-") {
                    ctry2code = String(langCodeFull.split(separator: "-").last ?? "")
                } else {
                    ctry2code = ""
                }
                let voiceVersion: Version
                if let vInfo = rhVoice.version {
                    voiceVersion = vInfo.modelVersion
                } else {
                    voiceVersion = Version(major: 1, minor: 0)
                }
                return Voice(
                    name: rhVoice.name,
                    ctry2code: ctry2code,
                    demoUrl: "",
                    version: voiceVersion,
                    dataUrl: "",
                    id: rhVoice.identifier
                )
            }

            let langVersion: Version
            if let vInfo = rhLang.version {
                langVersion = vInfo.modelVersion
            } else {
                langVersion = Version(major: 1, minor: 0)
            }

            let testMessage = BundledAPIConnector.testMessages[langCode] ?? "Test"

            return Language(
                code: langCode,
                testMessage: testMessage,
                name: rhLang.country ?? langCode,
                version: langVersion,
                voices: voices,
                dataUrl: "",
                dataMd5: "",
                identifier: langCode
            )
        }
    }

    func download(voice: Voice, unzipTo: URL) async {}
    func download(language: Language, unzipTo: URL) async {}
}
