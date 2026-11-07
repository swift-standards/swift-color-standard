import ISO_9899

extension Color {

    public struct LAB: Sendable, Hashable {

        public var l: Double

        public var a: Double

        public var b: Double

        public init(l: Double, a: Double, b: Double) {
            self.l = l.clamped(to: 0...100)
            self.a = a
            self.b = b
        }
    }
}

extension Color.LAB {
}

extension Color.LAB.Lightness {
}

extension Color.LAB.Lightness.Error {
    public static let validRange: ClosedRange<Double> = 0...100

    public var description: String {
        "LAB lightness \(value) is out of valid range \(Self.validRange)"
    }
}

extension Color.LAB {

    public static let black = Self(l: 0, a: 0, b: 0)

    public static let white = Self(l: 100, a: 0, b: 0)

    public static let d50White = Self(l: 100, a: 0, b: 0)
}

extension Color.LAB {

    public init(l: Lightness, a: Double, b: Double) {
        self.l = l.value
        self.a = a
        self.b = b
    }
}
