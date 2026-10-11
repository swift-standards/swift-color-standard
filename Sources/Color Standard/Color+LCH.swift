extension Color.LCH: _ColorProtocol {

    public func canonical() -> Color {

        self.lab.canonical()
    }

    public init(_ color: Color) {

        self.init(Color._toLAB(color))
    }
}
