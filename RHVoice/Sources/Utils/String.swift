//
//  String.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 09.12.2022.
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

extension String {
    
     static func localized(_ key: String.LocalizationValue, comment: StaticString? = nil, arguments: [CVarArg] = []) -> String {
         
         let format = String(localized: key, comment: comment)
         
         if LocalizationValue(format) == key {
             if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
                let bundle = Bundle(path: path) {
                 return String(localized: key, bundle: bundle)
             }
         }
         
         if arguments.isEmpty {
             return format
         }
         
         return String(format: format, arguments)
    }
    
    var localized: String {
        String.localized(String.LocalizationValue(self))
    }
    
    var audioComponentOSType: OSType {
        if self.count != 4 {
            Log.error("Invalid audio component length: \(self)")
            return 0
        }

        var result: OSType = 0
        for char in self.utf8 {
            result = (result << 8) + OSType(char)
        }
        return result
    }
}
