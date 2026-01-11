// Theme.swift
// Color scheme / appearance mode.

public import Dimension_Primitives

/// Color scheme / appearance mode.
///
/// `Theme` is an `Enumerable` type with two cases representing light and dark
/// appearance modes. As an `Enumerable`, it has indexed cases and generates
/// a natural product type `Theme.Product<V>` ≅ `V²`.
///
/// ## Example
///
/// ```swift
/// for theme in Theme.allCases {
///     print(theme)  // light, dark
/// }
///
/// let colors: Theme.Product<Color> = .init(light: .black, dark: .white)
/// let current = colors[.dark]  // .white
/// ```
///
/// ## Algebra
///
/// - `Theme` is a finite set with 2 elements: `{light, dark}`
/// - `Theme.Product<V>` is the exponential object `V^Theme ≅ V × V`
/// - Selection `product[theme]` is projection `π_i`
public struct Theme: Hashable {
  /// Index of this theme case (0 = light, 1 = dark).
  public let caseIndex: Int

  /// Creates a theme from its case index.
  ///
  /// - Precondition: `caseIndex` must be 0 or 1.
  @inlinable
  public init(caseIndex: Int) {
    precondition(caseIndex >= 0 && caseIndex < Self.caseCount, "Invalid theme index")
    self.caseIndex = caseIndex
  }

  /// Light appearance mode.
  public static let light = Theme(caseIndex: 0)

  /// Dark appearance mode.
  public static let dark = Theme(caseIndex: 1)
}

// MARK: - Enumerable Conformance

extension Theme: Enumerable {
  /// Number of theme cases (2: light and dark).
  public static let caseCount = 2
}

// MARK: - CustomStringConvertible

extension Theme: CustomStringConvertible {
  public var description: String {
    switch caseIndex {
    case 0: return "light"
    case 1: return "dark"
    default: return "unknown"
    }
  }
}
