// swift-tools-version: 6.4

import PackageDescription

// Color Standard — Unified color interchange between color standards
let package = Package(
    name: "swift-color-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Color Standard", targets: ["Color Standard"]),
        .library(name: "Theme", targets: ["Theme"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-dimension-primitives.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-iec/swift-iec-61966.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-9899.git", branch: "main"),
        .package(url: "https://github.com/swift-ecma/swift-ecma-48.git", branch: "main"),
    ],
    targets: [
        // MARK: - Theme
        .target(
            name: "Theme",
            dependencies: [
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives")
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
            dependencies: [
                "Color Standard"
            ]
        ),
        .testTarget(
            name: "Theme Tests",
            dependencies: [
                "Color Standard"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
