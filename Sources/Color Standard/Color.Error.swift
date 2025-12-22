// Color.Error.swift
// Error types for color conversion

// MARK: - Color Error

extension Color {
  /// Errors that can occur during color conversion.
  public enum Error: Swift.Error, Sendable, Equatable {
    /// Color is outside the target color space's representable gamut.
    ///
    /// This typically occurs when converting from a wide-gamut color space
    /// (like Display P3 or ProPhoto RGB) to a narrower one (like sRGB).
    case outOfGamut

    /// The source color space is not supported for this conversion.
    ///
    /// This may occur with exotic color spaces that require additional
    /// information (like ICC profiles) to convert accurately.
    case unsupportedColorSpace

    /// Invalid color component value.
    ///
    /// - Parameter component: Name of the invalid component
    /// - Parameter value: The invalid value
    case invalidComponent(component: String, value: Double)
  }
}

// MARK: - Error Descriptions

extension Color.Error: CustomStringConvertible {
  public var description: String {
    switch self {
    case .outOfGamut:
      return "Color is outside the target color space's representable gamut"
    case .unsupportedColorSpace:
      return "Color space is not supported for this conversion"
    case .invalidComponent(let component, let value):
      return "Invalid \(component) component value: \(value)"
    }
  }
}
