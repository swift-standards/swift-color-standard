public import IEC_61966
import ISO_9899

extension IEC_61966.`2`.`1`.sRGB: Color.`Protocol` {

    public func canonical() -> Color {
        Color._fromSRGB(self)
    }

    public init(_ color: Color) {
        self = Color._toSRGB(color)
    }
}

extension Color {

    internal static func _fromSRGB(_ srgb: IEC_61966.`2`.`1`.sRGB) -> Color {

        let linear = srgb.linear

        let m = _XYZ.sRGBToXYZ
        let lr = linear.r.value
        let lg = linear.g.value
        let lb = linear.b.value

        let x = m.0.0 * lr + m.0.1 * lg + m.0.2 * lb
        let y = m.1.0 * lr + m.1.1 * lg + m.1.2 * lb
        let z = m.2.0 * lr + m.2.1 * lg + m.2.2 * lb

        return Color(_xyz: _XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    internal static func _toSRGB(_ color: Color) -> IEC_61966.`2`.`1`.sRGB {

        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)

        let m = _XYZ.xyzToSRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        let linear = IEC_61966.`2`.`1`.LinearSRGB(r: lr, g: lg, b: lb)

        return linear.encoded
    }
}

extension IEC_61966.`2`.`1`.LinearSRGB: Color.`Protocol` {

    public func canonical() -> Color {
        let m = Color._XYZ.sRGBToXYZ
        let lr = r.value
        let lg = g.value
        let lb = b.value

        let x = m.0.0 * lr + m.0.1 * lg + m.0.2 * lb
        let y = m.1.0 * lr + m.1.1 * lg + m.1.2 * lb
        let z = m.2.0 * lr + m.2.1 * lg + m.2.2 * lb

        return Color(_xyz: Color._XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    public init(_ color: Color) {

        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)

        let m = Color._XYZ.xyzToSRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        self.init(r: lr, g: lg, b: lb)
    }
}
