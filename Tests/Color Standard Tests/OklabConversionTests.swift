import Testing

@testable import Color_Standard

extension Color.Oklab {
    @Suite("Oklab Conversion Tests")
    struct Test {
        typealias Oklab = Color.Oklab
        typealias Oklch = Color.Oklch
        typealias sRGB = IEC_61966.`2`.`1`.sRGB

        @Test
        func `Oklab black round-trip`() {
            let original = Oklab.black
            let color = original.canonical()
            let roundTrip = Oklab(color)

            #expect(abs(roundTrip.l - original.l) < 0.001)
            #expect(abs(roundTrip.a - original.a) < 0.001)
            #expect(abs(roundTrip.b - original.b) < 0.001)
        }

        @Test
        func `Oklab white round-trip`() {
            let original = Oklab.white
            let color = original.canonical()
            let roundTrip = Oklab(color)

            #expect(abs(roundTrip.l - original.l) < 0.001)
            #expect(abs(roundTrip.a - original.a) < 0.001)
            #expect(abs(roundTrip.b - original.b) < 0.001)
        }

        @Test
        func `Oklab arbitrary color round-trip`() {
            let original = Oklab(l: 0.6, a: 0.1, b: -0.1)
            let color = original.canonical()
            let roundTrip = Oklab(color)

            #expect(abs(roundTrip.l - original.l) < 0.001)
            #expect(abs(roundTrip.a - original.a) < 0.001)
            #expect(abs(roundTrip.b - original.b) < 0.001)
        }

        @Test
        func `Oklab to sRGB - black`() {
            let oklab = Oklab(l: 0, a: 0, b: 0)
            let srgb = oklab.converted(to: sRGB.self)

            #expect(abs(srgb.r - 0) < 0.01)
            #expect(abs(srgb.g - 0) < 0.01)
            #expect(abs(srgb.b - 0) < 0.01)
        }

        @Test
        func `Oklab to sRGB - white`() {
            let oklab = Oklab(l: 1, a: 0, b: 0)
            let srgb = oklab.converted(to: sRGB.self)

            #expect(abs(srgb.r - 1) < 0.01)
            #expect(abs(srgb.g - 1) < 0.01)
            #expect(abs(srgb.b - 1) < 0.01)
        }

        @Test
        func `Oklab to sRGB - mid gray`() {

            let oklab = Oklab(l: 0.5, a: 0, b: 0)
            let srgb = oklab.converted(to: sRGB.self)

            #expect(abs(srgb.r - srgb.g) < 0.01)
            #expect(abs(srgb.g - srgb.b) < 0.01)

            #expect(srgb.r > 0.1 && srgb.r < 0.5)
        }

        @Test
        func `sRGB to Oklab - red`() {
            let srgb = sRGB.red
            let oklab = srgb.converted(to: Oklab.self)

            #expect(oklab.l > 0.6 && oklab.l < 0.7)
            #expect(oklab.a > 0.2)
            #expect(oklab.b > 0.1)
        }

        @Test
        func `sRGB to Oklab - green`() {
            let srgb = sRGB.green
            let oklab = srgb.converted(to: Oklab.self)

            #expect(oklab.l > 0.8)
            #expect(oklab.a < 0)
            #expect(oklab.b > 0.1)
        }

        @Test
        func `sRGB to Oklab - blue`() {
            let srgb = sRGB.blue
            let oklab = srgb.converted(to: Oklab.self)

            #expect(oklab.l > 0.4 && oklab.l < 0.5)
            #expect(oklab.b < -0.25)
        }

        @Test
        func `Oklch round-trip`() {
            let original = Oklch(l: 0.7, c: 0.15, h: 120)
            let color = original.canonical()
            let roundTrip = Oklch(color)

            #expect(abs(roundTrip.l - original.l) < 0.001)
            #expect(abs(roundTrip.c - original.c) < 0.001)

            let hueDiff = abs(roundTrip.h - original.h)
            #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
        }

        @Test
        func `Oklab to Oklch conversion`() {
            let oklab = Oklab(l: 0.5, a: 0.1, b: 0.1)
            let oklch = Oklch(oklab)

            #expect(abs(oklch.l - 0.5) < 0.001)

            #expect(abs(oklch.c - 0.1414) < 0.01)

            #expect(abs(oklch.h - 45) < 0.1)
        }

        @Test
        func `Oklch to Oklab conversion`() {
            let oklch = Oklch(l: 0.5, c: 0.2, h: 90)
            let oklab = oklch.oklab

            #expect(abs(oklab.l - 0.5) < 0.001)

            #expect(abs(oklab.a) < 0.001)

            #expect(abs(oklab.b - 0.2) < 0.001)
        }

        @Test
        func `sRGB -> Oklab -> sRGB round-trip`() {
            let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
            let oklab = original.converted(to: Oklab.self)
            let roundTrip = oklab.converted(to: sRGB.self)

            #expect(abs(roundTrip.r - original.r) < 0.01)
            #expect(abs(roundTrip.g - original.g) < 0.01)
            #expect(abs(roundTrip.b - original.b) < 0.01)
        }

        @Test
        func `sRGB -> Oklch -> sRGB round-trip`() {
            let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
            let oklch = original.converted(to: Oklch.self)
            let roundTrip = oklch.converted(to: sRGB.self)

            #expect(abs(roundTrip.r - original.r) < 0.01)
            #expect(abs(roundTrip.g - original.g) < 0.01)
            #expect(abs(roundTrip.b - original.b) < 0.01)
        }

        @Test
        func `Oklab converted(to:) convenience method`() {
            let oklab = Oklab(l: 0.6, a: 0.1, b: -0.1)
            let roundTrip = oklab.converted(to: Oklab.self)

            #expect(abs(roundTrip.l - oklab.l) < 0.001)
            #expect(abs(roundTrip.a - oklab.a) < 0.001)
            #expect(abs(roundTrip.b - oklab.b) < 0.001)
        }

        @Test
        func `Oklch converted(to:) convenience method`() {
            let oklch = Oklch(l: 0.7, c: 0.15, h: 180)
            let roundTrip = oklch.converted(to: Oklch.self)

            #expect(abs(roundTrip.l - oklch.l) < 0.001)
            #expect(abs(roundTrip.c - oklch.c) < 0.001)
            let hueDiff = abs(roundTrip.h - oklch.h)
            #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
        }

        @Test
        func `Oklab Lightness typed component`() throws {
            let lightness = try Oklab.Lightness(0.5)
            #expect(lightness.value == 0.5)

            let clamped = Oklab.Lightness(clamping: 1.5)
            #expect(clamped.value == 1)

            #expect(throws: Oklab.Lightness.Error.self) {
                _ = try Oklab.Lightness(-0.1)
            }
        }
    }
}
