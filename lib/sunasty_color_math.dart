/// Zero-dependency sRGB and OKLCH color space conversions and WCAG 2.1 contrast calculations in Dart.
///
/// Published by Sunasty (https://sunasty.com).
library sunasty_color_math;

import 'dart:math' as math;

/// Represents an 8-bit sRGB color.
class RgbColor {
  /// Red channel (0 to 255).
  final int r;

  /// Green channel (0 to 255).
  final int g;

  /// Blue channel (0 to 255).
  final int b;

  /// Creates a constant [RgbColor] instance.
  const RgbColor(this.r, this.g, this.b);

  /// Formats the color as a lowercase 6-character hex string prefixed with `#`.
  String toHex() => rgbToHex(r, g, b);

  /// Calculates the relative luminance of this color.
  double get luminance => relativeLuminance(r, g, b);

  /// Computes the contrast ratio against another [RgbColor].
  double contrastWith(RgbColor other) => contrastRatio(this, other);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RgbColor &&
          runtimeType == other.runtimeType &&
          r == other.r &&
          g == other.g &&
          b == other.b;

  @override
  int get hashCode => r.hashCode ^ g.hashCode ^ b.hashCode;

  @override
  String toString() => 'RgbColor($r, $g, $b)';
}

/// Represents a color in the cylindrical OKLCH perceptual space.
class OklchColor {
  /// Perceived lightness, ranging from 0.0 (black) to 1.0 (white).
  final double l;

  /// Chroma (saturation), typically from 0.0 to approximately 0.4.
  final double c;

  /// Hue angle in degrees, from 0.0 to 360.0.
  final double h;

  /// Creates an [OklchColor] coordinate.
  const OklchColor(this.l, this.c, this.h);

  /// Converts this OKLCH color back into standard [RgbColor].
  RgbColor toRgb() => oklchToRgb(l, c, h);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OklchColor &&
          runtimeType == other.runtimeType &&
          l == other.l &&
          c == other.c &&
          h == other.h;

  @override
  int get hashCode => l.hashCode ^ c.hashCode ^ h.hashCode;

  @override
  String toString() => 'OklchColor(L: $l, C: $c, h: $h°)';
}

/// Evaluation of WCAG 2.1 AA and AAA accessibility contrast criteria.
class WcagConformance {
  /// The computed contrast ratio (between 1.0 and 21.0).
  final double ratio;

  /// Conformance with WCAG AA for normal text (ratio >= 4.5).
  final bool aaNormal;

  /// Conformance with WCAG AA for large text (ratio >= 3.0).
  final bool aaLarge;

  /// Conformance with WCAG AAA for normal text (ratio >= 7.0).
  final bool aaaNormal;

  /// Conformance with WCAG AAA for large text (ratio >= 4.5).
  final bool aaaLarge;

  /// Creates a [WcagConformance] evaluation report.
  const WcagConformance({
    required this.ratio,
    required this.aaNormal,
    required this.aaLarge,
    required this.aaaNormal,
    required this.aaaLarge,
  });

  @override
  String toString() =>
      'WcagConformance(ratio: $ratio:1, AA: $aaNormal, AAA: $aaaNormal)';
}

/// Parses a 3-digit or 6-digit hexadecimal color string into an [RgbColor].
///
/// Accepts strings with or without a leading `#`. Returns `null` if the input
/// string is not a valid hex color format.
RgbColor? parseHex(String hexStr) {
  var clean = hexStr.trim();
  if (clean.startsWith('#')) {
    clean = clean.substring(1);
  }
  if (clean.length == 3) {
    clean = clean.split('').map((c) => '$c$c').join();
  }
  if (clean.length != 6) {
    return null;
  }
  final val = int.tryParse(clean, radix: 16);
  if (val == null) {
    return null;
  }
  return RgbColor((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF);
}

/// Formats integer [r], [g], [b] channels (0-255) into a `#rrggbb` string.
String rgbToHex(int r, int g, int b) {
  final clampedR = r.clamp(0, 255);
  final clampedG = g.clamp(0, 255);
  final clampedB = b.clamp(0, 255);
  return '#${clampedR.toRadixString(16).padLeft(2, '0')}'
      '${clampedG.toRadixString(16).padLeft(2, '0')}'
      '${clampedB.toRadixString(16).padLeft(2, '0')}';
}

/// Converts an 8-bit sRGB channel into linear light intensity (0.0 to 1.0).
double linearizeSrgb(num c8bit) {
  final v = c8bit.clamp(0.0, 255.0) / 255.0;
  return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

/// Converts a linear light value (0.0 to 1.0) back to an 8-bit sRGB channel integer.
int delinearizeSrgb(double lin) {
  final v = lin.clamp(0.0, 1.0);
  final val =
      v <= 0.0031308 ? 12.92 * v : 1.055 * math.pow(v, 1.0 / 2.4) - 0.055;
  return (val * 255.0).round().clamp(0, 255);
}

/// Calculates the WCAG 2.1 relative luminance for an sRGB color.
double relativeLuminance(int r, int g, int b) {
  return 0.2126 * linearizeSrgb(r) +
      0.7152 * linearizeSrgb(g) +
      0.0722 * linearizeSrgb(b);
}

/// Computes the WCAG 2.1 contrast ratio between [colorA] and [colorB].
double contrastRatio(RgbColor colorA, RgbColor colorB) {
  final l1 = relativeLuminance(colorA.r, colorA.g, colorA.b);
  final l2 = relativeLuminance(colorB.r, colorB.g, colorB.b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  final ratio = (lighter + 0.05) / (darker + 0.05);
  return (ratio * 100).round() / 100.0;
}

/// Evaluates a contrast ratio against WCAG AA and AAA thresholds.
WcagConformance checkWcag(double contrast) {
  return WcagConformance(
    ratio: contrast,
    aaNormal: contrast >= 4.5,
    aaLarge: contrast >= 3.0,
    aaaNormal: contrast >= 7.0,
    aaaLarge: contrast >= 4.5,
  );
}

/// Converts 8-bit sRGB coordinates into cylindrical OKLCH coordinates.
OklchColor rgbToOklch(int r, int g, int b) {
  final lr = linearizeSrgb(r);
  final lg = linearizeSrgb(g);
  final lb = linearizeSrgb(b);

  final l = math.pow(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb, 1.0 / 3.0).toDouble();
  final m = math.pow(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb, 1.0 / 3.0).toDouble();
  final s = math.pow(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb, 1.0 / 3.0).toDouble();

  final okL = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
  final okA = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  final okB = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;

  final chroma = math.sqrt(okA * okA + okB * okB);
  final hRad = math.atan2(okB, okA);
  var hDeg = (hRad * 180.0 / math.pi) % 360.0;
  if (hDeg < 0) {
    hDeg += 360.0;
  }

  return OklchColor(
    (okL * 10000).round() / 10000.0,
    (chroma * 10000).round() / 10000.0,
    (hDeg * 100).round() / 100.0,
  );
}

/// Converts cylindrical OKLCH coordinates back into standard 8-bit [RgbColor].
RgbColor oklchToRgb(double lVal, double cVal, double hDeg) {
  final hRad = hDeg * math.pi / 180.0;
  final okA = cVal * math.cos(hRad);
  final okB = cVal * math.sin(hRad);

  final l = lVal + 0.3963377774 * okA + 0.2158037573 * okB;
  final m = lVal - 0.1055613458 * okA - 0.0638541728 * okB;
  final s = lVal - 0.0894841775 * okA - 1.2914855480 * okB;

  final l3 = l * l * l;
  final m3 = m * m * m;
  final s3 = s * s * s;

  final lr = 4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3;
  final lg = -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3;
  final lb = -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3;

  return RgbColor(
    delinearizeSrgb(lr),
    delinearizeSrgb(lg),
    delinearizeSrgb(lb),
  );
}
