public import ISO_11664

extension ISO_11664.Tristimulus: _ColorProtocol {

    /// The colour these tristimulus values are, read relative to D65 with the white's Y at 1: the values `Color`
    /// itself holds, so nothing is converted.
    public func canonical() -> Color {
        Color(_xyz: Color._XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    /// The tristimulus values of a colour relative to D65 with the white's Y at 1; a colour held relative to D50
    /// is adapted first, by Bradford.
    public init(_ color: Color) {
        let xyz =
            color._xyz.illuminant == .d65
            ? color._xyz
            : color._xyz.adapted(to: .d65)
        self.init(x: xyz.x, y: xyz.y, z: xyz.z)
    }
}
