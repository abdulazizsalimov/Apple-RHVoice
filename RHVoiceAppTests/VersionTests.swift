//
//  VersionTests.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 08.01.2023.
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

@testable import RHVoiceApp

struct VersionableMock: Versionable {
    var version: Version
    var installedVersion: Version?
}

final class VersionTests: XCTestCase {

    func testString() throws {
        XCTAssertEqual(Version(major: 1, minor: 0).string, "1.0")
        XCTAssertEqual(Version(major: 2, minor: 1).string, "2.1")
        XCTAssertEqual(Version(major: 1, minor: 2).string, "1.2")
        XCTAssertEqual(Version(major: 2, minor: 0).string, "2.0")
    }

    func testEqual() throws {
        XCTAssertEqual(Version(major: 1, minor: 0), Version(major: 1, minor: 0))
        XCTAssertEqual(Version(major: 2, minor: 0), Version(major: 2, minor: 0))
        XCTAssertEqual(Version(major: 2, minor: 1), Version(major: 2, minor: 1))
        
        XCTAssertNotEqual(Version(major: 2, minor: 1), Version(major: 1, minor: 1))
        XCTAssertNotEqual(Version(major: 2, minor: 0), Version(major: 1, minor: 0))
    }

    func testHasUpdate() throws {
        var systemUnderTest = VersionableMock(version: Version(major: 1, minor: 0), installedVersion: Version(major: 1, minor: 0))
        XCTAssertFalse(systemUnderTest.hasUpdate)
        systemUnderTest = VersionableMock(version: Version(major: 2, minor: 0), installedVersion: Version(major: 1, minor: 0))
        XCTAssertTrue(systemUnderTest.hasUpdate)
        systemUnderTest = VersionableMock(version: Version(major: 1, minor: 0), installedVersion: Version(major: 2, minor: 0))
        XCTAssertTrue(systemUnderTest.hasUpdate)
    }
}
