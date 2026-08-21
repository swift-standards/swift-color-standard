import ISO_9899

extension Color {

    public struct Oklch: Sendable, Hashable {

        public var l: Double

        public var c: Double

        public var h: Double

        public init(l: Double, c: Double, h: Double) {
            self.l = l.clamped(to: 0...1)
            self.c = max(0, c)
            self.h = h.truncatingRemainder(dividingBy: 360)
            if self.h < 0 { self.h += 360 }
        }
    }
}

extension Color.Oklch {

    public static let black = Self(l: 0, c: 0, h: 0)

    public static let white = Self(l: 1, c: 0, h: 0)
}

extension Color.Oklch {

    public init(_ oklab: Color.Oklab) {
        let c = ISO_9899.Math.sqrt(oklab.a * oklab.a + oklab.b * oklab.b)
        var h = ISO_9899.Math.atan2(oklab.b, oklab.a) * 180.0 / Double.pi
        if h < 0 { h += 360 }

        self.init(l: oklab.l, c: c, h: h)
    }

    public var oklab: Color.Oklab {
        let hRad = h * Double.pi / 180.0
        let a = c * ISO_9899.Math.cos(hRad)
        let b = c * ISO_9899.Math.sin(hRad)
        return Color.Oklab(l: l, a: a, b: b)
    }
}
