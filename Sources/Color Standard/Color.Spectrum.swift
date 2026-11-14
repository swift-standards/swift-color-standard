public import Cardinal
public import ISO_11664

extension Color {
    /// A range of wavelengths sampled at equal steps, each with the share of linear sRGB red, green and blue it
    /// gives. Light parted by wavelength and read once per wavelength is gathered back into one linear colour by
    /// these shares: each colour the sum of its reads times its weights.
    public struct Spectrum: Sendable, Hashable {
        /// The wavelengths in nanometres, from short to long.
        public let wavelengths: [Double]

        /// For each wavelength, its share of red, green and blue.
        public let weights: [Weight]
    }
}

extension Color.Spectrum {
    /// `count` wavelengths at the midpoints of as many equal parts of `range`, in nanometres, each weighted by
    /// `response(at:observer:)` and every colour's weights divided by their sum, so each colour's weights add up
    /// to 1 and a flat white is gathered back to white. A colour whose responses sum to 0 gets weight 0
    /// throughout. A count of zero, or one too large for an `Int`, gives no wavelengths.
    public init(sampling range: ClosedRange<Double>, count: Cardinal, observer: ISO_11664.Observer) {
        guard let count = Int(exactly: count), count > 0 else {
            self.init(wavelengths: [], weights: [])
            return
        }
        let low = range.lowerBound
        let width = range.upperBound - low
        let wavelengths = (0..<count).map { low + width * (Double($0) + 0.5) / Double(count) }
        let raw = wavelengths.map { Self.response(at: $0, observer: observer) }
        let total = raw.reduce((0.0, 0.0, 0.0)) { ($0.0 + $1.red, $0.1 + $1.green, $0.2 + $1.blue) }
        let weights = raw.map {
            Weight(
                red: total.0 > 0 ? $0.red / total.0 : 0,
                green: total.1 > 0 ? $0.green / total.1 : 0,
                blue: total.2 > 0 ? $0.blue / total.2 : 0
            )
        }
        self.init(wavelengths: wavelengths, weights: weights)
    }

    /// How much a wavelength in nanometres excites linear sRGB red, green and blue: the observer's
    /// colour-matching functions taken from XYZ to linear sRGB by IEC 61966-2-1's forward matrix, each held at
    /// 0 or more.
    public static func response(
        at nanometres: Double,
        observer: ISO_11664.Observer
    ) -> (red: Double, green: Double, blue: Double) {
        let xyz = observer.matching(at: nanometres)
        let m = IEC_61966.`2`.`1`.SRGB.Matrix.forward
        return (
            red: Swift.max(m[0][0] * xyz.x + m[0][1] * xyz.y + m[0][2] * xyz.z, 0),
            green: Swift.max(m[1][0] * xyz.x + m[1][1] * xyz.y + m[1][2] * xyz.z, 0),
            blue: Swift.max(m[2][0] * xyz.x + m[2][1] * xyz.y + m[2][2] * xyz.z, 0)
        )
    }
}
