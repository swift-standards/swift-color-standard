public import Cardinal
public import Finite
public import Ordinal
import Space

public enum Theme: Hashable, Sendable {

    case light

    case dark
}

extension Theme: Finite.Enumerable {

    public static let count: Cardinal = 2

    @inlinable
    public var ordinal: Ordinal {
        switch self {
        case .light: 0
        case .dark: 1
        }
    }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        precondition(ordinal.rawValue < Self.count.rawValue, "Theme ordinal must be zero or one")
        self = ordinal.rawValue == 0 ? .light : .dark
    }
}

extension Theme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        }
    }
}
