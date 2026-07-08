// Color.Oklab.swift
// Oklab perceptually uniform color space type

import ISO_9899

// MARK: - Oklab Color Space

extension Color {
    /// Oklab perceptually uniform color space.
    ///
    /// Oklab is a perceptually uniform color space designed by Björn Ottosson
    /// as an improvement over CIELAB. It provides better hue linearity and
    /// more uniform lightness perception.
    ///
    /// Components:
    /// - **L** (Lightness): 0 = black, 1 = white
    /// - **a**: Green–Red axis (negative = green, positive = red)
    /// - **b**: Blue–Yellow axis (negative = blue, positive = yellow)
    ///
    /// ## Advantages over CIELAB
    ///
    /// - Better hue linearity (hue stays constant when adjusting lightness/chroma)
    /// - More uniform lightness perception across hues
    /// - Uses D65 illuminant (same as sRGB, no chromatic adaptation needed)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Pure red in Oklab (approximately)
    /// let red = Color.Oklab(l: 0.628, a: 0.225, b: 0.126)
    ///
    /// // Convert to sRGB
    /// let srgb = red.converted(to: IEC_61966.`2`.`1`.sRGB.self)
    /// ```
    ///
    /// ## Reference
    ///
    /// Björn Ottosson, "A perceptual color space for image processing"
    /// https://bottosson.github.io/posts/oklab/
    public struct Oklab: Sendable, Hashable {
        /// Lightness component (0–1)
        ///
        /// - 0 = black (no light)
        /// - 1 = white (maximum lightness)
        public var l: Double

        /// a component (green–red axis)
        ///
        /// Typical range approximately -0.4 to +0.4.
        ///
        /// - Negative values = green
        /// - Positive values = red
        public var a: Double

        /// b component (blue–yellow axis)
        ///
        /// Typical range approximately -0.4 to +0.4.
        ///
        /// - Negative values = blue
        /// - Positive values = yellow
        public var b: Double

        /// Creates an Oklab color from components.
        ///
        /// - Parameters:
        ///   - l: Lightness (0–1)
        ///   - a: a component (green–red)
        ///   - b: b component (blue–yellow)
        public init(l: Double, a: Double, b: Double) {
            self.l = l.clamped(to: 0...1)
            self.a = a
            self.b = b
        }
    }
}

// MARK: - Typed Components (Optional)

extension Color.Oklab {
    /// Lightness component type for Oklab.
    ///
    /// Range: 0 (black) to 1 (white)
    public struct Lightness: Sendable, Hashable {
        /// The lightness value (0–1)
        public let value: Double

        /// Creates a lightness value.
        ///
        /// - Parameter value: Lightness in range [0, 1]
        /// - Throws: `Error` if value is outside valid range
        public init(_ value: Double) throws(Error) {
            guard value >= 0 && value <= 1 else {
                throw Error(value: value)
            }
            self.value = value
        }

        /// Creates a lightness value by clamping to valid range.
        ///
        /// - Parameter value: Any lightness value (will be clamped to 0–1)
        public init(clamping value: Double) {
            self.value = value.clamped(to: 0...1)
        }
    }
}

extension Color.Oklab.Lightness {
    /// Error thrown when lightness is out of valid range.
    public struct Error: Swift.Error, Sendable, CustomStringConvertible {
        public let value: Double
        public static let validRange: ClosedRange<Double> = 0...1
    }
}

extension Color.Oklab.Lightness.Error {
    public var description: String {
        "Oklab lightness \(value) is out of valid range \(Self.validRange)"
    }
}

// MARK: - Common Colors

extension Color.Oklab {
    /// Black (L=0)
    public static let black = Self(l: 0, a: 0, b: 0)

    /// White (L=1)
    public static let white = Self(l: 1, a: 0, b: 0)
}

// MARK: - Convenience Initializer with Typed Components

extension Color.Oklab {
    /// Creates an Oklab color from typed lightness component.
    ///
    /// - Parameters:
    ///   - l: Typed lightness component
    ///   - a: a component
    ///   - b: b component
    public init(l: Lightness, a: Double, b: Double) {
        self.l = l.value
        self.a = a
        self.b = b
    }
}
