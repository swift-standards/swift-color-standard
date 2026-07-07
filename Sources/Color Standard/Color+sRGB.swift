// Color+sRGB.swift
// IEC 61966-2-1 sRGB conformance to Color.Protocol

public import IEC_61966
import ISO_9899

// MARK: - sRGB Conformance

extension IEC_61966.`2`.`1`.sRGB: Color.`Protocol` {
    /// Converts sRGB to canonical color representation.
    ///
    /// The conversion:
    /// 1. Linearizes the sRGB values (removes gamma encoding)
    /// 2. Transforms linear RGB to CIE XYZ (D65)
    ///
    /// This conversion is lossless within the sRGB gamut.
    public func canonical() -> Color {
        Color._fromSRGB(self)
    }

    /// Creates sRGB from canonical color representation.
    ///
    /// The conversion:
    /// 1. Transforms XYZ (D65) to linear RGB
    /// 2. Applies gamma encoding
    /// 3. Clamps to [0, 1] range
    ///
    /// Colors outside the sRGB gamut will be clipped to the nearest
    /// representable color.
    ///
    /// - Parameter color: Canonical color to convert from
    public init(_ color: Color) {
        self = Color._toSRGB(color)
    }
}

// MARK: - Static Implementation

extension Color {
    /// Converts sRGB to XYZ (D65).
    ///
    /// Implementation follows IEC 61966-2-1:1999 Section 4.
    ///
    /// - Parameter srgb: sRGB color to convert
    /// - Returns: Canonical color representation
    internal static func _fromSRGB(_ srgb: IEC_61966.`2`.`1`.sRGB) -> Color {
        // 1. Linearize (remove gamma encoding)
        let linear = srgb.linear

        // 2. Apply sRGB → XYZ matrix (D65)
        let m = _XYZ.sRGBToXYZ
        let lr = linear.r.value
        let lg = linear.g.value
        let lb = linear.b.value

        let x = m.0.0 * lr + m.0.1 * lg + m.0.2 * lb
        let y = m.1.0 * lr + m.1.1 * lg + m.1.2 * lb
        let z = m.2.0 * lr + m.2.1 * lg + m.2.2 * lb

        return Color(_xyz: _XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    /// Converts XYZ to sRGB.
    ///
    /// Implementation follows IEC 61966-2-1:1999 Section 4.
    ///
    /// - Parameter color: Canonical color to convert
    /// - Returns: sRGB color (clamped to gamut)
    internal static func _toSRGB(_ color: Color) -> IEC_61966.`2`.`1`.sRGB {
        // Ensure D65 illuminant
        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)

        // 1. Apply XYZ → sRGB matrix (D65)
        let m = _XYZ.xyzToSRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        // 2. Create linear sRGB (clamping values)
        let linear = IEC_61966.`2`.`1`.LinearSRGB(r: lr, g: lg, b: lb)

        // 3. Apply gamma encoding
        return linear.encoded
    }
}

// MARK: - LinearSRGB Conformance

extension IEC_61966.`2`.`1`.LinearSRGB: Color.`Protocol` {
    /// Converts linear sRGB to canonical color representation.
    ///
    /// Linear sRGB values go directly to XYZ without gamma adjustment.
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

    /// Creates linear sRGB from canonical color representation.
    ///
    /// - Parameter color: Canonical color to convert from
    public init(_ color: Color) {
        // Ensure D65 illuminant
        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)

        // Apply XYZ → sRGB matrix (D65)
        let m = Color._XYZ.xyzToSRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        self.init(r: lr, g: lg, b: lb)
    }
}
