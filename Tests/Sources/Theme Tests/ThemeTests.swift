// ThemeTests.swift
// Tests for Theme and Theme.Product

import Testing

@testable import Theme

@Suite("Theme Tests")
struct ThemeTests {
  // MARK: - Theme Cases

  @Test("Theme has two cases")
  func themeCaseCount() {
    #expect(Theme.caseCount == 2)
  }

  @Test("Light theme has index 0")
  func lightIndex() {
    #expect(Theme.light.caseIndex == 0)
  }

  @Test("Dark theme has index 1")
  func darkIndex() {
    #expect(Theme.dark.caseIndex == 1)
  }

  @Test("Theme description")
  func themeDescription() {
    #expect(Theme.light.description == "light")
    #expect(Theme.dark.description == "dark")
  }

  @Test("Theme equality")
  func themeEquality() {
    #expect(Theme.light == Theme.light)
    #expect(Theme.dark == Theme.dark)
    #expect(Theme.light != Theme.dark)
  }

  @Test("Theme from caseIndex round-trip")
  func themeFromCaseIndex() {
    let light = Theme(caseIndex: 0)
    let dark = Theme(caseIndex: 1)
    #expect(light == Theme.light)
    #expect(dark == Theme.dark)
  }

  // MARK: - Enumerable Conformance

  @Test("Theme conforms to Enumerable")
  func themeEnumerable() {
    var themes: [Theme] = []
    for i in 0..<Theme.caseCount {
      themes.append(Theme(caseIndex: i))
    }
    #expect(themes.count == 2)
    #expect(themes[0] == .light)
    #expect(themes[1] == .dark)
  }
}

@Suite("Theme.Product Tests")
struct ThemeProductTests {
  // MARK: - Initialization

  @Test("Product initialization")
  func productInit() {
    let product = Theme.Product(light: "A", dark: "B")
    #expect(product.light == "A")
    #expect(product.dark == "B")
  }

  @Test("Uniform initialization")
  func uniformInit() {
    let product = Theme.Product(uniform: 42)
    #expect(product.light == 42)
    #expect(product.dark == 42)
  }

  @Test("Array initialization")
  func arrayInit() {
    let product = Theme.Product(values: [1.0, 2.0])
    #expect(product.light == 1.0)
    #expect(product.dark == 2.0)
  }

  // MARK: - Subscript Access

  @Test("Subscript get by theme")
  func subscriptGet() {
    let product = Theme.Product(light: "light", dark: "dark")
    #expect(product[.light] == "light")
    #expect(product[.dark] == "dark")
  }

  @Test("Subscript set by theme")
  func subscriptSet() {
    var product = Theme.Product(light: 0, dark: 0)
    product[.light] = 10
    product[.dark] = 20
    #expect(product.light == 10)
    #expect(product.dark == 20)
  }

  // MARK: - Functor Map

  @Test("Map transforms both values")
  func mapBothValues() {
    let product = Theme.Product(light: 1, dark: 2)
    let mapped = product.map { $0 * 10 }
    #expect(mapped.light == 10)
    #expect(mapped.dark == 20)
  }

  @Test("MapWithTheme has access to theme")
  func mapWithTheme() {
    let product = Theme.Product(light: "value", dark: "value")
    let mapped = product.mapWithTheme { theme, value in
      "\(theme.description):\(value)"
    }
    #expect(mapped.light == "light:value")
    #expect(mapped.dark == "dark:value")
  }

  @Test("Static map function")
  func staticMap() {
    let product = Theme.Product(light: 3, dark: 4)
    let mapped = Theme.Product<Int>.map(product) { $0 + 1 }
    #expect(mapped.light == 4)
    #expect(mapped.dark == 5)
  }

  // MARK: - Zip

  @Test("Zip combines two products")
  func zipProducts() {
    let a = Theme.Product(light: 1, dark: 2)
    let b = Theme.Product(light: "A", dark: "B")
    let zipped: Theme.Product<(Int, String)> = Theme.Product.zip(a, b)
    #expect(zipped.light == (1, "A"))
    #expect(zipped.dark == (2, "B"))
  }

  @Test("ZipWith combines using function")
  func zipWithFunction() {
    let a = Theme.Product(light: 10, dark: 20)
    let b = Theme.Product(light: 1, dark: 2)
    let result = Theme.Product.zipWith(a, b) { $0 + $1 }
    #expect(result.light == 11)
    #expect(result.dark == 22)
  }

  // MARK: - Values Array

  @Test("Values returns array in order")
  func valuesArray() {
    let product = Theme.Product(light: "first", dark: "second")
    let values = product.values
    #expect(values.count == 2)
    #expect(values[0] == "first")
    #expect(values[1] == "second")
  }

  // MARK: - Conditional Conformances

  @Test("Product is Equatable when Value is Equatable")
  func productEquatable() {
    let a = Theme.Product(light: 1, dark: 2)
    let b = Theme.Product(light: 1, dark: 2)
    let c = Theme.Product(light: 1, dark: 3)
    #expect(a == b)
    #expect(a != c)
  }

  @Test("Product is Hashable when Value is Hashable")
  func productHashable() {
    let a = Theme.Product(light: "x", dark: "y")
    let b = Theme.Product(light: "x", dark: "y")
    #expect(a.hashValue == b.hashValue)

    // Can be used as dictionary key
    var dict: [Theme.Product<String>: Int] = [:]
    dict[a] = 42
    #expect(dict[b] == 42)
  }
}
