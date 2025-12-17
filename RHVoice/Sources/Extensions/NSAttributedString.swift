//
//  NSAttributedString.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 31.10.2022.
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
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
typealias RHFont = UIFont
typealias RHColor = UIColor
typealias RHFontDescriptor = UIFontDescriptor
#elseif os(macOS)
typealias RHFont = NSFont
typealias RHColor = NSColor
typealias RHFontDescriptor = NSFontDescriptor
#endif

extension NSAttributedString {
#if os(iOS)
    static let defaultTextColor: RHColor = UIColor.label
#elseif os(macOS)
    static let defaultTextColor: RHColor = NSColor.labelColor
#endif
    convenience init?(html: String,
                      font: RHFont? = nil,
                      textAlignment: NSTextAlignment = .center,
                      textColor: RHColor = NSAttributedString.defaultTextColor) {
        let fontInternal = font ?? RHFont.systemFont(ofSize: 16)

        let inputText = "<html><head><style>body {\(fontInternal.css) text-align: \(textAlignment.css); color:\(textColor.css)}</style></head><body>\(html)</body></html>"

        guard let htmlData = inputText.data(using: .utf8) else {
            Log.error("Can not create Data object from HTML string.")
            return nil
        }

        try? self.init(data: htmlData,
                       options: [.documentType: NSAttributedString.DocumentType.html,
                                 .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
                       ], documentAttributes: nil)
    }
}

fileprivate extension NSTextAlignment {
    var css: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        case .justified:
            return"justify"
        case .natural:
            return "match-parent"
        default:
            return "center"
        }
    }
}

fileprivate extension RHFont {

    private static let AppleSystemFamilyName = ".AppleSystemUIFont"

    var css: String {
        return "font-family:\(cssFontFamily); font-size:\(pointSize)px; font-weight:\(weight);"
    }

    private var cssFontFamily: String {
        if familyName == RHFont.AppleSystemFamilyName {
            return "-apple-system"
        }
#if os(iOS)
        return familyName
#elseif os(macOS)
        return familyName ?? ""
#endif
    }

    private var weight: String {
        
        let defaultStringWeight = "normal"
        guard let weightNumber = traits[.weight] as? NSNumber else {
            Log.error("Font weight number wasn't found. Returning default value:\(defaultStringWeight)")
            return defaultStringWeight
        }

        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = RHFont.Weight(rawValue: weightRawValue)

        switch weight {

        case .ultraLight:
            return "100"
        case .thin:
            return "200"
        case .light:
            return "300"
        case .medium:
            return "500"
        case .semibold:
            return "600"
        case .bold:
            return "bold"
        case .heavy:
            return "800"
        case .black:
            return "900"
        case .regular:
            return "normal"
        default:
            Log.error("Font weight(\(weight)) is not supported. Returning default value:\(defaultStringWeight)")
            return defaultStringWeight
        }
    }

    private var traits: [RHFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [RHFontDescriptor.TraitKey: Any]
        ?? [:]
    }
 }

fileprivate extension RHColor {
    var css: String {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

#if os(iOS)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
#elseif os(macOS)
        if let convertedColor = usingColorSpace(.deviceRGB) {
            convertedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
#endif
        
        return "rgba(\(Int(255 * red)), \(Int(255 * green)), \(Int(255 * blue)), \(alpha));"
    }
}
