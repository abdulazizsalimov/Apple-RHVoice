//
//  RHSpeechUtteranceQuality.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 20.11.2022.
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

extension RHSpeechUtteranceQuality {
    static var allCases: [RHSpeechUtteranceQuality] {
        return [RHSpeechUtteranceQualityStandart,
                RHSpeechUtteranceQualityMax]
    }
    
    var string: String {
        switch self {
        case RHSpeechUtteranceQualityStandart:
            return String.localized("string-array.quality_labels.item_0",
                                    comment: "Minimum quality description string")
        case RHSpeechUtteranceQualityMax:
            return String.localized("string-array.quality_labels.item_2",
                                    comment: "Maximum quality description string")
        default:
            return ""
        }
    }
    
    var shortString: String {
        switch self {
        case RHSpeechUtteranceQualityStandart:
            return String.localized("string-array.ios_quality_labels_short.item.performance",
                                     comment: "Minimum quality short description string")
        case RHSpeechUtteranceQualityMax:
            return String.localized("string-array.ios_quality_labels_short.item.quality",
                                    comment: "Maximum quality short description string")
        default:
            return ""
        }
    }
}

extension RHSpeechUtteranceQuality: @retroactive Identifiable {
    public var id: Int {
        return self.rawValue
    }
}

extension RHSpeechUtteranceQuality: @retroactive Hashable {

 }
