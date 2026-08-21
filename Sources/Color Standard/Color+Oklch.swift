extension Color.Oklch: Color.`Protocol` {

    public func canonical() -> Color {

        self.oklab.canonical()
    }

    public init(_ color: Color) {

        self.init(Color._toOklab(color))
    }
}
