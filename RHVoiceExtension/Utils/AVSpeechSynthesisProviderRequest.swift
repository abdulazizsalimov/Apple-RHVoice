//
//  AVSpeechSynthesisProviderRequest.swift
//  RHVoiceExtension
//
//  Created by Ihor Shevchuk on 12.10.2023.
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
import AVFAudio

extension AVSpeechSynthesisProviderRequest {

    private func replaceTextInSSML(_ input: String, oldText: String, newText: String) -> (String, Bool) {
        let oldSuffix = ">\(oldText)</prosody></speak>"
        let newSuffix = ">\(newText)</prosody></speak>"

        if input.hasSuffix(oldSuffix) {
            return (input.replacingOccurrences(of: oldSuffix, with: newSuffix), true)
        }

        return (input, false)
    }

    var rhVoiceSSML: String {

        for language in voice.primaryLanguages {
            if language.hasPrefix("en") || language.hasPrefix("pt") {
                return ssmlRepresentation
            }
        }

       let specialCharacterMapping = [
            "vertical line": "|",
            "question mark": "?",
            "period": ".",
            "comma": ",",
            "hyphen": "-",
            "slash": "/",
            "colon": ":",
            "semicolon": ";",
            "left paren": "(",
            "right paren": ")",
            "at": "@",
            "exclamation mark": "!",
            "modifier apostrophe": "'",
            "left square bracket": "[",
            "right square bracket": "]",
            "left brace": "{",
            "right brace": "}",
            "number sign": "#",
            "percent": "%",
            "caret": "^",
            "star": "*",
            "plus": "+",
            "equals": "=",
            "underscore": "_",
            "backslash": "\\",
            "tilde": "~",
            "less than": "&lt",
            "greater than": "&gt",
            "euro sign": "€",
            "dollar sign": "$",
            "pound sign": "£",
            "bullet": "•",
            "ampersand": "&amp",
            "quotation mark": "&quot",
            "apostrophe": "&apos"
        ]

        let ssml = ssmlRepresentation
        for (mame, char) in specialCharacterMapping {
            var suffix = ">\(mame)</prosody></speak>"
            let replacement = "><say-as interpret-as=\"characters\">\(char)</say-as></prosody></speak>"
            if ssml.hasSuffix(suffix) {
                return ssml.replacingOccurrences(of: suffix, with: replacement)
            }
            suffix = "> \(mame) </prosody></speak>"
            if ssml.hasSuffix(suffix) {
                return ssml.replacingOccurrences(of: suffix, with: replacement)
            }
        }

        if let language = voice.primaryLanguages.first?.components(separatedBy: "-").first {
            let originals = [
                "Text field",
                "symbols",
                "Search field",
                "numbers",
                "Heading",
                "Double tap to toggle setting.",
                "Dictate",
                "Button",
                "Back button",
                "Switch button",
                "Actions available",
                "Double tap to edit."
            ]

            for original in originals {
                let replcement = original.localized(lang: language)
                let (replacedString, wasReplaced) = replaceTextInSSML(ssml, oldText: original, newText: replcement)
                if wasReplaced {
                    return replacedString
                }
            }
        }

        return ssmlRepresentation
    }
}
