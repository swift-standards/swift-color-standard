import ISO_9899


extension Color.LAB.Lightness {
    public struct Error: Swift::Error, Sendable, CustomStringConvertible {
        public let value: Double
    }
}
