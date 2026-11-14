extension Color.Spectrum {
    /// A wavelength's share of linear red, green and blue.
    public struct Weight: Sendable, Hashable {
        public var red: Double
        public var green: Double
        public var blue: Double

        public init(red: Double, green: Double, blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    }
}
