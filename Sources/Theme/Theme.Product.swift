public import Dimension

extension Theme {

    public struct Product<Value> {

        public var light: Value

        public var dark: Value

        @inlinable
        public init(light: Value, dark: Value) {
            self.light = light
            self.dark = dark
        }

        @inlinable
        public init(uniform value: Value) {
            self.light = value
            self.dark = value
        }
    }
}

extension Theme.Product {

    @inlinable
    public subscript(theme: Theme) -> Value {
        get {
            switch theme {
            case .light: return light
            case .dark: return dark
            default: fatalError("Invalid theme ordinal: \(theme.ordinal)")
            }
        }
        set {
            switch theme {
            case .light: light = newValue
            case .dark: dark = newValue
            default: fatalError("Invalid theme ordinal: \(theme.ordinal)")
            }
        }
    }
}

extension Theme.Product {

    @inlinable
    public static func map<NewValue, E: Swift.Error>(
        _ product: Theme.Product<Value>,
        transform: (Value) throws(E) -> NewValue
    ) throws(E) -> Theme.Product<NewValue> {
        Theme.Product<NewValue>(
            light: try transform(product.light),
            dark: try transform(product.dark)
        )
    }

    @inlinable
    public static func mapWithTheme<NewValue, E: Swift.Error>(
        _ product: Theme.Product<Value>,
        transform: (Theme, Value) throws(E) -> NewValue
    ) throws(E) -> Theme.Product<NewValue> {
        Theme.Product<NewValue>(
            light: try transform(.light, product.light),
            dark: try transform(.dark, product.dark)
        )
    }
}

extension Theme.Product {

    @inlinable
    public func map<NewValue, E: Swift.Error>(
        _ transform: (Value) throws(E) -> NewValue
    ) throws(E) -> Theme.Product<NewValue> {
        try Self.map(self, transform: transform)
    }

    @inlinable
    public func mapWithTheme<NewValue, E: Swift.Error>(
        _ transform: (Theme, Value) throws(E) -> NewValue
    ) throws(E) -> Theme.Product<NewValue> {
        try Self.mapWithTheme(self, transform: transform)
    }
}

extension Theme.Product {

    @inlinable
    public static func zip<A, B>(
        _ a: Theme.Product<A>,
        _ b: Theme.Product<B>
    ) -> Theme.Product<(A, B)> where Value == (A, B) {
        Theme.Product<(A, B)>(
            light: (a.light, b.light),
            dark: (a.dark, b.dark)
        )
    }

    @inlinable
    public static func zipWith<A, B, E: Swift.Error>(
        _ a: Theme.Product<A>,
        _ b: Theme.Product<B>,
        combine: (A, B) throws(E) -> Value
    ) throws(E) -> Theme.Product<Value> {
        Theme.Product(
            light: try combine(a.light, b.light),
            dark: try combine(a.dark, b.dark)
        )
    }
}

extension Theme.Product: Sendable where Value: Sendable {}
extension Theme.Product: Equatable where Value: Equatable {}
extension Theme.Product: Hashable where Value: Hashable {}

extension Theme.Product {

    @inlinable
    public var values: [Value] {
        [light, dark]
    }

    @inlinable
    public init(values: [Value]) {
        precondition(values.count == 2, "Array must have exactly 2 elements")
        self.light = values[0]
        self.dark = values[1]
    }
}
