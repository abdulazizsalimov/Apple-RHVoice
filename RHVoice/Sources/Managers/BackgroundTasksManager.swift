//
//  BackgroundTasksManager.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 23.04.2023.
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
#if !os(macOS)
import BackgroundTasks
#endif

class BackgroundTasksManager {
    static let updateVoicesAndLanguagesTaskIdentifier = "com.RHVoice.update.voicesAndLanguages"
    static let updateVoicesInfoTaskIdentifier = "com.RHVoice.update.voicesInfoS"
    let taskSerializer = SerialTasks(name: "BackgroundTasks")
    
    func registerTasks() {
#if !os(macOS)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTasksManager.updateVoicesAndLanguagesTaskIdentifier,
            using: nil
        ) { task in
            AppManager.shared.taskSerializer.run {
                await AppManager.shared.backgroundTasks.handleUpdateTask()
                task.setTaskCompleted(success: true)
            }
        }
#endif
    }

    func scheduleUpdate() {
#if !os(macOS)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTasksManager.updateVoicesAndLanguagesTaskIdentifier)
        if !SettingsStore.shared.automaticUpdates {
            Log.info("Do not schedule background updates, because it was disabled by user.")
            return
        }
        scheduleTask(id: BackgroundTasksManager.updateVoicesAndLanguagesTaskIdentifier, earliestBegin: .updateVoicesEarliestBeginTimeInterval)
#endif
    }

    func handleUpdateTask() async {
        Log.debug("Updating application data in background. Begin.")
        if !SettingsStore.shared.automaticUpdates {
            Log.info("Do not do background updates, because it was disabled by user.")
            return
        }

        scheduleUpdate()
        await AppManager.shared.voiceManager.getLanguagesAndUpdate()
        Log.debug("Updating application data in background. Completed.")
    }

    private func scheduleTask(id: String, earliestBegin: TimeInterval) {
#if !os(macOS)
        Log.debug("Scheduling background data update. Begin.")
        defer {
            Log.debug("Scheduling background data update. End.")
        }
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: id)
        let request = BGAppRefreshTaskRequest(identifier: id)
        request.earliestBeginDate = .now.addingTimeInterval(earliestBegin)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Log.error("Error happened during scheduling background task: \(error)")
        }
#endif
    }
}
