//
//  ResourseInfo.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 01.05.2023.
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

struct ResourseInfo {
    var name: String
    var language: String
    var gender: String?
    var format: Int
    var revision: Int

    init?(filePath: String?) {
        guard let filePath else {
            return nil
        }

        guard let dictionary = parseFileToDictionary(filePath: filePath) else {
            return nil
        }

        name = dictionary["name"] ?? ""
        language = dictionary["language"] ?? ""
        gender = dictionary["gender"] ?? ""
        format = Int(dictionary["format"] ?? "0") ?? 0
        revision = Int(dictionary["revision"] ?? "0") ?? 0
    }

    func save(file: String?) throws {

        guard let file else {
            return
        }

        let contents = "name=\(self.name)\n" +
                       "language=\(self.language)\n" +
                       "gender=\(self.gender ?? "")\n" +
                       "format=\(self.format)\n" +
                       "revision=\(self.revision)\n"
        try contents.write(toFile: file, atomically: true, encoding: .utf8)
    }
}

func parseFileToDictionary(filePath: String) -> [String: String]? {
    guard let fileContents = try? String(contentsOfFile: filePath) else {
        return nil
    }

    let lines = fileContents.split(separator: "\n")

    var dictionary = [String: String]()

    for line in lines {
        let components = line.split(separator: "=")
        guard components.count == 2 else {
            continue
        }
        let key = String(components[0])
        let value = String(components[1])
        dictionary[key] = value
    }

    return dictionary
}
