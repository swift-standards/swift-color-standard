// sRGBConversionTests.swift
// Tests for sRGB <-> Color round-trip conversions

import Testing

@testable import Color_Standard

@Suite("sRGB Conversion Tests")
struct sRGBConversionTests {
  typealias sRGB = IEC_61966.`2`.`1`.sRGB

  // MARK: - Round-Trip Tests

  @Test
  func `Black round-trip`() {
    let original = sRGB.black
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `White round-trip`() {
    let original = sRGB.white
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `Primary red round-trip`() {
    let original = sRGB.red
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `Primary green round-trip`() {
    let original = sRGB.green
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `Primary blue round-trip`() {
    let original = sRGB.blue
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `Arbitrary color round-trip`() {
    let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  @Test
  func `Gray round-trip`() {
    let original = sRGB(gray: 0.5)
    let color = original.canonical()
    let roundTrip = sRGB(color)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }

  // MARK: - Conversion Accuracy

  @Test
  func `sRGB to Color preserves luminance relationship`() {
    let dark = sRGB(gray: 0.2).canonical()
    let mid = sRGB(gray: 0.5).canonical()
    let light = sRGB(gray: 0.8).canonical()

    // Y (luminance) should increase
    #expect(dark._xyz.y < mid._xyz.y)
    #expect(mid._xyz.y < light._xyz.y)
  }

  // MARK: - Protocol Conformance

  @Test
  func `sRGB converted(to:) convenience method`() {
    let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
    let roundTrip = original.converted(to: sRGB.self)

    #expect(abs(roundTrip.r - original.r) < 0.0001)
    #expect(abs(roundTrip.g - original.g) < 0.0001)
    #expect(abs(roundTrip.b - original.b) < 0.0001)
  }
}
