import ISO_9899

extension Color.Oklab: Color.`Protocol` {

    public func canonical() -> Color {
        Color._fromOklab(self)
    }

    public init(_ color: Color) {
        self = Color._toOklab(color)
    }
}

extension Color {

    internal static func _fromOklab(_ oklab: Oklab) -> Color {

        let l_ = oklab.l + 0.3963377774 * oklab.a + 0.2158037573 * oklab.b

        let m_ = oklab.l - 0.1055613458 * oklab.a - 0.0638541728 * oklab.b

        let s_ = oklab.l - 0.0894841775 * oklab.a - 1.2914855480 * oklab.b

        let l = l_ * l_ * l_
        let m = m_ * m_ * m_
        let s = s_ * s_ * s_

        let lr = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let lg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let lb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

        let xyz = _XYZ.sRGBToXYZ
        let x = xyz.0.0 * lr + xyz.0.1 * lg + xyz.0.2 * lb
        let y = xyz.1.0 * lr + xyz.1.1 * lg + xyz.1.2 * lb
        let z = xyz.2.0 * lr + xyz.2.1 * lg + xyz.2.2 * lb

        return Color(_xyz: _XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    internal static func _toOklab(_ color: Color) -> Oklab {

        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)

        let m = _XYZ.xyzToSRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        let l = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb
        let ms = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb
        let s = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb

        let l_ = ISO_9899.Math.cbrt(l)

        let m_ = ISO_9899.Math.cbrt(ms)

        let s_ = ISO_9899.Math.cbrt(s)

        let L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
        let a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
        let b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

        return Oklab(l: L, a: a, b: b)
    }
}
