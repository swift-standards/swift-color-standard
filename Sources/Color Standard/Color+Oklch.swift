// Color+Oklch.swift
// Oklch conformance to Color.Protocol

// MARK: - Oklch Conformance to Color.Protocol

extension Color.Oklch: Color.`Protocol` {
  /// Converts Oklch to canonical color representation.
  ///
  /// The conversion:
  /// 1. Converts Oklch to Oklab (cylindrical to cartesian)
  /// 2. Converts Oklab to XYZ (D65 illuminant)
  /// 3. Stores in canonical `Color` representation
  ///
  /// - Returns: Canonical color representation
  public func canonical() -> Color {
    // Oklch → Oklab → XYZ → Color
    self.oklab.canonical()
  }

  /// Creates Oklch from canonical color representation.
  ///
  /// The conversion:
  /// 1. Converts to Oklab via `Color._toOklab`
  /// 2. Converts Oklab to Oklch (cartesian to cylindrical)
  ///
  /// - Parameter color: Canonical color to convert from
  public init(_ color: Color) {
    // Color → Oklab → Oklch
    self.init(Color._toOklab(color))
  }
}
