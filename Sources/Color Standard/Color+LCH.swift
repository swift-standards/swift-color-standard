extension Color.LCH: Color.`Protocol` {

    public func canonical() -> Color {

        self.lab.canonical()
    }

    public init(_ color: Color) {

        self.init(Color._toLAB(color))
    }
}
