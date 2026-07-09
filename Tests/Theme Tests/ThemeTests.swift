// ThemeTests.swift
// Tests for Theme and Theme.Product

import Cardinal_Primitives_Standard_Library_Integration
import Finite_Enumerable_Primitives
import Ordinal_Primitives_Standard_Library_Integration
import Testing

@testable import Theme

extension Theme {
    @Suite("Theme Tests")
    struct Test {
        // MARK: - Theme Cases

        @Test
        func `Theme has two cases`() {
            #expect(Theme.count == 2)
        }

        @Test
        func `Light theme has index 0`() {
            #expect(Theme.light.ordinal == 0)
        }

        @Test
        func `Dark theme has index 1`() {
            #expect(Theme.dark.ordinal == 1)
        }

        @Test
        func `Theme description`() {
            #expect(Theme.light.description == "light")
            #expect(Theme.dark.description == "dark")
        }

        @Test
        func `Theme equality`() {
            #expect(Theme.light == Theme.light)
            #expect(Theme.dark == Theme.dark)
            #expect(Theme.light != Theme.dark)
        }

        @Test
        func `Theme from ordinal round-trip`() {
            let light = Theme(0)
            let dark = Theme(1)
            #expect(light == .some(Theme.light))
            #expect(dark == .some(Theme.dark))
        }

        // MARK: - Enumerable Conformance

        @Test
        func `Theme conforms to Enumerable`() {
            let themes = Array(Theme.allCases)
            #expect(themes.count == 2)
            #expect(themes[0] == .light)
            #expect(themes[1] == .dark)
        }
    }
}

@Suite
struct `Theme.Product Tests` {
    // MARK: - Initialization

    @Test
    func `Product initialization`() {
        let product = Theme.Product(light: "A", dark: "B")
        #expect(product.light == "A")
        #expect(product.dark == "B")
    }

    @Test
    func `Uniform initialization`() {
        let product = Theme.Product(uniform: 42)
        #expect(product.light == 42)
        #expect(product.dark == 42)
    }

    @Test
    func `Array initialization`() {
        let product = Theme.Product(values: [1.0, 2.0])
        #expect(product.light == 1.0)
        #expect(product.dark == 2.0)
    }

    // MARK: - Subscript Access

    @Test
    func `Subscript get by theme`() {
        let product = Theme.Product(light: "light", dark: "dark")
        #expect(product[.light] == "light")
        #expect(product[.dark] == "dark")
    }

    @Test
    func `Subscript set by theme`() {
        var product = Theme.Product(light: 0, dark: 0)
        product[.light] = 10
        product[.dark] = 20
        #expect(product.light == 10)
        #expect(product.dark == 20)
    }

    // MARK: - Functor Map

    @Test
    func `Map transforms both values`() {
        let product = Theme.Product(light: 1, dark: 2)
        let mapped = product.map { $0 * 10 }
        #expect(mapped.light == 10)
        #expect(mapped.dark == 20)
    }

    @Test
    func `MapWithTheme has access to theme`() {
        let product = Theme.Product(light: "value", dark: "value")
        let mapped = product.mapWithTheme { theme, value in
            "\(theme.description):\(value)"
        }
        #expect(mapped.light == "light:value")
        #expect(mapped.dark == "dark:value")
    }

    @Test
    func `Static map function`() {
        let product = Theme.Product(light: 3, dark: 4)
        let mapped = Theme.Product<Int>.map(product) { $0 + 1 }
        #expect(mapped.light == 4)
        #expect(mapped.dark == 5)
    }

    // MARK: - Zip

    @Test
    func `Zip combines two products`() {
        let a = Theme.Product(light: 1, dark: 2)
        let b = Theme.Product(light: "A", dark: "B")
        let zipped: Theme.Product<(Int, String)> = Theme.Product.zip(a, b)
        #expect(zipped.light == (1, "A"))
        #expect(zipped.dark == (2, "B"))
    }

    @Test
    func `ZipWith combines using function`() {
        let a = Theme.Product(light: 10, dark: 20)
        let b = Theme.Product(light: 1, dark: 2)
        let result = Theme.Product.zipWith(a, b) { $0 + $1 }
        #expect(result.light == 11)
        #expect(result.dark == 22)
    }

    // MARK: - Values Array

    @Test
    func `Values returns array in order`() {
        let product = Theme.Product(light: "first", dark: "second")
        let values = product.values
        #expect(values.count == 2)
        #expect(values[0] == "first")
        #expect(values[1] == "second")
    }

    // MARK: - Conditional Conformances

    @Test
    func `Product is Equatable when Value is Equatable`() {
        let a = Theme.Product(light: 1, dark: 2)
        let b = Theme.Product(light: 1, dark: 2)
        let c = Theme.Product(light: 1, dark: 3)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Product is Hashable when Value is Hashable`() {
        let a = Theme.Product(light: "x", dark: "y")
        let b = Theme.Product(light: "x", dark: "y")
        #expect(a.hashValue == b.hashValue)

        // Can be used as dictionary key
        var dict: [Theme.Product<String>: Int] = [:]
        dict[a] = 42
        #expect(dict[b] == 42)
    }
}
