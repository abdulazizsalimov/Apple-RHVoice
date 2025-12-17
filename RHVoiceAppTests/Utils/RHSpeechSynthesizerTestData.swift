//
//  RHSpeechSynthesizerTestData.swift
//  RHVoiceAppTests
//
//  Created by Ihor Shevchuk on 04.05.2023.
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

struct RHSpeechMarker {
    let mark: RHSpeechSynthesisMarkerMark
    let byteSampleOffset: UInt
    let textRange: NSRange
}

struct RHSpeechSynthesizerTestData {
    let text: String
    let markers: [RHSpeechMarker]
    
    static let data: [RHSpeechSynthesizerTestData] = [
        RHSpeechSynthesizerTestData(text: """
    The purpose of lorem ipsum is to create a natural looking block of text (sentence, paragraph, page, etc.) that doesn't distract from the layout.
    A practice not without controversy, laying out pages with meaningless filler text can be very useful when the focus is meant to be on design, not content.
    """, markers: [
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 105)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 2400, textRange: NSRange(location: 11, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 13440, textRange: NSRange(location: 19, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 16320, textRange: NSRange(location: 22, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 24000, textRange: NSRange(location: 28, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 31200, textRange: NSRange(location: 34, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 34560, textRange: NSRange(location: 37, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 37920, textRange: NSRange(location: 40, length: 6)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 48000, textRange: NSRange(location: 47, length: 1)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 49440, textRange: NSRange(location: 49, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 61440, textRange: NSRange(location: 57, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 70080, textRange: NSRange(location: 65, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 78240, textRange: NSRange(location: 71, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 81120, textRange: NSRange(location: 74, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 96000, textRange: NSRange(location: 79, length: 10)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 113280, textRange: NSRange(location: 90, length: 10)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 133440, textRange: NSRange(location: 101, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 145440, textRange: NSRange(location: 107, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 165840, textRange: NSRange(location: 113, length: 38)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 166800, textRange: NSRange(location: 113, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 170640, textRange: NSRange(location: 118, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 178320, textRange: NSRange(location: 126, length: 8)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 191280, textRange: NSRange(location: 135, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 196560, textRange: NSRange(location: 140, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 198480, textRange: NSRange(location: 144, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 216840, textRange: NSRange(location: 152, length: 154)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 217800, textRange: NSRange(location: 152, length: 1)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 219240, textRange: NSRange(location: 154, length: 8)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 231720, textRange: NSRange(location: 163, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 237480, textRange: NSRange(location: 167, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 248040, textRange: NSRange(location: 175, length: 12)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 268680, textRange: NSRange(location: 188, length: 6)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 276360, textRange: NSRange(location: 195, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 281640, textRange: NSRange(location: 199, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 292200, textRange: NSRange(location: 205, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 296520, textRange: NSRange(location: 210, length: 11)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 309000, textRange: NSRange(location: 222, length: 6)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 317160, textRange: NSRange(location: 229, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 327240, textRange: NSRange(location: 234, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 332040, textRange: NSRange(location: 238, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 335400, textRange: NSRange(location: 241, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 342120, textRange: NSRange(location: 246, length: 6)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 354120, textRange: NSRange(location: 253, length: 4)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 359400, textRange: NSRange(location: 258, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 361320, textRange: NSRange(location: 262, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 372840, textRange: NSRange(location: 268, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 376200, textRange: NSRange(location: 271, length: 5)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 382440, textRange: NSRange(location: 277, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 385320, textRange: NSRange(location: 280, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 389640, textRange: NSRange(location: 283, length: 2)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 393960, textRange: NSRange(location: 286, length: 7)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 409800, textRange: NSRange(location: 294, length: 3)),
        RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 415560, textRange: NSRange(location: 298, length: 8))

    ]),
        RHSpeechSynthesizerTestData(text: "This is a test message.", markers: [
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 23)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 5760, textRange: NSRange(location: 12, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 9120, textRange: NSRange(location: 15, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 10080, textRange: NSRange(location: 17, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 18240, textRange: NSRange(location: 22, length: 8))
        ]),
        RHSpeechSynthesizerTestData(text: "Eu consegui falar um pouco de português muitos, muitos anos atrás, quando visitei o Brasil por um mês. Mas hoje eu preciso usar o Google Tradutor.", markers: [
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 102)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 7200, textRange: NSRange(location: 10, length: 8)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 21600, textRange: NSRange(location: 19, length: 5)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 31200, textRange: NSRange(location: 25, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 34080, textRange: NSRange(location: 28, length: 5)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 40800, textRange: NSRange(location: 34, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 44160, textRange: NSRange(location: 37, length: 9)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 63360, textRange: NSRange(location: 47, length: 7)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 77760, textRange: NSRange(location: 55, length: 6)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 89280, textRange: NSRange(location: 62, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 98400, textRange: NSRange(location: 67, length: 6)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 112800, textRange: NSRange(location: 74, length: 6)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 124800, textRange: NSRange(location: 81, length: 7)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 140160, textRange: NSRange(location: 89, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 142560, textRange: NSRange(location: 91, length: 6)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 154080, textRange: NSRange(location: 98, length: 3)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 161280, textRange: NSRange(location: 102, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 163200, textRange: NSRange(location: 105, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 180960, textRange: NSRange(location: 110, length: 43)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 181920, textRange: NSRange(location: 110, length: 3)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 188160, textRange: NSRange(location: 114, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 194880, textRange: NSRange(location: 119, length: 2)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 201120, textRange: NSRange(location: 122, length: 7)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 215520, textRange: NSRange(location: 130, length: 4)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 226560, textRange: NSRange(location: 135, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 228480, textRange: NSRange(location: 137, length: 6)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 236640, textRange: NSRange(location: 144, length: 9))
        ]),
        RHSpeechSynthesizerTestData(text: "😆 😅 😂 🤣", markers: [
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 10)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 10, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 13, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 16, length: 1))
        ]),
        RHSpeechSynthesizerTestData(text: "😆", markers: [
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 1))
        ]),
        RHSpeechSynthesizerTestData(text: "Test:😆", markers: [
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 0, textRange: NSRange(location: 7, length: 5)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 960, textRange: NSRange(location: 7, length: 5)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkSentence, byteSampleOffset: 18960, textRange: NSRange(location: 12, length: 1)),
            RHSpeechMarker(mark: RHSpeechSynthesisMarkerMarkWord, byteSampleOffset: 19920, textRange: NSRange(location: 12, length: 1))])
    ]
}
