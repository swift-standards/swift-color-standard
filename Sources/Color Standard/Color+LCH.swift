// Color+LCH.swift
// CIE LCH conformance to Color.Protocol

// MARK: - LCH Conformance to Color.Protocol

extension Color.LCH: Color.`Protocol` {
  /// Converts LCH to canonical color representation.
  ///
  /// The conversion:
  /// 1. Converts LCH to LAB (cylindrical to cartesian)
  /// 2. Converts LAB to XYZ (D50 illuminant)
  /// 3. Stores in canonical `Color` representation
  ///
  /// - Returns: Canonical color representation
  public func canonical() -> Color {
    // LCH → LAB → XYZ → Color
    self.lab.canonical()
  }

  /// Creates LCH from canonical color representation.
  ///
  /// The conversion:
  /// 1. Converts to LAB via `Color._toLAB`
  /// 2. Converts LAB to LCH (cartesian to cylindrical)
  ///
  /// - Parameter color: Canonical color to convert from
  public init(_ color: Color) {
    // Color → LAB → LCH
    self.init(Color._toLAB(color))
  }
}
