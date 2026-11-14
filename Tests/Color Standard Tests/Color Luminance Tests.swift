import Testing

@testable import Color_Standard

enum `Color Luminance Tests` {}

extension `Color Luminance Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension `Color Luminance Tests`.Test.Unit {

    @Test
    func `white has luminance 1 and black 0`() {
        #expect(abs(Color.luminance(red: 1.0, green: 1.0, blue: 1.0) - 1) < 1e-12)
        #expect(Color.luminance(red: 0.0, green: 0.0, blue: 0.0) == 0)
    }

    @Test
    func `the weights are the printed matrix's Y row, in Float as written in Float`() {
        #expect(Color.luminance(red: Float(1), green: 0, blue: 0) == Float(0.2126))
        #expect(Color.luminance(red: Float(0), green: 1, blue: 0) == Float(0.7152))
        #expect(Color.luminance(red: Float(0), green: 0, blue: 1) == Float(0.0722))
        let (r, g, b): (Float, Float, Float) = (0.3, 0.6, 0.9)
        #expect(Color.luminance(red: r, green: g, blue: b) == 0.2126 * r + 0.7152 * g + 0.0722 * b)
    }

    @Test
    func `luminance is the Y of the printed reverse matrix`() {
        let m = IEC_61966.`2`.`1`.SRGB.Matrix.reverse
        let (r, g, b) = (0.25, 0.5, 0.125)
        #expect(Color.luminance(red: r, green: g, blue: b) == m[1][0] * r + m[1][1] * g + m[1][2] * b)
    }

    @Test
    func `luminance is linear`() {
        let once = Color.luminance(red: 0.1, green: 0.2, blue: 0.3)
        #expect(Color.luminance(red: 0.2, green: 0.4, blue: 0.6) == 2 * once)
    }
}
