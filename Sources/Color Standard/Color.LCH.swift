// Color.LCH.swift
// CIE LCH (Lightness, Chroma, Hue) color space type

import ISO_9899

// MARK: - LCH Color Space

extension Color {
    /// CIE LCH color space (cylindrical representation of LAB).
    ///
    /// LCH is a polar/cylindrical representation of CIELAB that uses:
    /// - **L*** (Lightness): Same as LAB, 0 = black, 100 = white
    /// - **C*** (Chroma): Distance from the neutral axis (colorfulness)
    /// - **h** (Hue): Angle in degrees (0° = red, 90° = yellow, 180° = green, 270° = blue)
    ///
    /// LCH is often more intuitive for color manipulation since hue and
    /// chroma are explicit rather than encoded in a*/b* coordinates.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Pure red in LCH (approximately)
    /// let red = Color.LCH(l: 53.2, c: 104.6, h: 40.0)
    ///
    /// // Rotate hue by 180° to get cyan
    /// let cyan = Color.LCH(l: red.l, c: red.c, h: red.h + 180)
    /// ```
    ///
    /// ## Reference
    ///
    /// CIE Publication 15:2004, Colorimetry, 3rd Edition
    public struct LCH: Sendable, Hashable {
        /// Lightness component (0–100)
        ///
        /// Same as LAB L*:
        /// - 0 = black (no light)
        /// - 100 = white (maximum lightness)
        public var l: Double

        /// Chroma component (colorfulness)
        ///
        /// Distance from the neutral axis (L* axis).
        ///
        /// - 0 = gray/achromatic
        /// - Higher values = more colorful/saturated
        ///
        /// Typical maximum is around 130 for sRGB colors.
        public var c: Double

        /// Hue angle in degrees (0–360)
        ///
        /// Angular position on the color wheel:
        /// - 0°/360° = Red
        /// - 90° = Yellow
        /// - 180° = Green/Cyan
        /// - 270° = Blue
        public var h: Double

        /// Creates an LCH color from components.
        ///
        /// - Parameters:
        ///   - l: Lightness (0–100)
        ///   - c: Chroma (≥0)
        ///   - h: Hue angle in degrees (automatically normalized to 0–360)
        public init(l: Double, c: Double, h: Double) {
            self.l = l.clamped(to: 0...100)
            self.c = max(0, c)
            self.h = h.truncatingRemainder(dividingBy: 360)
            if self.h < 0 { self.h += 360 }
        }
    }
}

// MARK: - Common Colors

extension Color.LCH {
    /// Black (L*=0)
    public static let black = Self(l: 0, c: 0, h: 0)

    /// White (L*=100)
    public static let white = Self(l: 100, c: 0, h: 0)
}

// MARK: - LAB Conversion

extension Color.LCH {
    /// Creates LCH from LAB components.
    ///
    /// - Parameter lab: LAB color to convert
    public init(_ lab: Color.LAB) {
        let c = ISO_9899.Math.sqrt(lab.a * lab.a + lab.b * lab.b)
        var h = ISO_9899.Math.atan2(lab.b, lab.a) * 180.0 / Double.pi
        if h < 0 { h += 360 }

        self.init(l: lab.l, c: c, h: h)
    }

    /// Converts to LAB representation.
    public var lab: Color.LAB {
        let hRad = h * Double.pi / 180.0
        let a = c * ISO_9899.Math.cos(hRad)
        let b = c * ISO_9899.Math.sin(hRad)
        return Color.LAB(l: l, a: a, b: b)
    }
}
