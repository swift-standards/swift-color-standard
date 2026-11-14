import Testing

@testable import Color_Standard

enum `Color.Oklab Linear Tests` {}

extension `Color.Oklab Linear Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension `Color.Oklab Linear Tests`.Test.Unit {

    static let samples: [(Double, Double, Double)] = [
        (0, 0, 0), (1, 1, 1), (1, 0, 0), (0, 1, 0), (0, 0, 1),
        (0.2, 0.5, 0.8), (0.9, 0.1, 0.4), (0.018, 0.018, 0.018),
    ]

    /// A colour's linear sRGB components as `Color` works them out, unclamped.
    static func linear(_ color: Color) -> (Double, Double, Double) {
        let m = Color._XYZ.xyzToSRGB
        let xyz = color._xyz
        return (
            m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z,
            m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z,
            m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z
        )
    }

    @Test
    func `Oklab of a colour is the coordinates of its linear sRGB, bit for bit`() {
        for (r, g, b) in Self.samples {
            let color = IEC_61966.`2`.`1`.LinearSRGB(r: r, g: g, b: b).canonical()
            let (lr, lg, lb) = Self.linear(color)
            let place = Color.Oklab.coordinates(red: lr, green: lg, blue: lb)
            #expect(Color.Oklab(color) == Color.Oklab(l: place.l, a: place.a, b: place.b))
        }
    }

    @Test
    func `encoded sRGB reaches the same Oklab as its linear components`() {
        let encoded = IEC_61966.`2`.`1`.SRGB(r: 0.25, g: 0.5, b: 0.75)
        let (lr, lg, lb) = Self.linear(encoded.canonical())
        let place = Color.Oklab.coordinates(red: lr, green: lg, blue: lb)
        #expect(encoded.converted(to: Color.Oklab.self) == Color.Oklab(l: place.l, a: place.a, b: place.b))
    }

    @Test
    func `white is at L 1 and greys have no a or b`() {
        let white = Color.Oklab.coordinates(red: 1.0, green: 1.0, blue: 1.0)
        #expect(abs(white.l - 1) < 1e-6 && abs(white.a) < 1e-6 && abs(white.b) < 1e-6)
        let grey = Color.Oklab.coordinates(red: Float(0.18), green: 0.18, blue: 0.18)
        #expect(abs(grey.a) < 1e-5 && abs(grey.b) < 1e-5)
        #expect(Color.Oklab.coordinates(red: 0.0, green: 0.0, blue: 0.0) == (l: 0, a: 0, b: 0))
    }

    @Test
    func `linear is the inverse of coordinates`() {
        for (r, g, b) in Self.samples {
            let place = Color.Oklab.coordinates(red: r, green: g, blue: b)
            let back = Color.Oklab.linear(l: place.l, a: place.a, b: place.b)
            #expect(abs(back.red - r) < 1e-6 && abs(back.green - g) < 1e-6 && abs(back.blue - b) < 1e-6)
        }
    }

    @Test
    func `Float is Double's arithmetic in single precision`() {
        for (r, g, b) in Self.samples {
            let single = Color.Oklab.coordinates(red: Float(r), green: Float(g), blue: Float(b))
            let double = Color.Oklab.coordinates(red: Double(Float(r)), green: Double(Float(g)), blue: Double(Float(b)))
            #expect(abs(Double(single.l) - double.l) < 1e-5)
            #expect(abs(Double(single.a) - double.a) < 1e-5)
            #expect(abs(Double(single.b) - double.b) < 1e-5)
        }
    }

    @Test
    func `the canonical colour of a place is its linear sRGB taken to XYZ`() {
        let oklab = Color.Oklab(l: 0.6, a: 0.1, b: -0.1)
        let linear = Color.Oklab.linear(l: oklab.l, a: oklab.a, b: oklab.b)
        let expected = IEC_61966.`2`.`1`.LinearSRGB(r: linear.red, g: linear.green, b: linear.blue).canonical()
        #expect(oklab.canonical() == expected)
    }
}
