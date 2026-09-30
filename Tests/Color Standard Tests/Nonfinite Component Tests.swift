import Testing

@testable import Color_Standard

@Suite
struct `Nonfinite components` {
    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func `a LAB color with a nonfinite axis converts to terminal colors without trapping`(_ value: Double) {
        let color = Color.LAB(l: 50, a: value, b: 0).canonical()

        _ = color.sgr
        _ = color.sgr256
        _ = color.sgrPalette
        #expect(color._debugRGBA.r.isFinite)
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func `an Oklab color with a nonfinite axis converts to terminal colors without trapping`(_ value: Double) {
        let color = Color.Oklab(l: 0.5, a: 0, b: value).canonical()

        _ = color.sgr
        _ = color.sgr256
        _ = color.sgrPalette
        #expect(color._debugRGBA.b.isFinite)
    }
}
