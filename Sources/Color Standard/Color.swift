import ISO_9899

public struct Color: Sendable, Hashable {

    internal var _xyz: _XYZ

    internal var _alpha: Double

    internal init(_xyz: _XYZ, _alpha: Double = 1.0) {
        self._xyz = _xyz
        self._alpha = _alpha.clamped(to: 0...1)
    }
}

extension Color {

    public var alpha: Double { _alpha }

    public func withAlpha(_ alpha: Double) -> Color {
        Color(_xyz: _xyz, _alpha: alpha)
    }
}

extension Color {

    public static let black = Color(_xyz: _XYZ.d65Black, _alpha: 1.0)

    public static let white = Color(_xyz: _XYZ.d65White, _alpha: 1.0)

    public static let clear = Color(_xyz: _XYZ.d65Black, _alpha: 0.0)
}

extension Color: CustomDebugStringConvertible {

    public var debugDescription: String {
        let rgb = _debugRGBA
        return "Color(r: \(rgb.r), g: \(rgb.g), b: \(rgb.b), a: \(rgb.a))"
    }

    public var _debugRGBA: (r: Double, g: Double, b: Double, a: Double) {
        let m = _XYZ.xyzToSRGB
        let xyz = _xyz

        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        func encode(_ linear: Double) -> Double {
            let clamped = linear.clamped(to: 0...1)
            if clamped <= 0.0031308 {
                return 12.92 * clamped
            } else {
                return 1.055 * ISO_9899.Math.pow(clamped, 1.0 / 2.4) - 0.055
            }
        }

        return (
            r: encode(lr),
            g: encode(lg),
            b: encode(lb),
            a: _alpha
        )
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
