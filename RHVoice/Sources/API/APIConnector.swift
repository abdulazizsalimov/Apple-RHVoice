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
