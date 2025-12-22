// Color.Oklch.swift
// Oklch (Lightness, Chroma, Hue) color space type

import ISO_9899

// MARK: - Oklch Color Space

extension Color {
  /// Oklch color space (cylindrical representation of Oklab).
  ///
  /// Oklch is a polar/cylindrical representation of Oklab that uses:
  /// - **L** (Lightness): Same as Oklab, 0 = black, 1 = white
  /// - **C** (Chroma): Distance from the neutral axis (colorfulness)
  /// - **h** (Hue): Angle in degrees (0° = pink/red, 90° = yellow, 180° = cyan, 270° = blue)
  ///
  /// Oklch is often more intuitive for color manipulation since hue and
  /// chroma are explicit rather than encoded in a/b coordinates.
  ///
  /// ## CSS Color Level 4
  ///
  /// Oklch is specified in CSS Color Level 4 as `oklch()` and is recommended
  /// for CSS color manipulation due to its perceptual uniformity.
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Pure red in Oklch (approximately)
  /// let red = Color.Oklch(l: 0.628, c: 0.258, h: 29.2)
  ///
  /// // Rotate hue by 180° to get cyan
  /// let cyan = Color.Oklch(l: red.l, c: red.c, h: red.h + 180)
  /// ```
  ///
  /// ## Reference
  ///
  /// CSS Color Level 4: https://www.w3.org/TR/css-color-4/#ok-lab
  /// Björn Ottosson: https://bottosson.github.io/posts/oklab/
  public struct Oklch: Sendable, Hashable {
    /// Lightness component (0–1)
    ///
    /// Same as Oklab L:
    /// - 0 = black (no light)
    /// - 1 = white (maximum lightness)
    public var l: Double

    /// Chroma component (colorfulness)
    ///
    /// Distance from the neutral axis (L axis).
    /// - 0 = gray/achromatic
    /// - Higher values = more colorful/saturated
    ///
    /// Typical maximum is around 0.4 for sRGB colors.
    public var c: Double

    /// Hue angle in degrees (0–360)
    ///
    /// Angular position on the color wheel:
    /// - 0°/360° = Pink/Red
    /// - 90° = Yellow
    /// - 180° = Cyan
    /// - 270° = Blue
    public var h: Double

    /// Creates an Oklch color from components.
    ///
    /// - Parameters:
    ///   - l: Lightness (0–1)
    ///   - c: Chroma (≥0)
    ///   - h: Hue angle in degrees (automatically normalized to 0–360)
    public init(l: Double, c: Double, h: Double) {
      self.l = l.clamped(to: 0...1)
      self.c = max(0, c)
      self.h = h.truncatingRemainder(dividingBy: 360)
      if self.h < 0 { self.h += 360 }
    }
  }
}

// MARK: - Common Colors

extension Color.Oklch {
  /// Black (L=0)
  public static let black = Self(l: 0, c: 0, h: 0)

  /// White (L=1)
  public static let white = Self(l: 1, c: 0, h: 0)
}

// MARK: - Oklab Conversion

extension Color.Oklch {
  /// Creates Oklch from Oklab components.
  ///
  /// - Parameter oklab: Oklab color to convert
  public init(_ oklab: Color.Oklab) {
    let c = ISO_9899.Math.sqrt(oklab.a * oklab.a + oklab.b * oklab.b)
    var h = ISO_9899.Math.atan2(oklab.b, oklab.a) * 180.0 / Double.pi
    if h < 0 { h += 360 }

    self.init(l: oklab.l, c: c, h: h)
  }

  /// Converts to Oklab representation.
  public var oklab: Color.Oklab {
    let hRad = h * Double.pi / 180.0
    let a = c * ISO_9899.Math.cos(hRad)
    let b = c * ISO_9899.Math.sin(hRad)
    return Color.Oklab(l: l, a: a, b: b)
  }
}
