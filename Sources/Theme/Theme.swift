public import Dimension

public struct Theme: Hashable, Sendable {

    public let ordinal: Ordinal

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        self.ordinal = ordinal
    }
}

extension Theme {

    public static let light = Theme(_unchecked: (), ordinal: 0)

    public static let dark = Theme(_unchecked: (), ordinal: 1)
}

extension Theme: Finite.Enumerable {

    public static let count: Cardinal = 2
}

extension Theme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        default: return "unknown"
        }
    }
}
