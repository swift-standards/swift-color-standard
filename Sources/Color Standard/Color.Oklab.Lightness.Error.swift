import ISO_9899

extension Color.Oklab.Lightness {
    public struct Error: Swift::Error, Sendable, CustomStringConvertible {
        public let value: Double
    }
}
