// Color.XYZ.swift
// CIE 1931 XYZ color space — internal canonical representation

import ISO_9899

// MARK: - Internal XYZ Type

extension Color {
  /// CIE 1931 XYZ color space — internal canonical representation.
  ///
  /// XYZ is a device-independent color space that encompasses all
  /// visible colors. It serves as the mathematically rigorous foundation
  /// for color transformations.
  ///
  /// - Note: This is an implementation detail. Do not expose publicly.
  ///         The Canonical type provides the public interface.
  internal struct _XYZ: Sendable, Hashable {
    /// X tristimulus value (mix of cone response curves)
    var x: Double

    /// Y tristimulus value (luminance)
    var y: Double

    /// Z tristimulus value (quasi-equal to blue)
    var z: Double

    /// Reference illuminant
    var illuminant: _Illuminant

    /// Creates an XYZ color with the given components.
    init(x: Double, y: Double, z: Double, illuminant: _Illuminant = .d65) {
      self.x = x
      self.y = y
      self.z = z
      self.illuminant = illuminant
    }
  }
}

// MARK: - D65 White Point Constants

extension Color._XYZ {
  /// D65 white point (CIE standard illuminant, daylight ~6500K)
  ///
  /// Per IEC 61966-2-1:
  /// - x = 0.3127, y = 0.3290
  /// - XYZ: (0.95047, 1.0, 1.08883) normalized to Y=1
  static let d65White = Color._XYZ(x: 0.95047, y: 1.0, z: 1.08883, illuminant: .d65)

  /// Black point (no light)
  static let d65Black = Color._XYZ(x: 0, y: 0, z: 0, illuminant: .d65)
}

// MARK: - Illuminant

extension Color {
  /// Reference illuminant for color space white point.
  ///
  /// Different standards use different illuminants:
  /// - **D65**: sRGB, displays, CSS (daylight ~6500K)
  /// - **D50**: ICC PCS, print workflows (horizon light ~5000K)
  ///
  /// - Note: Internal implementation detail.
  internal enum _Illuminant: Sendable, Hashable {
    /// D65 — standard illuminant for sRGB and displays
    case d65

    /// D50 — standard illuminant for ICC Profile Connection Space
    case d50
  }
}

// MARK: - Chromatic Adaptation (Bradford Transform)

extension Color._XYZ {
  /// Bradford transformation matrix (XYZ to LMS cone response)
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

  /// Inverse Bradford matrix (LMS to XYZ)
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

  /// D65 white point in LMS (computed via Bradford matrix from D65 XYZ)
  private static let d65LMS: (Double, Double, Double) = (0.9414285350, 1.040417467, 1.089532651)

  /// D50 white point in LMS (computed via Bradford matrix from D50 XYZ)
  private static let d50LMS: (Double, Double, Double) = (0.9962844280, 1.020427363, 0.818644374)

  /// Adapts this XYZ color to a different illuminant using Bradford transform.
  ///
  /// - Parameter target: Target illuminant
  /// - Returns: XYZ color adapted to target illuminant
  func adapted(to target: Color._Illuminant) -> Color._XYZ {
    guard illuminant != target else { return self }

    // Get source and target LMS white points
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

    // XYZ → LMS
    let m = Self.bradfordM
    let l = m.0.0 * x + m.0.1 * y + m.0.2 * z
    let ms = m.1.0 * x + m.1.1 * y + m.1.2 * z
    let s = m.2.0 * x + m.2.1 * y + m.2.2 * z

    // Scale by adaptation ratio
    let lAdapt = l * (dstLMS.0 / srcLMS.0)
    let mAdapt = ms * (dstLMS.1 / srcLMS.1)
    let sAdapt = s * (dstLMS.2 / srcLMS.2)

    // LMS → XYZ
    let mInv = Self.bradfordMInv
    let xAdapt = mInv.0.0 * lAdapt + mInv.0.1 * mAdapt + mInv.0.2 * sAdapt
    let yAdapt = mInv.1.0 * lAdapt + mInv.1.1 * mAdapt + mInv.1.2 * sAdapt
    let zAdapt = mInv.2.0 * lAdapt + mInv.2.1 * mAdapt + mInv.2.2 * sAdapt

    return Color._XYZ(x: xAdapt, y: yAdapt, z: zAdapt, illuminant: target)
  }
}

// MARK: - sRGB Conversion Matrices

extension Color._XYZ {
  /// sRGB to XYZ matrix (D65)
  ///
  /// From IEC 61966-2-1:1999 Section 4.3
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

  /// XYZ to sRGB matrix (D65)
  ///
  /// Inverse of sRGBToXYZ matrix
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
