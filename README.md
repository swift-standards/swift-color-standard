# swift-color-standard

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Unified color representation for Swift, composing CSS and display-profile specifications.

## Overview

This package provides a `Color` type and protocol that convert between color spaces — sRGB, CIE LAB, CIE LCH, Oklab, Oklch, and CIE XYZ — under the `Color Standard` target, plus a small `Theme` target for color-role/product composition. It composes IEC 61966 (display-referred color management), ISO 9899, and ECMA 48 rather than reimplementing colorimetry from scratch.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-color-standard.git", from: "0.1.0")
]
```

Add the product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Color Standard", package: "swift-color-standard")
    ]
)
```

The package also vends `Theme` for color-role and product composition.

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.
