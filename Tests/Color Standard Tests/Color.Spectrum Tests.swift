import Cardinal
import ISO_11664
import ISO_9899
import Testing

@testable import Color_Standard

enum `Color.Spectrum Tests` {}

extension `Color.Spectrum Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension `Color.Spectrum Tests`.Test {
    /// The spectral weights as a dispersive-glass renderer worked them out before this type existed, copied
    /// here as the reference: the same fit, the printed sRGB forward matrix, midpoints of 400 to 700 nm, each
    /// colour's weights divided by their sum and rounded to `Float`.
    static func reference(count: Int) -> [(red: Float, green: Float, blue: Float)] {
        func response(_ wavelength: Double) -> (red: Double, green: Double, blue: Double) {
            func lobe(_ mean: Double, _ below: Double, _ above: Double) -> Double {
                let t = (wavelength - mean) / (wavelength < mean ? below : above)
                return ISO_9899.Math.exp(-0.5 * t * t)
            }
            let x =
                1.056 * lobe(599.8, 37.9, 31.0) + 0.362 * lobe(442.0, 16.0, 26.7) - 0.065 * lobe(501.1, 20.4, 26.2)
            let y = 0.821 * lobe(568.8, 46.9, 40.5) + 0.286 * lobe(530.9, 16.3, 31.1)
            let z = 1.217 * lobe(437.0, 11.8, 36.0) + 0.681 * lobe(459.0, 26.0, 13.8)
            return (
                Swift.max(3.2406 * x - 1.5372 * y - 0.4986 * z, 0),
                Swift.max(-0.9689 * x + 1.8758 * y + 0.0415 * z, 0),
                Swift.max(0.0557 * x - 0.2040 * y + 1.0570 * z, 0)
            )
        }
        let wavelengths = (0..<count).map { 400 + 300 * (Double($0) + 0.5) / Double(count) }
        let raw = wavelengths.map(response)
        let total = raw.reduce((0.0, 0.0, 0.0)) { ($0.0 + $1.red, $0.1 + $1.green, $0.2 + $1.blue) }
        return raw.map {
            (
                red: total.0 > 0 ? Float($0.red / total.0) : 0,
                green: total.1 > 0 ? Float($0.green / total.1) : 0,
                blue: total.2 > 0 ? Float($0.blue / total.2) : 0
            )
        }
    }
}

extension `Color.Spectrum Tests`.Test.Unit {

    @Test
    func `three wavelengths over 400 to 700 nm give the reference's literal weights`() {
        let spectrum = Color.Spectrum(sampling: 400...700, count: 3, observer: .analytic)
        #expect(spectrum.wavelengths == [450, 550, 650])
        let weights = spectrum.weights.map { [Float($0.red), Float($0.green), Float($0.blue)] }
        #expect(weights == [[0.188188061, 0, 1], [0, 1, 0], [0.811811924, 0, 0]])
    }

    @Test
    func `five wavelengths over 400 to 700 nm give the reference's literal weights`() {
        let spectrum = Color.Spectrum(sampling: 400...700, count: 5, observer: .analytic)
        #expect(spectrum.wavelengths == [430, 490, 550, 610, 670])
        let weights = spectrum.weights.map { [Float($0.red), Float($0.green), Float($0.blue)] }
        #expect(
            weights == [
                [0.0623365156, 0, 0.76608783],
                [0, 0.211243406, 0.233912185],
                [0, 0.788756609, 0],
                [0.864945471, 0, 0],
                [0.0727180094, 0, 0],
            ]
        )
    }

    @Test
    func `every count from 2 to 32 gives the reference's weights, rounded to Float`() {
        (2...32).forEach { count in
            let spectrum = Color.Spectrum(sampling: 400...700, count: Cardinal(UInt(count)), observer: .analytic)
            let expected = `Color.Spectrum Tests`.Test.reference(count: count)
            #expect(spectrum.weights.count == count)
            for (weight, reference) in zip(spectrum.weights, expected) {
                #expect(Float(weight.red) == reference.red, "count \(count)")
                #expect(Float(weight.green) == reference.green, "count \(count)")
                #expect(Float(weight.blue) == reference.blue, "count \(count)")
            }
        }
    }

    @Test
    func `each colour's weights add up to 1`() {
        for count in [2, 7, 16, 31] {
            let weights = Color.Spectrum(sampling: 380...780, count: Cardinal(UInt(count)), observer: .analytic).weights
            #expect(abs(weights.reduce(0) { $0 + $1.red } - 1) < 1e-12)
            #expect(abs(weights.reduce(0) { $0 + $1.green } - 1) < 1e-12)
            #expect(abs(weights.reduce(0) { $0 + $1.blue } - 1) < 1e-12)
        }
    }

    @Test
    func `weights are the response divided by its sum, and never negative`() {
        let spectrum = Color.Spectrum(sampling: 400...700, count: 9, observer: .analytic)
        let raw = spectrum.wavelengths.map { Color.Spectrum.response(at: $0, observer: .analytic) }
        let green = raw.reduce(0) { $0 + $1.green }
        for (weight, response) in zip(spectrum.weights, raw) {
            #expect(weight.green == response.green / green)
            #expect(weight.red >= 0 && weight.green >= 0 && weight.blue >= 0)
        }
    }

    @Test
    func `a colour with no response anywhere in the range gets weight 0`() {
        // Between 560 and 570 nm the fit's blue response is held at 0 throughout.
        let spectrum = Color.Spectrum(sampling: 560...570, count: 4, observer: .analytic)
        #expect(spectrum.weights.allSatisfy { $0.blue == 0 })
        #expect(abs(spectrum.weights.reduce(0) { $0 + $1.green } - 1) < 1e-12)
    }

    @Test
    func `a count of zero gives no wavelengths`() {
        let spectrum = Color.Spectrum(sampling: 400...700, count: 0, observer: .analytic)
        #expect(spectrum.wavelengths.isEmpty && spectrum.weights.isEmpty)
    }

    @Test
    func `the response is the forward matrix applied to the observer, held at 0`() {
        let xyz = ISO_11664.Observer.analytic.matching(at: 520)
        let m = IEC_61966.`2`.`1`.SRGB.Matrix.forward
        let response = Color.Spectrum.response(at: 520, observer: .analytic)
        #expect(response.green == m[1][0] * xyz.x + m[1][1] * xyz.y + m[1][2] * xyz.z)
        #expect(response.red == Swift.max(m[0][0] * xyz.x + m[0][1] * xyz.y + m[0][2] * xyz.z, 0))
    }
}
