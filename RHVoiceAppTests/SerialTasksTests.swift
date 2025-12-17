//
//  SerialTasksTests.swift
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

final class SerialTasksTests: XCTestCase {
    
    let systemUnderTest = SerialTasks(name: "Unit_Tests")

    func testOneTask() throws {
        let finishExp = expectation(description: "Task finished")
        systemUnderTest.run { [weak self] in
            await self?.task(duration: 1)
            finishExp.fulfill()
        }
        wait(for: [finishExp], timeout: 3)
    }
    
    func testMultipleTasks() throws {
        let numberOfTasks = 20
        
        let finishExp = expectation(description: "Init task finished")
        systemUnderTest.run { [weak self] in
            await self?.task(duration: 1)
            finishExp.fulfill()
        }
        
        let lastTaskExp = expectation(description: "Last task finished")
        var callNumber = 0
        for index in 1...numberOfTasks {
            systemUnderTest.run { [weak self] in
                await self?.task()
                callNumber += 1
                XCTAssertEqual(index, callNumber)
                if callNumber == numberOfTasks {
                    lastTaskExp.fulfill()
                }
            }
        }
        
        wait(for: [finishExp, lastTaskExp], timeout: 3)

        XCTAssertEqual(callNumber, numberOfTasks)
    }
    
    private func task(duration: TimeInterval = 0) async {
        var duration = duration
        while duration > 0 {
            sleep(1)
            duration -= 1
        }
    }
}
