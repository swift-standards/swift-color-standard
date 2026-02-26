// CanonicalTests.swift
// Tests for Color and round-trip conversions

import Testing

@testable import Color_Standard

@Suite("Color Tests")
struct ColorTests {
  // MARK: - Constants

  @Test("Black constant")
  func blackConstant() {
    let black = Color.black
    #expect(black.alpha == 1.0)

    let rgb = black._debugRGBA
    #expect(rgb.r == 0, "Red should be 0")
    #expect(rgb.g == 0, "Green should be 0")
    #expect(rgb.b == 0, "Blue should be 0")
  }

  @Test("White constant")
  func whiteConstant() {
    let white = Color.white
    #expect(white.alpha == 1.0)

    let rgb = white._debugRGBA
    #expect(abs(rgb.r - 1.0) < 0.001, "Red should be ~1.0")
    #expect(abs(rgb.g - 1.0) < 0.001, "Green should be ~1.0")
    #expect(abs(rgb.b - 1.0) < 0.001, "Blue should be ~1.0")
  }

  @Test("Clear constant")
  func clearConstant() {
    let clear = Color.clear
    #expect(clear.alpha == 0.0)
  }

  // MARK: - Alpha Manipulation

  @Test("withAlpha creates new instance")
  func withAlphaCreatesNewInstance() {
    let original = Color.black
    let modified = original.withAlpha(0.5)

    #expect(original.alpha == 1.0, "Original unchanged")
    #expect(modified.alpha == 0.5, "Modified has new alpha")
  }

  @Test("withAlpha clamps values")
  func withAlphaClampsValues() {
    let color = Color.black
    #expect(color.withAlpha(-0.5).alpha == 0.0)
    #expect(color.withAlpha(1.5).alpha == 1.0)
  }

  // MARK: - Equatable

  @Test("Color equality")
  func colorEquality() {
    let a = Color.black
    let b = Color.black
    let c = Color.white

    #expect(a == b)
    #expect(a != c)
  }

  // MARK: - Self-Conformance

  @Test("Color conforms to Color.Protocol")
  func colorSelfConformance() {
    let original = Color.white
    let roundTrip = original.canonical()

    #expect(original == roundTrip)
  }
}
