// OklabConversionTests.swift
// Tests for Oklab/Oklch <-> Color conversions

import Testing

@testable import Color_Standard

@Suite("Oklab Conversion Tests")
struct OklabConversionTests {
  typealias Oklab = Color.Oklab
  typealias Oklch = Color.Oklch
  typealias sRGB = IEC_61966.`2`.`1`.sRGB

  // MARK: - Oklab Round-Trip Tests

  @Test("Oklab black round-trip")
  func oklabBlackRoundTrip() {
    let original = Oklab.black
    let color = original.canonical()
    let roundTrip = Oklab(color)

    #expect(abs(roundTrip.l - original.l) < 0.001)
    #expect(abs(roundTrip.a - original.a) < 0.001)
    #expect(abs(roundTrip.b - original.b) < 0.001)
  }

  @Test("Oklab white round-trip")
  func oklabWhiteRoundTrip() {
    let original = Oklab.white
    let color = original.canonical()
    let roundTrip = Oklab(color)

    #expect(abs(roundTrip.l - original.l) < 0.001)
    #expect(abs(roundTrip.a - original.a) < 0.001)
    #expect(abs(roundTrip.b - original.b) < 0.001)
  }

  @Test("Oklab arbitrary color round-trip")
  func oklabArbitraryRoundTrip() {
    let original = Oklab(l: 0.6, a: 0.1, b: -0.1)
    let color = original.canonical()
    let roundTrip = Oklab(color)

    #expect(abs(roundTrip.l - original.l) < 0.001)
    #expect(abs(roundTrip.a - original.a) < 0.001)
    #expect(abs(roundTrip.b - original.b) < 0.001)
  }

  // MARK: - Oklab to sRGB Known Values

  @Test("Oklab to sRGB - black")
  func oklabToSRGBBlack() {
    let oklab = Oklab(l: 0, a: 0, b: 0)
    let srgb = oklab.converted(to: sRGB.self)

    #expect(abs(srgb.r - 0) < 0.01)
    #expect(abs(srgb.g - 0) < 0.01)
    #expect(abs(srgb.b - 0) < 0.01)
  }

  @Test("Oklab to sRGB - white")
  func oklabToSRGBWhite() {
    let oklab = Oklab(l: 1, a: 0, b: 0)
    let srgb = oklab.converted(to: sRGB.self)

    #expect(abs(srgb.r - 1) < 0.01)
    #expect(abs(srgb.g - 1) < 0.01)
    #expect(abs(srgb.b - 1) < 0.01)
  }

  @Test("Oklab to sRGB - mid gray")
  func oklabToSRGBMidGray() {
    // L=0.5 in Oklab is perceptually mid-gray
    let oklab = Oklab(l: 0.5, a: 0, b: 0)
    let srgb = oklab.converted(to: sRGB.self)

    // All channels should be equal (achromatic)
    #expect(abs(srgb.r - srgb.g) < 0.01)
    #expect(abs(srgb.g - srgb.b) < 0.01)
    // Should be somewhere in the gray range
    #expect(srgb.r > 0.1 && srgb.r < 0.5)
  }

  // MARK: - sRGB to Oklab Known Values

  @Test("sRGB to Oklab - red")
  func srgbToOklabRed() {
    let srgb = sRGB.red
    let oklab = srgb.converted(to: Oklab.self)

    // sRGB red in Oklab is approximately L≈0.628, a≈0.225, b≈0.126
    #expect(oklab.l > 0.6 && oklab.l < 0.7)
    #expect(oklab.a > 0.2)  // Positive a (red)
    #expect(oklab.b > 0.1)  // Positive b (yellow-ish for red)
  }

  @Test("sRGB to Oklab - green")
  func srgbToOklabGreen() {
    let srgb = sRGB.green
    let oklab = srgb.converted(to: Oklab.self)

    // sRGB green in Oklab is approximately L≈0.866, a≈-0.234, b≈0.179
    #expect(oklab.l > 0.8)
    #expect(oklab.a < 0)  // Negative a (green)
    #expect(oklab.b > 0.1)  // Positive b (yellow-ish)
  }

  @Test("sRGB to Oklab - blue")
  func srgbToOklabBlue() {
    let srgb = sRGB.blue
    let oklab = srgb.converted(to: Oklab.self)

    // sRGB blue in Oklab is approximately L≈0.452, a≈-0.032, b≈-0.312
    #expect(oklab.l > 0.4 && oklab.l < 0.5)
    #expect(oklab.b < -0.25)  // Negative b (blue)
  }

  // MARK: - Oklch Round-Trip Tests

  @Test("Oklch round-trip")
  func oklchRoundTrip() {
    let original = Oklch(l: 0.7, c: 0.15, h: 120)
    let color = original.canonical()
    let roundTrip = Oklch(color)

    #expect(abs(roundTrip.l - original.l) < 0.001)
    #expect(abs(roundTrip.c - original.c) < 0.001)
    // Hue might wrap around 360°
    let hueDiff = abs(roundTrip.h - original.h)
    #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
  }

  // MARK: - Oklab <-> Oklch Conversion

  @Test("Oklab to Oklch conversion")
  func oklabToOklch() {
    let oklab = Oklab(l: 0.5, a: 0.1, b: 0.1)
    let oklch = Oklch(oklab)

    #expect(abs(oklch.l - 0.5) < 0.001)
    // Chroma = sqrt(0.1² + 0.1²) ≈ 0.1414
    #expect(abs(oklch.c - 0.1414) < 0.01)
    // Hue = atan2(0.1, 0.1) = 45°
    #expect(abs(oklch.h - 45) < 0.1)
  }

  @Test("Oklch to Oklab conversion")
  func oklchToOklab() {
    let oklch = Oklch(l: 0.5, c: 0.2, h: 90)
    let oklab = oklch.oklab

    #expect(abs(oklab.l - 0.5) < 0.001)
    // a = 0.2 * cos(90°) ≈ 0
    #expect(abs(oklab.a) < 0.001)
    // b = 0.2 * sin(90°) = 0.2
    #expect(abs(oklab.b - 0.2) < 0.001)
  }

  // MARK: - Cross-Format Conversion

  @Test("sRGB -> Oklab -> sRGB round-trip")
  func srgbOklabRoundTrip() {
    let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
    let oklab = original.converted(to: Oklab.self)
    let roundTrip = oklab.converted(to: sRGB.self)

    #expect(abs(roundTrip.r - original.r) < 0.01)
    #expect(abs(roundTrip.g - original.g) < 0.01)
    #expect(abs(roundTrip.b - original.b) < 0.01)
  }

  @Test("sRGB -> Oklch -> sRGB round-trip")
  func srgbOklchRoundTrip() {
    let original = sRGB(r: 0.5, g: 0.3, b: 0.8)
    let oklch = original.converted(to: Oklch.self)
    let roundTrip = oklch.converted(to: sRGB.self)

    #expect(abs(roundTrip.r - original.r) < 0.01)
    #expect(abs(roundTrip.g - original.g) < 0.01)
    #expect(abs(roundTrip.b - original.b) < 0.01)
  }

  // MARK: - Protocol Conformance

  @Test("Oklab converted(to:) convenience method")
  func oklabConvertedToMethod() {
    let oklab = Oklab(l: 0.6, a: 0.1, b: -0.1)
    let roundTrip = oklab.converted(to: Oklab.self)

    #expect(abs(roundTrip.l - oklab.l) < 0.001)
    #expect(abs(roundTrip.a - oklab.a) < 0.001)
    #expect(abs(roundTrip.b - oklab.b) < 0.001)
  }

  @Test("Oklch converted(to:) convenience method")
  func oklchConvertedToMethod() {
    let oklch = Oklch(l: 0.7, c: 0.15, h: 180)
    let roundTrip = oklch.converted(to: Oklch.self)

    #expect(abs(roundTrip.l - oklch.l) < 0.001)
    #expect(abs(roundTrip.c - oklch.c) < 0.001)
    let hueDiff = abs(roundTrip.h - oklch.h)
    #expect(hueDiff < 0.1 || abs(hueDiff - 360) < 0.1)
  }

  // MARK: - Lightness Component

  @Test("Oklab Lightness typed component")
  func oklabLightnessComponent() throws {
    let lightness = try Oklab.Lightness(0.5)
    #expect(lightness.value == 0.5)

    let clamped = Oklab.Lightness(clamping: 1.5)
    #expect(clamped.value == 1)

    #expect(throws: Oklab.Lightness.Error.self) {
      _ = try Oklab.Lightness(-0.1)
    }
  }
}
