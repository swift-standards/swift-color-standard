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
public struct Theme: Hashable, Sendable {
    /// Ordinal position of this theme case (0 = light, 1 = dark).
    public let ordinal: Ordinal

    /// Creates a theme from its ordinal without bounds checking.
    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        self.ordinal = ordinal
    }
}

// MARK: - Common Instances

extension Theme {
    /// Light appearance mode.
    public static let light = Theme(_unchecked: (), ordinal: 0)

    /// Dark appearance mode.
    public static let dark = Theme(_unchecked: (), ordinal: 1)
}

// MARK: - Enumerable Conformance

extension Theme: Finite.Enumerable {
    /// Number of theme cases (2: light and dark).
    public static let count: Cardinal = 2
}

// MARK: - CustomStringConvertible

extension Theme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        default: return "unknown"
        }
    }
}
