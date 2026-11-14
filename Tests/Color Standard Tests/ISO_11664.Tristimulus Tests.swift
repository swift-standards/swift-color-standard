import ISO_11664
import Testing

@testable import Color_Standard

enum `ISO_11664.Tristimulus Color Tests` {}

extension `ISO_11664.Tristimulus Color Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension `ISO_11664.Tristimulus Color Tests`.Test.Unit {

    @Test
    func `tristimulus values are the colour's own XYZ relative to D65`() {
        let values = ISO_11664.Tristimulus(x: 0.3, y: 0.4, z: 0.5)
        #expect(ISO_11664.Tristimulus(values.canonical()) == values)
        #expect(ISO_11664.Tristimulus(Color.white) == ISO_11664.Tristimulus(x: 0.95047, y: 1, z: 1.08883))
    }

    @Test
    func `a D50 colour is adapted to D65 first, and back to the digits of the Bradford matrices`() {
        let lab = Color.LAB(l: 50, a: 20, b: -30)
        let values = ISO_11664.Tristimulus(lab.canonical())
        let back = Color.LAB(values.canonical())
        #expect(abs(back.l - lab.l) < 1e-3 && abs(back.a - lab.a) < 1e-3 && abs(back.b - lab.b) < 1e-3)
        #expect(values != ISO_11664.Tristimulus(x: lab.canonical()._xyz.x, y: lab.canonical()._xyz.y, z: lab.canonical()._xyz.z))
    }

    @Test
    func `sRGB through tristimulus values is unchanged`() {
        let srgb = IEC_61966.`2`.`1`.SRGB(r: 0.2, g: 0.6, b: 0.9)
        let values = srgb.converted(to: ISO_11664.Tristimulus.self)
        #expect(values.converted(to: IEC_61966.`2`.`1`.SRGB.self) == srgb.converted(to: IEC_61966.`2`.`1`.SRGB.self))
    }
}
