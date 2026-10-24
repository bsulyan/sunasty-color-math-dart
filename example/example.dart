import 'package:sunasty_color_math/sunasty_color_math.dart';

void main() {
  print('=== Sunasty Color Math Example ===\n');

  // 1. Parsing Hex Colors
  final brandTeal = parseHex('#0F766E')!;
  final white = parseHex('#FFFFFF')!;

  print('Brand Teal RGB: (${brandTeal.r}, ${brandTeal.g}, ${brandTeal.b})');
  print('Brand Teal Hex: ${brandTeal.toHex()}');

  // 2. Relative Luminance
  print('Teal relative luminance: ${brandTeal.luminance.toStringAsFixed(4)}');
  print('White relative luminance: ${white.luminance.toStringAsFixed(4)}');

  // 3. WCAG 2.1 Contrast Calculation
  final tealOnWhite = contrastRatio(brandTeal, white);
  final conformance = checkWcag(tealOnWhite);

  print('\nContrast (Teal on White): ${tealOnWhite.toStringAsFixed(2)}:1');
  print('Meets WCAG AA (Normal text >= 4.5): ${conformance.aaNormal}');
  print('Meets WCAG AA (Large text >= 3.0): ${conformance.aaLarge}');
  print('Meets WCAG AAA (Normal text >= 7.0): ${conformance.aaaNormal}');

  // 4. Perceptual OKLCH Color Space Conversion
  final oklch = rgbToOklch(brandTeal.r, brandTeal.g, brandTeal.b);
  print('\nOKLCH Coordinates:');
  print('  Lightness (L): ${oklch.l.toStringAsFixed(4)}');
  print('  Chroma    (C): ${oklch.c.toStringAsFixed(4)}');
  print('  Hue       (h): ${oklch.h.toStringAsFixed(2)}°');

  // 5. Roundtrip Reconstruction from OKLCH back to sRGB
  final reconstructed = oklch.toRgb();
  print('Reconstructed Hex: ${reconstructed.toHex()}');
}
