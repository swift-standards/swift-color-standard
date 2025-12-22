// Color.Protocol.swift
// Protocol for types that can be represented as colors

// MARK: - Color Protocol

extension Color {
  /// Protocol for types that can be represented as colors.
  ///
  /// Conforming types can convert to/from `Color`,
  /// enabling interchange between different color standards.
  ///
  /// ## Conformance
  ///
  /// To make a color type interchangeable, conform it to `Color.Protocol`:
  ///
  /// ```swift
  /// extension MyColor: Color.Protocol {
  ///     func canonical() -> Color {
  ///         // Convert to canonical representation
  ///         Color(...)
  ///     }
  ///
  ///     init(_ color: Color) {
  ///         // Convert from canonical representation
  ///     }
  /// }
  /// ```
  ///
  /// ## Example Usage
  ///
  /// ```swift
  /// // Convert between any conforming types
  /// let srgb = IEC_61966.`2`.`1`.sRGB(r: 0.5, g: 0.3, b: 0.8)
  /// let color = srgb.canonical()
  ///
  /// // Convert to another format
  /// let other = OtherColor(color)
  ///
  /// // Or use the convenience method
  /// let converted = srgb.converted(to: OtherColor.self)
  /// ```
  ///
  /// ## Lossy Conversions
  ///
  /// Some conversions may be lossy due to:
  /// - **Gamut limitations**: Target color space cannot represent all colors
  /// - **Precision loss**: Rounding during conversion
  /// - **Model differences**: e.g., CMYK has no direct XYZ equivalent
  ///
  /// Conforming types should document any limitations in their conversion.
  public protocol `Protocol`: Sendable {
    /// Converts to canonical color representation.
    ///
    /// This conversion should be lossless within the type's representable gamut.
    /// Colors outside the target's gamut during reverse conversion may be clipped.
    ///
    /// - Returns: Canonical color representation
    func canonical() -> Color

    /// Creates from canonical color representation.
    ///
    /// - Parameter color: Canonical color to convert from
    init(_ color: Color)
  }
}

// MARK: - Convenience Extension

extension Color.`Protocol` {
  /// Converts to another color type through canonical representation.
  ///
  /// This is a convenience method that chains `canonical()` and `init(_:)`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let srgb = IEC_61966.`2`.`1`.sRGB(r: 0.5, g: 0.3, b: 0.8)
  /// let other = srgb.converted(to: OtherColor.self)
  /// ```
  ///
  /// - Parameter targetType: The type to convert to
  /// - Returns: Color converted to target type
  public func converted<Target: Color.`Protocol`>(to targetType: Target.Type) -> Target {
    Target(self.canonical())
  }
}

// MARK: - Color Self-Conformance

extension Color: Color.`Protocol` {
  /// Returns self (identity conversion).
  public func canonical() -> Color {
    self
  }

  /// Creates from another color (identity conversion).
  public init(_ color: Color) {
    self = color
  }
}
