extension Color.Oklab: _ColorProtocol {

    public func canonical() -> Color {
        Color._fromOklab(self)
    }

    public init(_ color: Color) {
        self = Color._toOklab(color)
    }
}

extension Color {

    internal static func _fromOklab(_ oklab: Oklab) -> Color {

        let linear = Oklab.linear(l: oklab.l, a: oklab.a, b: oklab.b)
        let lr = linear.red
        let lg = linear.green
        let lb = linear.blue

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

        let place = Oklab.coordinates(red: lr, green: lg, blue: lb)

        return Oklab(l: place.l, a: place.a, b: place.b)
    }
}
