// swift-tools-version: 5.7

//  Created by Ihor Shevchuk on 9/12/23.
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

import Foundation
import PackageDescription

let version = versionString(fileName: "SConstruct")

var commonDefines: [CSetting] = [
    .define("MAX_RATE", to: "3"),
    .define("RHVOICE"),
    .define("PACKAGE", to: "\"RHVoice\""),
    .define("ENABLE_PKG"),
    .define("DATA_PATH", to: ""),
    .define("CONFIG_PATH", to: ""),
    .unsafeFlags(["-Wno-enum-constexpr-conversion"]),
    .define("TARGET_OS_IPHONE", .when(platforms: [.iOS, .macCatalyst])),
    /// This is needed to pass root certificate to fix loading of JSON
    .define("ANDROID", .when(platforms: [.iOS, .macCatalyst])),
    .define("TARGET_OS_MAC", .when(platforms: [.macOS])),
    /// TODO: Update package URL
    .define("PKG_DIR_URL", to: "\"https://s2.nonroutine.com/apple.json\"")
]

func boostHeadersPaths() -> [String] {
    return [
        "external/libs/boost/libs/nowide/include",
        "external/libs/boost/libs/move/include",
        "external/libs/boost/libs/core/include",
        "external/libs/boost/libs/tuple/include",
        "external/libs/boost/libs/config/include",
        "external/libs/boost/libs/array/include",
        "external/libs/boost/libs/unordered/include",
        "external/libs/boost/libs/smart_ptr/include",
        "external/libs/boost/libs/tokenizer/include",
        "external/libs/boost/libs/interprocess/include",
        "external/libs/boost/libs/type_traits/include",
        "external/libs/boost/libs/io/include",
        "external/libs/boost/libs/container_hash/include",
        "external/libs/boost/libs/function/include",
        "external/libs/boost/libs/algorithm/include",
        "external/libs/boost/libs/numeric_conversion/include",
        "external/libs/boost/libs/assert/include",
        "external/libs/boost/libs/date_time/include",
        "external/libs/boost/libs/optional/include",
        "external/libs/boost/libs/container/include",
        "external/libs/boost/libs/system/include",
        "external/libs/boost/libs/concept_check/include",
        "external/libs/boost/libs/variant2/include",
        "external/libs/boost/libs/align/include",
        "external/libs/boost/libs/iterator/include",
        "external/libs/boost/libs/detail/include",
        "external/libs/boost/libs/mp11/include",
        "external/libs/boost/libs/intrusive/include",
        "external/libs/boost/libs/json/include",
        "external/libs/boost/libs/static_assert/include",
        "external/libs/boost/libs/mpl/include",
        "external/libs/boost/libs/mpl/preprocessed/include",
        "external/libs/boost/libs/winapi/include",
        "external/libs/boost/libs/integer/include",
        "external/libs/boost/libs/predef/include",
        "external/libs/boost/libs/range/include",
        "external/libs/boost/libs/bind/include",
        "external/libs/boost/libs/exception/include",
        "external/libs/boost/libs/preprocessor/include",
        "external/libs/boost/libs/throw_exception/include",
        "external/libs/boost/libs/type_index/include",
        "external/libs/boost/libs/lexical_cast/include",
        "external/libs/boost/libs/utility/include"
    ]
}

func boostHeaders(prefix: String = "") -> [CSetting] {
    return boostHeadersPaths().map { path in
        return .headerSearchPath(prefix + path)
    }
}

func commonHeaderSearchPath(prefix: String = "") -> [CSetting] {
    let headerPaths = [
        "src/third-party/utf8",
        "src/third-party/rapidxml",
        "src/include",
        "src/hts_engine"
    ]

    return headerPaths.map { path in
        return .headerSearchPath(prefix + path)
    }
}

func commonCSettings(prefix: String = "") -> [CSetting] {
    return boostHeaders(prefix: prefix)
    + commonHeaderSearchPath(prefix: prefix)
    + commonDefines
}

let package = Package(
    name: "RHVoice",
    platforms: [
        .macOS(.v11),
        .macCatalyst(.v13),
        .iOS(.v13)],
    products: [
        .library(
            name: "RHVoice",
            targets: ["RHVoice",
                     "RHVoice_dependencies"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RHVoiceCore",
            dependencies: [
            ],
            path: "Core",
            exclude: [
                // Files that are not compiled because they are included into sources directly
                "src/core/unidata.cpp",
                "src/core/userdict_parser.c",
                "src/core/emoji_data.cpp",
                // Platform audio files that shouldn't be compiled for iOS and macOS(at least in scope of this package)
                "src/audio/libao.cpp",
                "src/audio/portaudio.cpp",
                "src/audio/pulse.cpp",
                // cmake files
                "src/core/CMakeLists.txt",
                "src/hts_engine/CMakeLists.txt",
                "src/audio/CMakeLists.txt",
                "src/lib/CMakeLists.txt",
                // Scons files
                "src/audio/SConscript",
                "src/core/SConscript",
                "src/hts_engine/SConscript",
                "src/lib/SConscript",
                "src/pkg/SConscript",
                // Not used on Apple platfroms since config path is set during runtime
                "src/core/config.h.in",
                // Not used on Apple platforms
                "src/core/userdict_parser.g"
            ],
            sources: [
                "src/core",
                "src/hts_engine",
                "src/pkg",
                "src/lib",
                "src/audio"
            ],
            publicHeadersPath: "src/include/",
            cSettings: [
                .headerSearchPath("../Bridge/Mock"),
                .define("VERSION", to: "\(version)")
            ] + commonCSettings(prefix: "")
        ),
        .binaryTarget(
            name: "libcurl",
            url: "https://github.com/IhorShevchuk/Build-OpenSSL-cURL/releases/download/8.0.1/libcurl.xcframework.zip",
            checksum: "ca6db5983531dd0daf88077fb090b5b543c622264c97bdf269d06cdb99f13433"
        ),
        .binaryTarget(
            name: "libcrypto",
            url: "https://github.com/IhorShevchuk/Build-OpenSSL-cURL/releases/download/8.0.1/libcrypto.xcframework.zip",
            checksum: "6d4a105f591a32453726fc68f0e18b9a8050e9e051a3b5a01bfcf3e072414ed2"
        ),
        .binaryTarget(
            name: "libnghttp2",
            url: "https://github.com/IhorShevchuk/Build-OpenSSL-cURL/releases/download/8.0.1/libnghttp2.xcframework.zip",
            checksum: "a14509e7638174a1d55127bd6860424fc96bab388184ceb1228450d2bc21819d"
        ),
        .binaryTarget(
            name: "libssl",
            url: "https://github.com/IhorShevchuk/Build-OpenSSL-cURL/releases/download/8.0.1/libssl.xcframework.zip",
            checksum: "eaa778c6241bb4662e57b7d63b9d647ec891e86b078e3716a478f392e28176bc"
        ),
        .target(name: "RHVoice",
                dependencies: [
                    .target(name: "RHVoiceCore")
                ],
                path: "Bridge",
                sources: [
                    "CoreLib",
                    "RHVoice",
                    "Utils"
                ],
                publicHeadersPath: "RHVoice/PublicHeaders/",
                cSettings: [
                    .headerSearchPath("RHVoice/Logger"),
                    .headerSearchPath("RHVoice/PrivateHeaders"),
                    .headerSearchPath("Utils"),
                    .headerSearchPath("CoreLib"),
                    .headerSearchPath("Mock")
                ] + commonCSettings(prefix: "../Core/"),
                linkerSettings: [
                    .linkedFramework("AVFoundation"),
                    .linkedLibrary("z")
                ]
               ),
        .target(name: "RHVoice_dependencies",
               dependencies: [
                .target(name: "libcurl", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "libcrypto"),
                .target(name: "libnghttp2", condition: .when(platforms: [.iOS, .macCatalyst])),
                .target(name: "libssl", condition: .when(platforms: [.iOS, .macCatalyst]))
               ],
                path: "Bridge",
                sources: [
                    "placeholder.swift"
                ],
                linkerSettings: [
                    .linkedFramework("SystemConfiguration", .when(platforms: [.macOS])),
                    .linkedLibrary("ldap", .when(platforms: [.macOS])),
                    .linkedLibrary("curl", .when(platforms: [.macOS])),
                    .linkedLibrary("boringssl", .when(platforms: [.macOS]))
                ]
               )
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx11
)

func versionString(fileName: String) -> String {
    let defaultValue = "\"\""
    do {
        let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let input = packageURL.appendingPathComponent("Core").appendingPathComponent(fileName)
        let inputString = try String(contentsOf: input, encoding: .utf8)
        guard let begin = inputString.range(of: "next_version=") else {
            return defaultValue
        }

        guard let end = inputString.range(of: "\n", range: begin.upperBound..<inputString.endIndex) else {
            return defaultValue
        }

        return String(inputString[begin.upperBound..<end.lowerBound])
    } catch {

    }
    return defaultValue
}
