import ISO_9899

extension Color {

    public struct LCH: Sendable, Hashable {

        public var l: Double

        public var c: Double

        public var h: Double

        public init(l: Double, c: Double, h: Double) {
            self.l = l.clamped(to: 0...100)
            self.c = max(0, c)
            self.h = h.truncatingRemainder(dividingBy: 360)
            if self.h < 0 { self.h += 360 }
        }
    }
}

extension Color.LCH {

    public static let black = Self(l: 0, c: 0, h: 0)

    public static let white = Self(l: 100, c: 0, h: 0)
}

extension Color.LCH {

    public init(_ lab: Color.LAB) {
        let c = ISO_9899.Math.sqrt(lab.a * lab.a + lab.b * lab.b)
        var h = ISO_9899.Math.atan2(lab.b, lab.a) * 180.0 / Double.pi
        if h < 0 { h += 360 }

        self.init(l: lab.l, c: c, h: h)
    }

    public var lab: Color.LAB {
        let hRad = h * Double.pi / 180.0
        let a = c * ISO_9899.Math.cos(hRad)
        let b = c * ISO_9899.Math.sin(hRad)
        return Color.LAB(l: l, a: a, b: b)
    }
}
