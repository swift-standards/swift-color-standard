// swift-tools-version: 6.2

import PackageDescription

// Color Standard — Unified color interchange between color standards
let package = Package(
    name: "swift-color-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "Color Standard", targets: ["Color Standard"]),
        .library(name: "Theme", targets: ["Theme"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-dimension-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-iec-61966.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-iso-9899.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-ecma-48.git", from: "0.0.1"),
    ],
    targets: [
        // MARK: - Theme
        .target(
            name: "Theme",
            dependencies: [
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
            ]
        ),

        // MARK: - Color Standard
        .target(
            name: "Color Standard",
            dependencies: [
                "Theme",
                .product(name: "IEC 61966", package: "swift-iec-61966"),
                .product(name: "ISO 9899", package: "swift-iso-9899"),
                .product(name: "ECMA 48", package: "swift-ecma-48"),
            ]
        ),

        .testTarget(
            name: "Color Standard Tests",
            dependencies: ["Color Standard"]
        ),

        .testTarget(
            name: "Theme Tests",
            dependencies: ["Theme"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
