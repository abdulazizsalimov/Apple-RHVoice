//
//  SerialTasks.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 18.09.2022.
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

class SerialTasks {

    private let operationQueue: OperationQueue

    init(name: String = "") {
        operationQueue = OperationQueue()
        operationQueue.name = name
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }

    func run(block: @escaping () async throws -> Void) {
        operationQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                defer {
                    semaphore.signal()
                }
                try await block()
            }
            semaphore.wait()
        }
    }
}
