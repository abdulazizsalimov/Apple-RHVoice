//
//  APIConnectorMock.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 30.04.2023.
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

import XCTest
import Foundation

import RHVoice
@testable import RHVoiceApp

class APIConnectorMock: NSObject {

    private struct JSONFormat: Decodable {
        let languages: [String]
        let voices: [String]
    }

    static let shared = APIConnectorMock()

    private var availableLanguages: [Language] {

        guard let path = bundle.path(forResource: "RHVoice-config", ofType: "json") else {
            Log.error(type: .tests, "Missing RHVoice-config.json. Returning empty array")
            return []
        }

        do {
            let jsonData = try Data(contentsOf: URL(filePath: path))
            let jsonInfo = try JSONDecoder().decode(JSONFormat.self, from: jsonData)

            let voices = jsonInfo.voices.map { voiceName in

                let info = voiceResourseInfo(for: voiceName)
                let version = info?.version ?? Version(major: 0, minor: 0)

                return Voice(name: voiceName, ctry2code: "en", demoUrl: "", version: version, dataUrl: "", id: voiceName)
            }
            
            let languages = jsonInfo.languages.map { languageName in

                let info = languageResourseInfo(for: languageName)
                let version = info?.version ?? Version(major: 0, minor: 0)

                return Language(code: "en", testMessage: "", name: languageName, version: version, voices: voices, dataUrl: "", dataMd5: "", identifier: languageName)
            }

            return languages
        } catch {
            Log.error(type: .tests, "Error happened during parsing RHVoice-config.json file: \(error)")
        }

        return []
    }

    private var rhVoiceDataFolder: String? {
        return bundle.path(forResource: Constans.RHVoiceDataFolderName, ofType: nil)
    }

    private var voicesFolder: String? {
        return rhVoiceDataFolder?.appending("/voices")
    }

    private var languagesFolder: String? {
        return rhVoiceDataFolder?.appending("/languages")
    }

    private var bundle: Bundle {
        return Bundle(for: APIConnectorMock.self)
    }

    private func copy(voice: Voice, to url: URL, with name: String) throws {
        let originPath = voicesFolder?.appending("/\(voice.name)")
        try copy(folder: URL(fileURLWithPath: originPath ?? ""), to: url, with: name)
    }

    private func copy(language: Language, to url: URL, with name: String) throws {
        let originPath = languagesFolder?.appending("/\(language.name)")
        try copy(folder: URL(fileURLWithPath: originPath ?? ""), to: url, with: name)
    }

    private func copy(folder: URL?, to url: URL, with name: String) throws {
        guard let folder else {
            throw NSError(domain: "Tests", code: 404)
        }

        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
        }

        try FileManager.default.copyItem(at: folder, to: url.appending(path: folder.lastPathComponent))

        do {
            try FileManager.default.removeItem(at: url.appending(path: name))
        } catch {
        }

        try FileManager.default.moveItem(at: url.appending(path: folder.lastPathComponent), to: url.appending(path: name))
    }

    func set(version: Version, for voice: Voice) throws {
        guard var info = voiceResourseInfo(for: voice.name) else {
            throw XCTestCase.UnitTestErrors.VersionUpdateFailed
        }

        info.format = version.major
        info.revision = version.minor
        do {
            try info.save(file: voiceInfoFilePath(for: voice.name))
        } catch {
            Log.error(type: .tests, "Error happened during writing file: \(error)")
            throw XCTestCase.UnitTestErrors.VersionUpdateFailed
        }
    }

    private func voiceResourseInfo(for voiceName: String) -> ResourseInfo? {
        return ResourseInfo(filePath: voiceInfoFilePath(for: voiceName))
    }

    private func voiceInfoFilePath(for voiceName: String) -> String? {
        return voicesFolder?.appending("/" + voiceName + "/voice.info")
    }

    private func languageInfoFilePath(for languageName: String) -> String? {
        return languagesFolder?.appending("/" + languageName + "/language.info")
    }

    private func languageResourseInfo(for languageName: String) -> ResourseInfo? {
        return ResourseInfo(filePath: languageInfoFilePath(for: languageName))
    }

    func set(version: Version, for language: Language) throws {
        guard var info = languageResourseInfo(for: language.name) else {
            throw XCTestCase.UnitTestErrors.VersionUpdateFailed
        }

        info.format = version.major
        info.revision = version.minor
        do {
            try info.save(file: languageInfoFilePath(for: language.name))
        } catch {
            Log.error(type: .tests, "Error happened during writing file: \(error)")
            throw XCTestCase.UnitTestErrors.VersionUpdateFailed
        }
    }

    private func resourseInfo(for voiceName: String) -> ResourseInfo? {
        return ResourseInfo(filePath: voiceInfoFilePath(for: voiceName))
    }
}

extension APIConnectorMock: APIConnectorInterface {
    func languages() async -> [Language] {
        return availableLanguages
    }

    func download(voice: Voice, unzipTo: URL) async {
        do {
            try copy(voice: voice, to: unzipTo, with: voice.newFolderName)
        } catch {
            Log.error(type: .tests, "Error happened during 'installing' voice: \(error)")
        }
    }

    func download(language: Language, unzipTo: URL) async {
        do {
            try copy(language: language, to: unzipTo, with: language.newFolderName)
        } catch {
            Log.error(type: .tests, "Error happened during 'installing' language: \(error)")
        }
    }
}

fileprivate extension ResourseInfo {
    var version: Version {
        return Version(major: format, minor: revision)
    }
}
