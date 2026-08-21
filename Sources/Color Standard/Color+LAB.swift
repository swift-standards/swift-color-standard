import ISO_9899

extension Color.LAB: Color.`Protocol` {

    public func canonical() -> Color {
        Color._fromLAB(self)
    }

    public init(_ color: Color) {
        self = Color._toLAB(color)
    }
}

extension Color {

    internal static func _fromLAB(_ lab: LAB) -> Color {

        let epsilon: Double = 216.0 / 24389.0
        let kappa: Double = 24389.0 / 27.0

        let xn: Double = 0.96422
        let yn: Double = 1.0
        let zn: Double = 0.82521

        let fy = (lab.l + 16.0) / 116.0
        let fx = lab.a / 500.0 + fy
        let fz = fy - lab.b / 200.0

        let fx3 = fx * fx * fx
        let fz3 = fz * fz * fz

        let xr = fx3 > epsilon ? fx3 : (116.0 * fx - 16.0) / kappa
        let yr =
            lab.l > kappa * epsilon ? ISO_9899.Math.pow((lab.l + 16.0) / 116.0, 3) : lab.l / kappa
        let zr = fz3 > epsilon ? fz3 : (116.0 * fz - 16.0) / kappa

        let x = xr * xn
        let y = yr * yn
        let z = zr * zn

        return Color(_xyz: _XYZ(x: x, y: y, z: z, illuminant: .d50), _alpha: 1.0)
    }

    internal static func _toLAB(_ color: Color) -> LAB {

        let xyz =
            color._xyz.illuminant == .d50
            ? color._xyz
            : color._xyz.adapted(to: .d50)

        let epsilon: Double = 216.0 / 24389.0
        let kappa: Double = 24389.0 / 27.0

        let xn: Double = 0.96422
        let yn: Double = 1.0
        let zn: Double = 0.82521

        let xr = xyz.x / xn
        let yr = xyz.y / yn
        let zr = xyz.z / zn

        func f(_ t: Double) -> Double {
            if t > epsilon {
                return ISO_9899.Math.cbrt(t)
            } else {
                return (kappa * t + 16.0) / 116.0
            }
        }

        let fx = f(xr)
        let fy = f(yr)
        let fz = f(zr)

        let l = 116.0 * fy - 16.0
        let a = 500.0 * (fx - fy)
        let b = 200.0 * (fy - fz)

        return LAB(l: l, a: a, b: b)
    }
}

extension Color._XYZ {

    static let d50White = Color._XYZ(x: 0.96422, y: 1.0, z: 0.82521, illuminant: .d50)
}
