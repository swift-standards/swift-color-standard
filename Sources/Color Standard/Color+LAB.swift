// Color+LAB.swift
// CIE LAB conformance to Color.Protocol

import ISO_9899

// MARK: - LAB Conformance to Color.Protocol

extension Color.LAB: Color.`Protocol` {
    /// Converts LAB to canonical color representation.
    ///
    /// The conversion:
    /// 1. Converts LAB to XYZ (D50 illuminant)
    /// 2. Stores in canonical `Color` representation
    ///
    /// - Returns: Canonical color representation
    public func canonical() -> Color {
        Color._fromLAB(self)
    }

    /// Creates LAB from canonical color representation.
    ///
    /// The conversion:
    /// 1. Adapts XYZ to D50 illuminant if needed
    /// 2. Converts XYZ to LAB
    ///
    /// - Parameter color: Canonical color to convert from
    public init(_ color: Color) {
        self = Color._toLAB(color)
    }
}

// MARK: - Static Implementation

extension Color {
    /// Converts LAB to XYZ (D50).
    ///
    /// Implementation follows CIE Publication 15:2004.
    ///
    /// - Parameter lab: LAB color to convert
    /// - Returns: Canonical color representation
    internal static func _fromLAB(_ lab: LAB) -> Color {
        // LAB to XYZ conversion constants
        let epsilon: Double = 216.0 / 24389.0  // 0.008856
        let kappa: Double = 24389.0 / 27.0  // 903.3

        // D50 reference white point
        let xn: Double = 0.96422
        let yn: Double = 1.0
        let zn: Double = 0.82521

        // Calculate f(Y)
        let fy = (lab.l + 16.0) / 116.0
        let fx = lab.a / 500.0 + fy
        let fz = fy - lab.b / 200.0

        // Calculate X, Y, Z
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

    /// Converts XYZ to LAB.
    ///
    /// Implementation follows CIE Publication 15:2004.
    ///
    /// - Parameter color: Canonical color to convert
    /// - Returns: LAB color
    internal static func _toLAB(_ color: Color) -> LAB {
        // Ensure D50 illuminant for LAB
        let xyz =
            color._xyz.illuminant == .d50
            ? color._xyz
            : color._xyz.adapted(to: .d50)

        // LAB to XYZ conversion constants
        let epsilon: Double = 216.0 / 24389.0  // 0.008856
        let kappa: Double = 24389.0 / 27.0  // 903.3

        // D50 reference white point
        let xn: Double = 0.96422
        let yn: Double = 1.0
        let zn: Double = 0.82521

        // Normalize to reference white
        let xr = xyz.x / xn
        let yr = xyz.y / yn
        let zr = xyz.z / zn

        // f(t) function
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

// MARK: - D50 White Point Constants

extension Color._XYZ {
    /// D50 white point (ICC PCS illuminant, horizon light ~5000K)
    ///
    /// Per ICC Profile specification:
    /// - x = 0.3457, y = 0.3585
    /// - XYZ: (0.96422, 1.0, 0.82521) normalized to Y=1
    static let d50White = Color._XYZ(x: 0.96422, y: 1.0, z: 0.82521, illuminant: .d50)
}
