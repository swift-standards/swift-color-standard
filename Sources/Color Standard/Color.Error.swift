extension Color {

    public enum Error: Swift.Error, Sendable, Equatable {

        case outOfGamut

        case unsupportedColorSpace

        case invalidComponent(component: String, value: Double)
    }
}

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
