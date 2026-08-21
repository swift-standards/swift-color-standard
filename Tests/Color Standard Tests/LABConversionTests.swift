import Testing

@testable import Color_Standard

extension Color.LAB {
    @Suite("LAB Conversion Tests")
    struct Test {
        typealias LAB = Color.LAB
        typealias LCH = Color.LCH
        typealias sRGB = IEC_61966.`2`.`1`.sRGB

        @Test
        func `LAB black round-trip`() {
            let original = LAB.black
            let color = original.canonical()
            let roundTrip = LAB(color)

            #expect(abs(roundTrip.l - original.l) < 0.01)
            #expect(abs(roundTrip.a - original.a) < 0.01)
            #expect(abs(roundTrip.b - original.b) < 0.01)
        }

        @Test
        func `LAB white round-trip`() {
            let original = LAB.white
            let color = original.canonical()
            let roundTrip = LAB(color)

            #expect(abs(roundTrip.l - original.l) < 0.01)
            #expect(abs(roundTrip.a - original.a) < 0.01)
            #expect(abs(roundTrip.b - original.b) < 0.01)
        }

        @Test
        func `LAB arbitrary color round-trip`() {

            let original = LAB(l: 50, a: 20, b: -30)
            let color = original.canonical()
            let roundTrip = LAB(color)

            #expect(abs(roundTrip.l - original.l) < 0.01)
            #expect(abs(roundTrip.a - original.a) < 0.01)
            #expect(abs(roundTrip.b - original.b) < 0.01)
        }

        @Test
        func `LAB to sRGB - black`() {
            let lab = LAB(l: 0, a: 0, b: 0)
            let srgb = lab.converted(to: sRGB.self)

            #expect(abs(srgb.r - 0) < 0.01)
            #expect(abs(srgb.g - 0) < 0.01)
            #expect(abs(srgb.b - 0) < 0.01)
        }

        @Test
        func `LAB to sRGB - white`() {
            let lab = LAB(l: 100, a: 0, b: 0)
            let srgb = lab.converted(to: sRGB.self)

            #expect(abs(srgb.r - 1) < 0.01)
            #expect(abs(srgb.g - 1) < 0.01)
            #expect(abs(srgb.b - 1) < 0.01)
        }

        @Test
        func `LAB to sRGB - mid gray`() {

            let lab = LAB(l: 50, a: 0, b: 0)
            let srgb = lab.converted(to: sRGB.self)

            #expect(abs(srgb.r - srgb.g) < 0.01)
            #expect(abs(srgb.g - srgb.b) < 0.01)

            #expect(srgb.r > 0.1 && srgb.r < 0.5)
        }

        @Test
        func `sRGB to LAB - red`() {
            let srgb = sRGB.red
            let lab = srgb.converted(to: LAB.self)

            #expect(lab.l > 50 && lab.l < 60)
            #expect(lab.a > 70)
            #expect(lab.b > 50)
        }

        @Test
        func `sRGB to LAB - green`() {
            let srgb = sRGB.green
            let lab = srgb.converted(to: LAB.self)

            #expect(lab.l > 80)
            #expect(lab.a < 0)
            #expect(lab.b > 50)
        }

        @Test
        func `sRGB to LAB - blue`() {
            let srgb = sRGB.blue
            let lab = srgb.converted(to: LAB.self)

            #expect(lab.l > 25 && lab.l < 40)
            #expect(lab.a > 50)
            #expect(lab.b < -80)
        }

        @Test
        func `LCH round-trip`() {
            let original = LCH(l: 60, c: 50, h: 120)
            let color = original.canonical()
            let roundTrip = LCH(color)

            #expect(abs(roundTrip.l - original.l) < 0.01)
            #expect(abs(roundTrip.c - original.c) < 0.01)

            let hueDiff = abs(roundTrip.h - original.h)
            #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
        }

        @Test
        func `LAB to LCH conversion`() {
            let lab = LAB(l: 50, a: 25, b: 25)
            let lch = LCH(lab)

            #expect(abs(lch.l - 50) < 0.01)

            #expect(abs(lch.c - 35.36) < 0.1)

            #expect(abs(lch.h - 45) < 0.1)
        }

        @Test
        func `LCH to LAB conversion`() {
            let lch = LCH(l: 50, c: 50, h: 90)
            let lab = lch.lab

            #expect(abs(lab.l - 50) < 0.01)

            #expect(abs(lab.a) < 0.01)

            #expect(abs(lab.b - 50) < 0.01)
        }

        @Test
        func `LAB converted(to:) convenience method`() {
            let lab = LAB(l: 50, a: 20, b: -30)
            let roundTrip = lab.converted(to: LAB.self)

            #expect(abs(roundTrip.l - lab.l) < 0.01)
            #expect(abs(roundTrip.a - lab.a) < 0.01)
            #expect(abs(roundTrip.b - lab.b) < 0.01)
        }

        @Test
        func `LCH converted(to:) convenience method`() {
            let lch = LCH(l: 60, c: 40, h: 180)
            let roundTrip = lch.converted(to: LCH.self)

            #expect(abs(roundTrip.l - lch.l) < 0.01)
            #expect(abs(roundTrip.c - lch.c) < 0.01)
            let hueDiff = abs(roundTrip.h - lch.h)
            #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
        }

        @Test
        func `LAB Lightness typed component`() throws {
            let lightness = try LAB.Lightness(50)
            #expect(lightness.value == 50)

            let clamped = LAB.Lightness(clamping: 150)
            #expect(clamped.value == 100)

            #expect(throws: LAB.Lightness.Error.self) {
                _ = try LAB.Lightness(-10)
            }
        }
    }
}
