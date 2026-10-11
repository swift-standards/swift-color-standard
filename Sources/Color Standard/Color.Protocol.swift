public protocol _ColorProtocol: Sendable {

    func canonical() -> Color

    init(_ color: Color)
}

extension Color {

    public typealias `Protocol` = _ColorProtocol
}

extension _ColorProtocol {

    public func converted<Target: Color.`Protocol`>(to targetType: Target.Type) -> Target {
        Target(self.canonical())
    }
}

extension Color: _ColorProtocol {

    public func canonical() -> Color {
        self
    }

    public init(_ color: Color) {
        self = color
    }
}
