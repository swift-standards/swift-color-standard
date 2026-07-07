// Color.swift
// Color Standard — Unified color interchange

import ISO_9899

/// Canonical color representation for interchange between color standards.
///
/// `Color` serves as the hub for all color conversions. Any color type
/// conforming to `Color.Protocol` can convert to and from `Color`,
/// enabling interchange between different standards.
///
/// The internal representation is an implementation detail and may change.
///
/// Use this type as an opaque interchange format.
///
/// ## Supported Standards
/// - IEC 61966-2-1 (sRGB)
/// - W3C CSS Color Module (future)
/// - ISO 32000 PDF (future)
///
/// ## Example
///
/// ```swift
/// import IEC_61966
/// import Color_Standard
///
/// let srgb = IEC_61966.`2`.`1`.sRGB(r: 0.5, g: 0.3, b: 0.8)
/// let color = srgb.canonical()
///
/// // Convert to another format
/// let roundTrip = try IEC_61966.`2`.`1`.sRGB(color)
/// ```
///
/// ## Hub-and-Spoke Conversion
///
/// All conversions go through `Color`:
/// ```
/// Source → Color → Target
/// ```
///
/// This ensures consistency and minimizes the number of conversion
/// functions needed (n conversions instead of n×n).
public struct Color: Sendable, Hashable {
    // MARK: - Internal Storage (Hidden)

    /// Internal XYZ representation
    internal var _xyz: _XYZ

    /// Alpha/opacity component
    internal var _alpha: Double

    // MARK: - Initialization

    /// Creates a color from internal XYZ representation.
    ///
    /// - Parameters:
    ///   - xyz: Internal XYZ color
    ///   - alpha: Alpha component (0 = transparent, 1 = opaque)
    internal init(_xyz: _XYZ, _alpha: Double = 1.0) {
        self._xyz = _xyz
        self._alpha = _alpha.clamped(to: 0...1)
    }

    // MARK: - Public API (Stable)

    /// Alpha/opacity component (0 = transparent, 1 = opaque).
    public var alpha: Double { _alpha }

    /// Returns a copy with modified alpha.
    ///
    /// - Parameter alpha: New alpha value (clamped to 0...1)
    /// - Returns: New color with updated alpha
    public func withAlpha(_ alpha: Double) -> Color {
        Color(_xyz: _xyz, _alpha: alpha)
    }
}

// MARK: - Common Constants

extension Color {
    /// Black (no light).
    public static let black = Color(_xyz: _XYZ.d65Black, _alpha: 1.0)

    /// White (full light).
    public static let white = Color(_xyz: _XYZ.d65White, _alpha: 1.0)

    /// Transparent (invisible).
    public static let clear = Color(_xyz: _XYZ.d65Black, _alpha: 0.0)
}

// MARK: - Debug Support

extension Color: CustomDebugStringConvertible {
    /// Debug description showing approximate sRGB values.
    ///
    /// - Note: This is for debugging only. The actual representation may differ.
    public var debugDescription: String {
        let rgb = _debugRGBA
        return "Color(r: \(rgb.r), g: \(rgb.g), b: \(rgb.b), a: \(rgb.a))"
    }

    /// Approximate sRGB values for debugging.
    ///
    /// These values are clamped to the sRGB gamut and may not accurately
    /// represent colors outside that gamut.
    public var _debugRGBA: (r: Double, g: Double, b: Double, a: Double) {
        let m = _XYZ.xyzToSRGB
        let xyz = _xyz

        // XYZ → linear sRGB
        let lr = m.0.0 * xyz.x + m.0.1 * xyz.y + m.0.2 * xyz.z
        let lg = m.1.0 * xyz.x + m.1.1 * xyz.y + m.1.2 * xyz.z
        let lb = m.2.0 * xyz.x + m.2.1 * xyz.y + m.2.2 * xyz.z

        // Linear → sRGB (gamma encoding)
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

// MARK: - Helper

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
