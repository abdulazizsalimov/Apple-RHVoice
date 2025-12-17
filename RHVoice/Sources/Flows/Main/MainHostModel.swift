//
//  MainHostModel.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 12.09.2022.
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

import SwiftUI

class MainHostModel: ObservableObject, @unchecked Sendable {
    @Published private(set) var viewModel: MainViewModel

    init() {
        self.viewModel = MainViewModel()
        updateLanguages()
    }

    func updateLanguages() {
        Log.debug("Updating languages list")
        let isLanguageListEmpty = viewModel.languages == nil || viewModel.languages?.isEmpty == true
        self.viewModel.showLoadingIndicator = isLanguageListEmpty
        AppManager.shared.taskSerializer.run { [weak self] in

            let languages = await AppManager.shared.voiceManager.getLanguagesAndUpdate()
            await MainActor.run { [weak self] in
                guard let self else { return }
                let languagesToSet = languages.canBeShownOnUI
                if languages != self.viewModel.languages {
                    self.viewModel.languages = languagesToSet
                    self.viewModel.showLoadingIndicator = false
                }
            }
        }
    }
}

extension Array where Element: Language {
    var canBeShownOnUI: [Language] {
        return filter({ lng in
            return !lng.voices.isEmpty
        })
    }
}
