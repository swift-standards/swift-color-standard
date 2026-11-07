import ISO_9899


extension Color.Oklab {
    public struct Lightness: Sendable, Hashable {

        public let value: Double

        public init(_ value: Double) throws(Error) {
            guard value >= 0 && value <= 1 else {
                throw Error(value: value)
            }
            self.value = value
        }

        public init(clamping value: Double) {
            self.value = value.clamped(to: 0...1)
        }
    }
}
