public import IEC_61966

extension Color {

    /// The relative luminance of a linear sRGB colour, in any binary floating-point precision: its CIE Y, the
    /// middle row of IEC 61966-2-1's matrix from linear sRGB to XYZ, 0.2126 red + 0.7152 green + 0.0722 blue,
    /// each weight rounded to `Value`. Components are taken as they are, unclamped.
    @inlinable
    public static func luminance<Value: BinaryFloatingPoint>(red: Value, green: Value, blue: Value) -> Value {
        let weights = IEC_61966.`2`.`1`.SRGB.Matrix.reverse[1]
        return Value(weights[0]) * red + Value(weights[1]) * green + Value(weights[2]) * blue
    }
}
