# swift-color-standard

Use this package when you need to convert a color between sRGB, linear sRGB, CIE XYZ, CIE LAB, CIE LCH, Oklab and Oklch, or turn it into a terminal color. Start from `Color`, and reach a specific space with `Color.LAB`, `Color.LCH`, `Color.Oklab`, `Color.Oklch` or `ISO_11664.Tristimulus` for XYZ. To work in linear light in `Float` or any other precision without going through `Color`, use `Color.Oklab.coordinates(red:green:blue:)`, `Color.Oklab.linear(l:a:b:)` and `Color.luminance(red:green:blue:)`. To gather light parted by wavelength back into linear sRGB, use `Color.Spectrum`. If you only need sRGB encoding and decoding, use swift-iec-61966. To hold one value for the light theme and one for the dark theme, use `Theme.Product<Value>` from the `Theme` product.

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
- XYZ is `ISO_11664.Tristimulus` from swift-iso-11664. As a color it is read relative to D65 with the white's Y at 1, the values `Color` holds, and a D50 color is adapted to D65 by Bradford before it is read out.
- `Color`'s own conversions between XYZ and sRGB use the matrices derived from the sRGB primaries and the D65 white to seven decimals, under which sRGB white lands on the D65 white exactly and the pair are inverses to about 1e-7. IEC 61966-2-1 prints the same matrices to four decimals, inverses only to about 1e-4; `Color.Spectrum` and `Color.luminance(red:green:blue:)` use those printed ones, from swift-iec-61966.
- `Color.Oklab.coordinates(red:green:blue:)` and `Color.Oklab.linear(l:a:b:)` take and give linear sRGB in any `BinaryFloatingPoint`, unclamped, with the cube root worked in `Double`. `Color.Oklab.init(_:)` and `canonical()` go through them, so for `Double` they agree bit for bit with converting through `Color`, given the same linear components.
- `Color.luminance(red:green:blue:)` is the CIE Y of a linear sRGB color: 0.2126 red + 0.7152 green + 0.0722 blue, the middle row of the printed reverse matrix, each weight rounded to the precision used.
- `Color.Spectrum(sampling:count:observer:)` samples `count` wavelengths at the midpoints of as many equal parts of the range, in nanometres. Each wavelength's response is the observer's colour-matching functions taken to linear sRGB by the printed forward matrix, each component held at 0 or more. Each color's weights are its responses divided by their sum, so they add up to 1 and a flat white gathers back to white; a color with no response in the range gets weight 0 throughout, and a count of zero gives no wavelengths. Gather reads by summing each color of each read times its weight.
