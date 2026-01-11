// Color+ECMA_48.swift
// ECMA-48 SGR color conversion

public import ECMA_48
import ISO_9899

// MARK: - Color to ECMA_48.SGR.Color

extension Color {
    /// Convert to ECMA-48 SGR color (24-bit RGB).
    ///
    /// Returns an RGB color suitable for terminal output with true color support.
    public var sgr: ECMA_48.SGR.Color {
        let rgba = _debugRGBA
        return .rgb(
            r: UInt8(clamping: Int(rgba.r * 255)),
            g: UInt8(clamping: Int(rgba.g * 255)),
            b: UInt8(clamping: Int(rgba.b * 255))
        )
    }

    /// Convert to ECMA-48 SGR color with specified capability level.
    ///
    /// - Parameter capability: The color capability level to target
    /// - Returns: SGR color appropriate for the capability level
    public func sgr(for capability: SGRCapability) -> ECMA_48.SGR.Color {
        switch capability {
        case .trueColor:
            return sgr
        case .palette8:
            return sgr256
        case .palette4:
            return sgrPalette
        }
    }

    /// Convert to nearest 256-color palette index.
    ///
    /// Uses the 6x6x6 color cube (indices 16-231) or grayscale ramp (232-255).
    public var sgr256: ECMA_48.SGR.Color {
        let rgba = _debugRGBA
        let r = rgba.r
        let g = rgba.g
        let b = rgba.b

        // Check if grayscale (r ≈ g ≈ b)
        let maxDiff = max(abs(r - g), abs(g - b), abs(r - b))
        if maxDiff < 0.05 {
            // Use grayscale ramp (232-255, 24 levels)
            let gray = (r + g + b) / 3.0
            let index = UInt8(232 + min(23, Int(gray * 24)))
            return .extended(index)
        }

        // Use 6x6x6 color cube (16-231)
        let ri = min(5, Int(r * 6))
        let gi = min(5, Int(g * 6))
        let bi = min(5, Int(b * 6))
        let index = UInt8(16 + 36 * ri + 6 * gi + bi)
        return .extended(index)
    }

    /// Convert to nearest 16-color palette.
    ///
    /// Maps to the standard ANSI 16-color palette.
    public var sgrPalette: ECMA_48.SGR.Color {
        let rgba = _debugRGBA
        let r = rgba.r
        let g = rgba.g
        let b = rgba.b

        // Determine if color is bright (high luminance)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        let bright = luminance > 0.5

        // Find closest base color
        let palette = closestPaletteColor(r: r, g: g, b: b, bright: bright)
        return .palette(palette)
    }

    /// SGR color capability levels.
    public enum SGRCapability: Sendable {
        /// 24-bit true color (16 million colors).
        case trueColor
        /// 8-bit extended palette (256 colors).
        case palette8
        /// 4-bit palette (16 colors).
        case palette4
    }
}

// MARK: - ECMA_48.SGR.Color to Color

extension Color {
    /// Create from ECMA-48 SGR color.
    ///
    /// - Parameter sgr: SGR color to convert
    public init(_ sgr: ECMA_48.SGR.Color) {
        switch sgr {
        case .palette(let p):
            self = Self._fromPalette(p)
        case .extended(let index):
            self = Self._from256(index)
        case .rgb(let r, let g, let b):
            self = Self._fromRGB(r: r, g: g, b: b)
        }
    }
}

// MARK: - Private Helpers

extension Color {
    /// Convert from RGB bytes.
    private static func _fromRGB(r: UInt8, g: UInt8, b: UInt8) -> Color {
        let rd = Double(r) / 255.0
        let gd = Double(g) / 255.0
        let bd = Double(b) / 255.0

        // Linearize sRGB
        func linearize(_ v: Double) -> Double {
            if v <= 0.04045 {
                return v / 12.92
            } else {
                return ISO_9899.Math.pow((v + 0.055) / 1.055, 2.4)
            }
        }

        let lr = linearize(rd)
        let lg = linearize(gd)
        let lb = linearize(bd)

        // Convert to XYZ
        let m = _XYZ.sRGBToXYZ
        let x = m.0.0 * lr + m.0.1 * lg + m.0.2 * lb
        let y = m.1.0 * lr + m.1.1 * lg + m.1.2 * lb
        let z = m.2.0 * lr + m.2.1 * lg + m.2.2 * lb

        return Color(_xyz: _XYZ(x: x, y: y, z: z, illuminant: .d65), _alpha: 1.0)
    }

    /// Convert from 256-color palette index.
    private static func _from256(_ index: UInt8) -> Color {
        if index < 16 {
            // Standard 16 colors
            return _fromPalette(ECMA_48.SGR.Color.Palette(rawValue: Int(index))!)
        } else if index < 232 {
            // 6x6x6 color cube
            let i = Int(index) - 16
            let b = i % 6
            let g = (i / 6) % 6
            let r = i / 36

            // Map 0-5 to 0, 95, 135, 175, 215, 255
            func cube(_ v: Int) -> UInt8 {
                if v == 0 { return 0 }
                return UInt8(55 + v * 40)
            }

            return _fromRGB(r: cube(r), g: cube(g), b: cube(b))
        } else {
            // Grayscale ramp (232-255)
            let gray = UInt8(8 + (Int(index) - 232) * 10)
            return _fromRGB(r: gray, g: gray, b: gray)
        }
    }

    /// Convert from 16-color palette.
    private static func _fromPalette(_ palette: ECMA_48.SGR.Color.Palette) -> Color {
        let rgb: (UInt8, UInt8, UInt8) = switch palette {
        case .black:         (0, 0, 0)
        case .red:           (128, 0, 0)
        case .green:         (0, 128, 0)
        case .yellow:        (128, 128, 0)
        case .blue:          (0, 0, 128)
        case .magenta:       (128, 0, 128)
        case .cyan:          (0, 128, 128)
        case .white:         (192, 192, 192)
        case .brightBlack:   (128, 128, 128)
        case .brightRed:     (255, 0, 0)
        case .brightGreen:   (0, 255, 0)
        case .brightYellow:  (255, 255, 0)
        case .brightBlue:    (0, 0, 255)
        case .brightMagenta: (255, 0, 255)
        case .brightCyan:    (0, 255, 255)
        case .brightWhite:   (255, 255, 255)
        }
        return _fromRGB(r: rgb.0, g: rgb.1, b: rgb.2)
    }

    /// Find closest 16-color palette entry.
    private func closestPaletteColor(r: Double, g: Double, b: Double, bright: Bool) -> ECMA_48.SGR.Color.Palette {
        // Simple heuristic: check which primary/secondary color dominates
        let threshold = 0.3

        let hasR = r > threshold
        let hasG = g > threshold
        let hasB = b > threshold

        // Check for grayscale
        let maxDiff = max(abs(r - g), abs(g - b), abs(r - b))
        if maxDiff < 0.15 {
            let avg = (r + g + b) / 3.0
            if avg < 0.15 {
                return .black
            } else if avg < 0.5 {
                return bright ? .brightBlack : .black
            } else if avg < 0.85 {
                return bright ? .white : .brightBlack
            } else {
                return .brightWhite
            }
        }

        // Map to color based on dominant channels
        let palette: ECMA_48.SGR.Color.Palette
        switch (hasR, hasG, hasB) {
        case (true, false, false): palette = .red
        case (false, true, false): palette = .green
        case (false, false, true): palette = .blue
        case (true, true, false):  palette = .yellow
        case (true, false, true):  palette = .magenta
        case (false, true, true):  palette = .cyan
        case (true, true, true):   palette = .white
        case (false, false, false): palette = .black
        }

        // Return bright variant if needed
        if bright {
            return ECMA_48.SGR.Color.Palette(rawValue: palette.rawValue + 8) ?? palette
        }
        return palette
    }
}
