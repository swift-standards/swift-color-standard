extension Color {

    public protocol `Protocol`: Sendable {

        func canonical() -> Color

        init(_ color: Color)
    }
}

extension Color.`Protocol` {

    public func converted<Target: Color.`Protocol`>(to targetType: Target.Type) -> Target {
        Target(self.canonical())
    }
}

extension Color: Color.`Protocol` {

    public func canonical() -> Color {
        self
    }

    public init(_ color: Color) {
        self = color
    }
}
