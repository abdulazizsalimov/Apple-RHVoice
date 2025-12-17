//
//  LicensesHostModel.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 05.01.2023.
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
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class LicensesHostModel: ObservableObject {
    @Published var viewModel: LicensesViewModel
    
    private let dependciesNames = ["RHVoice",
                                   "HTS",
                                   "Boost",
                                   "curl",
                                   "OpenSSL",
                                   "nghttp2",
                                   "ZIPFoundation"]
    
    init() {
        
        var licenses = [LicenseInfo]()
        
        for dependency in dependciesNames {
            guard let data = NSDataAsset(name: "license-\(dependency.lowercased())") else {
                Log.error("Missed data asset for dependency(\(dependency))")
                continue
            }
            
            guard let licenseText = String(data: data.data, encoding: .utf8) else {
                Log.error("Cannot convert data to string for dependency(\(dependency))")
                continue
            }
            
            licenses.append(LicenseInfo(name: dependency, content: licenseText))
        }
        
        viewModel = LicensesViewModel(licenses: licenses)
    }
}
