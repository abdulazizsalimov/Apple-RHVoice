//
//  CShortTests.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 06.05.2023.
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

final class CShortTests: XCTestCase {
    func testToFloat() {
        XCTAssertEqual(NSNumber(value: 0).int16Value.toFloat(), 0)
        XCTAssertEqual(NSNumber(value: 32767).int16Value.toFloat(), 0.9999695)
        XCTAssertEqual(NSNumber(value: -32767).int16Value.toFloat(), -0.9999695)
        XCTAssertEqual(NSNumber(value: 20).int16Value.toFloat(), 0.00061035156)
        XCTAssertEqual(NSNumber(value: -20).int16Value.toFloat(), -0.00061035156)
        XCTAssertEqual(NSNumber(value: 259).int16Value.toFloat(), 0.007904053)
        XCTAssertEqual(NSNumber(value: -259).int16Value.toFloat(), -0.007904053)
    }
}
