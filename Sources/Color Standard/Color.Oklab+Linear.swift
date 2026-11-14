public import ISO_9899

extension Color.Oklab {

    /// The place in Oklab (Ottosson 2020) of a linear sRGB colour, in any binary floating-point precision:
    /// linear light to cone responses by Ottosson's first matrix, a cube root of each, then to L, a and b by his
    /// second matrix. Components are taken as they are, unclamped; the cube root of a negative response is
    /// negative. The cube root is worked in `Double` and rounded to `Value`. `Color.Oklab.init(_:)` reaches
    /// Oklab through this, so for `Double` the two agree bit for bit on the same linear components.
    @inlinable
    public static func coordinates<Value: BinaryFloatingPoint>(
        red: Value,
        green: Value,
        blue: Value
    ) -> (l: Value, a: Value, b: Value) {
        let l = 0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue
        let m = 0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue
        let s = 0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue

        let l_ = Value(ISO_9899.Math.cbrt(Double(l)))
        let m_ = Value(ISO_9899.Math.cbrt(Double(m)))
        let s_ = Value(ISO_9899.Math.cbrt(Double(s)))

        return (
            l: 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
            a: 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
            b: 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
        )
    }

    /// The linear sRGB colour at a place in Oklab, in any binary floating-point precision: the inverse of
    /// `coordinates(red:green:blue:)` to the digits of Ottosson's inverse matrices, unclamped, so a place outside
    /// sRGB gives components outside 0 to 1. `Color.Oklab.canonical()` goes through this.
    @inlinable
    public static func linear<Value: BinaryFloatingPoint>(
        l: Value,
        a: Value,
        b: Value
    ) -> (red: Value, green: Value, blue: Value) {
        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b

        let cubed = (l: l_ * l_ * l_, m: m_ * m_ * m_, s: s_ * s_ * s_)

        return (
            red: +4.0767416621 * cubed.l - 3.3077115913 * cubed.m + 0.2309699292 * cubed.s,
            green: -1.2684380046 * cubed.l + 2.6097574011 * cubed.m - 0.3413193965 * cubed.s,
            blue: -0.0041960863 * cubed.l - 0.7034186147 * cubed.m + 1.7076147010 * cubed.s
        )
    }
}
