import ISO_9899

extension Color {

    internal struct _XYZ: Sendable, Hashable {

        var x: Double

        var y: Double

        var z: Double

        var illuminant: _Illuminant

        init(x: Double, y: Double, z: Double, illuminant: _Illuminant = .d65) {
            self.x = x
            self.y = y
            self.z = z
            self.illuminant = illuminant
        }
    }
}

extension Color._XYZ {

    static let d65White = Color._XYZ(x: 0.95047, y: 1.0, z: 1.08883, illuminant: .d65)

    static let d65Black = Color._XYZ(x: 0, y: 0, z: 0, illuminant: .d65)
}

extension Color {

    internal enum _Illuminant: Sendable, Hashable {

        case d65

        case d50
    }
}

extension Color._XYZ {

    private static let bradfordM:
        (
            (Double, Double, Double),
            (Double, Double, Double),
            (Double, Double, Double)
        ) = (
            (0.8951, 0.2664, -0.1614),
            (-0.7502, 1.7135, 0.0367),
            (0.0389, -0.0685, 1.0296)
        )

    private static let bradfordMInv:
        (
            (Double, Double, Double),
            (Double, Double, Double),
            (Double, Double, Double)
        ) = (
            (0.9869929, -0.1470543, 0.1599627),
            (0.4323053, 0.5183603, 0.0492912),
            (-0.0085287, 0.0400428, 0.9684867)
        )

    private static let d65LMS: (Double, Double, Double) = (0.9414285350, 1.040417467, 1.089532651)

    private static let d50LMS: (Double, Double, Double) = (0.9962844280, 1.020427363, 0.818644374)

    func adapted(to target: Color._Illuminant) -> Color._XYZ {
        guard illuminant != target else { return self }

        let srcLMS: (Double, Double, Double)
        let dstLMS: (Double, Double, Double)

        switch (illuminant, target) {
        case (.d65, .d50):
            srcLMS = Self.d65LMS
            dstLMS = Self.d50LMS

        case (.d50, .d65):
            srcLMS = Self.d50LMS
            dstLMS = Self.d65LMS

        default:
            return self
        }

        let m = Self.bradfordM
        let l = m.0.0 * x + m.0.1 * y + m.0.2 * z
        let ms = m.1.0 * x + m.1.1 * y + m.1.2 * z
        let s = m.2.0 * x + m.2.1 * y + m.2.2 * z

        let lAdapt = l * (dstLMS.0 / srcLMS.0)
        let mAdapt = ms * (dstLMS.1 / srcLMS.1)
        let sAdapt = s * (dstLMS.2 / srcLMS.2)

        let mInv = Self.bradfordMInv
        let xAdapt = mInv.0.0 * lAdapt + mInv.0.1 * mAdapt + mInv.0.2 * sAdapt
        let yAdapt = mInv.1.0 * lAdapt + mInv.1.1 * mAdapt + mInv.1.2 * sAdapt
        let zAdapt = mInv.2.0 * lAdapt + mInv.2.1 * mAdapt + mInv.2.2 * sAdapt

        return Color._XYZ(x: xAdapt, y: yAdapt, z: zAdapt, illuminant: target)
    }
}

extension Color._XYZ {

    static let sRGBToXYZ:
        (
            (Double, Double, Double),
            (Double, Double, Double),
            (Double, Double, Double)
        ) = (
            (0.4124564, 0.3575761, 0.1804375),
            (0.2126729, 0.7151522, 0.0721750),
            (0.0193339, 0.1191920, 0.9503041)
        )

    static let xyzToSRGB:
        (
            (Double, Double, Double),
            (Double, Double, Double),
            (Double, Double, Double)
        ) = (
            (3.2404542, -1.5371385, -0.4985314),
            (-0.9692660, 1.8760108, 0.0415560),
            (0.0556434, -0.2040259, 1.0572252)
        )
}
