// swift-tools-version: 6.3.1

import PackageDescription

// Color Standard — Unified color interchange between color standards
let package = Package(
    name: "swift-color-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "Color Standard", targets: ["Color Standard"]),
        .library(name: "Theme", targets: ["Theme"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-dimension-primitives"),
        .package(path: "../../swift-iec/swift-iec-61966"),
        .package(path: "../../swift-iso/swift-iso-9899"),
        .package(path: "../../swift-ecma/swift-ecma-48")
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
                .product(name: "ECMA 48", package: "swift-ecma-48")
            ]
        ),
        .testTarget(
            name: "Color Standard Tests",
            dependencies: [
                "Color Standard",
            ]
        ),
        .testTarget(
            name: "Theme Tests",
            dependencies: [
                "Color Standard",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
