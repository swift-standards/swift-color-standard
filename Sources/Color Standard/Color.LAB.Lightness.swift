import ISO_9899

extension Color.LAB {
    public struct Lightness: Sendable, Hashable {

        public let value: Double

        public init(_ value: Double) throws(Error) {
            guard value >= 0 && value <= 100 else {
                throw Error(value: value)
            }
            self.value = value
        }

        public init(clamping value: Double) {
            self.value = value.clamped(to: 0...100)
        }
    }
}
