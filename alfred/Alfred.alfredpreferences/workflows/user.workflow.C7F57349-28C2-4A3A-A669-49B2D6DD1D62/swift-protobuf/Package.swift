// swift-tools-version:5.10

// Package.swift
//
// Copyright (c) 2014 - 2018 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/main/LICENSE.txt
//

import PackageDescription

let package = Package(
    name: "SwiftProtobuf",
    products: [
        .library(
            name: "SwiftProtobuf",
            targets: ["SwiftProtobuf"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftProtobuf",
            exclude: ["CMakeLists.txt"],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: .packageSettings
        ),
    ],
    swiftLanguageVersions: [.v5]
)

// Settings for every Swift target in this package, like project-level settings
// in an Xcode project.
extension Array where Element == PackageDescription.SwiftSetting {
    static var packageSettings: Self {
        [
            .enableExperimentalFeature("StrictConcurrency=complete"),
            .enableUpcomingFeature("ExistentialAny"),
        ]
    }
}
