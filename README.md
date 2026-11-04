# swift-color-standard

Use this package when you need to convert a color between sRGB, linear sRGB, CIE LAB, CIE LCH, Oklab and Oklch, or turn it into a terminal color. Start from `Color`, and reach a specific space with `Color.LAB`, `Color.LCH`, `Color.Oklab` or `Color.Oklch`. If you only need sRGB encoding and decoding, use swift-iec-61966. To hold one value for the light theme and one for the dark theme, use `Theme.Product<Value>` from the `Theme` product.

## Laws

- Every conversion goes through `Color`, which holds CIE XYZ and an alpha. `converted(to:)` is `canonical()` followed by the target's `init(_:)`.
- LAB and LCH are relative to the D50 white point. sRGB, linear sRGB and Oklab are relative to D65. Converting between the two uses Bradford chromatic adaptation.
- Two `Color` values are equal only if they hold the same XYZ under the same white point and the same alpha. The same color reached from LAB and from sRGB is generally not equal.
- Alpha lives only on `Color`. A color made from any other space is opaque, and converting to another space drops the alpha. `Color.withAlpha(_:)` clamps to 0 through 1.
- `Color.LAB` clamps lightness to 0 through 100 and `Color.Oklab` clamps it to 0 through 1. A NaN lightness becomes 0. The `a` and `b` axes are not bounded. `Color.LAB.Lightness.init(_:)` and `Color.Oklab.Lightness.init(_:)` throw outside that range instead.
- `Color.LCH` and `Color.Oklch` raise a negative chroma to 0 and wrap the hue into 0 up to 360 degrees.
- Terminal colors clamp each sRGB channel to 0 through 1 first, so out of gamut and non-finite colors never trap. `Color.sgr` truncates each channel to 0 through 255.
- `Color.sgr256` uses the 24 step gray ramp when the channels differ by less than 0.05, and the 6 by 6 by 6 cube otherwise.
- `Color.sgrPalette` picks one of the 16 ANSI colors. It picks the bright variant when the luma, with weights 0.299, 0.587 and 0.114, is above 0.5.
- Creating a `Color` from an `ECMA_48.SGR.Color` uses the VGA values for the 16 palette colors, where `white` is 192 gray and `brightBlack` is 128 gray, and the xterm values for the cube and the gray ramp.
- `Theme.allCases` and `Theme.Product.values` list light before dark.
