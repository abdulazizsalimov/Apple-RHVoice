//
//  Version.swift
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
import RHVoice

extension Version {
    var string: String {
        return String(major) + "." + String(minor)
    }
}

extension Version: Equatable {
    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major &&
               lhs.minor == rhs.minor
    }
}

protocol Versionable {
    var hasUpdate: Bool { get }
    var installedVersion: Version? { get }
    /// Version from JSON
    var version: Version { get }
}

extension Versionable {
    var hasUpdate: Bool {
        guard let installedVersion else {
            return false
        }

        return version != installedVersion
    }
}

protocol VersionableResourse: Versionable {
    static var resourseType: String { get }
    var newFolderName: String { get }
    var currentFolderName: String? { get }
    var countryCode: String { get }
    var name: String { get }
    var isInstalled: Bool { get }
}

extension VersionableResourse {
    var currentFolderName: String? {
        guard let installedVersion else {
            Log.error("Version for installed \(Self.resourseType) is not found")
            return nil
        }

        return folderName(version: installedVersion)
    }

    var newFolderName: String {
        return folderName(version: version)
    }

    private func folderName(version: Version) -> String {
        return Self.resourseType + "-" + countryCode + "-" + name + "-" + "v" + version.string
    }

    var isInstalled: Bool {
        return installedVersion != nil
    }
}
