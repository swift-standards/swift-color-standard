// Color.LAB.swift
// CIE LAB (L*a*b*) color space type

import ISO_9899

// MARK: - LAB Color Space

extension Color {
    /// CIE LAB (L*a*b*) color space.
    ///
    /// CIELAB is a perceptually uniform color space designed so that
    /// equal numeric changes correspond to roughly equal perceived changes.
    ///
    /// Components:
    /// - **L*** (Lightness): 0 = black, 100 = white
    /// - **a***: Green–Red axis (negative = green, positive = red)
    /// - **b***: Blue–Yellow axis (negative = blue, positive = yellow)
    ///
    /// ## Reference Illuminant
    ///
    /// CIELAB is defined relative to a reference white point. This implementation
    /// uses **D50** (ICC Profile Connection Space standard), which is converted
    /// to D65 when interfacing with sRGB through the `Color` hub.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Pure red in LAB (approximately)
    /// let red = Color.LAB(l: 53.2, a: 80.1, b: 67.2)
    ///
    /// // Convert to sRGB
    /// let srgb = red.converted(to: IEC_61966.`2`.`1`.sRGB.self)
    /// ```
    ///
    /// ## Reference
    ///
    /// CIE Publication 15:2004, Colorimetry, 3rd Edition
    public struct LAB: Sendable, Hashable {
        /// Lightness component (0–100)
        ///
        /// - 0 = black (no light)
        /// - 100 = white (maximum lightness)
        public var l: Double

        /// a* component (green–red axis)
        ///
        /// Typical range approximately -128 to +128.
        ///
        /// - Negative values = green
        /// - Positive values = red
        public var a: Double

        /// b* component (blue–yellow axis)
        ///
        /// Typical range approximately -128 to +128.
        ///
        /// - Negative values = blue
        /// - Positive values = yellow
        public var b: Double

        /// Creates a LAB color from components.
        ///
        /// - Parameters:
        ///   - l: Lightness (0–100)
        ///   - a: a* component (green–red)
        ///   - b: b* component (blue–yellow)
        public init(l: Double, a: Double, b: Double) {
            self.l = l.clamped(to: 0...100)
            self.a = a
            self.b = b
        }
    }
}

// MARK: - Typed Components (Optional)

extension Color.LAB {
    /// Lightness component type for CIELAB.
    ///
    /// Range: 0 (black) to 100 (white)
    public struct Lightness: Sendable, Hashable {
        /// The lightness value (0–100)
        public let value: Double

        /// Creates a lightness value.
        ///
        /// - Parameter value: Lightness in range [0, 100]
        /// - Throws: `Error` if value is outside valid range
        public init(_ value: Double) throws(Error) {
            guard value >= 0 && value <= 100 else {
                throw Error(value: value)
            }
            self.value = value
        }

        /// Creates a lightness value by clamping to valid range.
        ///
        /// - Parameter value: Any lightness value (will be clamped to 0–100)
        public init(clamping value: Double) {
            self.value = value.clamped(to: 0...100)
        }
    }
}

extension Color.LAB.Lightness {
    /// Error thrown when lightness is out of valid range.
    public struct Error: Swift.Error, Sendable, CustomStringConvertible {
        public let value: Double
        public static let validRange: ClosedRange<Double> = 0...100
    }
}

extension Color.LAB.Lightness.Error {
    public var description: String {
        "LAB lightness \(value) is out of valid range \(Self.validRange)"
    }
}

// MARK: - Common Colors

extension Color.LAB {
    /// Black (L*=0)
    public static let black = Self(l: 0, a: 0, b: 0)

    /// White (L*=100)
    public static let white = Self(l: 100, a: 0, b: 0)

    /// D50 white point in LAB (reference white)
    public static let d50White = Self(l: 100, a: 0, b: 0)
}

// MARK: - Convenience Initializer with Typed Components

extension Color.LAB {
    /// Creates a LAB color from typed lightness component.
    ///
    /// - Parameters:
    ///   - l: Typed lightness component
    ///   - a: a* component
    ///   - b: b* component
    public init(l: Lightness, a: Double, b: Double) {
        self.l = l.value
        self.a = a
        self.b = b
    }
}
