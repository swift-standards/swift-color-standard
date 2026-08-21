import ISO_9899

extension Color {

    public struct Oklab: Sendable, Hashable {

        public var l: Double

        public var a: Double

        public var b: Double

        public init(l: Double, a: Double, b: Double) {
            self.l = l.clamped(to: 0...1)
            self.a = a
            self.b = b
        }
    }
}

extension Color.Oklab {

    public struct Lightness: Sendable, Hashable {

        public let value: Double

        public init(_ value: Double) throws(Error) {
            guard value >= 0 && value <= 1 else {
                throw Error(value: value)
            }
            self.value = value
        }

        public init(clamping value: Double) {
            self.value = value.clamped(to: 0...1)
        }
    }
}

extension Color.Oklab.Lightness {

    public struct Error: Swift.Error, Sendable, CustomStringConvertible {
        public let value: Double
    }
}

extension Color.Oklab.Lightness.Error {
    public static let validRange: ClosedRange<Double> = 0...1

    public var description: String {
        "Oklab lightness \(value) is out of valid range \(Self.validRange)"
    }
}

extension Color.Oklab {

    public static let black = Self(l: 0, a: 0, b: 0)

    public static let white = Self(l: 1, a: 0, b: 0)
}

extension Color.Oklab {

    public init(l: Lightness, a: Double, b: Double) {
        self.l = l.value
        self.a = a
        self.b = b
    }
}
