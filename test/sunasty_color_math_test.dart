import 'package:test/test.dart';
import 'package:sunasty_color_math/sunasty_color_math.dart';

void main() {
  group('Hex and RGB Parsing', () {
    test('parses standard 6-digit hex code', () {
      final color = parseHex('#0F766E');
      expect(color, isNotNull);
      expect(color!.r, equals(15));
      expect(color.g, equals(118));
      expect(color.b, equals(110));
      expect(color.toHex(), equals('#0f766e'));
    });

    test('parses shorthand 3-digit hex code', () {
      final color = parseHex('#FFF');
      expect(color, equals(const RgbColor(255, 255, 255)));
      expect(color!.toHex(), equals('#ffffff'));
    });

    test('returns null for invalid hex', () {
      expect(parseHex('invalid'), isNull);
      expect(parseHex('#12'), isNull);
    });
  });

  group('WCAG 2.1 Contrast Calculation', () {
    test('computes maximum contrast ratio for black on white', () {
      const white = RgbColor(255, 255, 255);
      const black = RgbColor(0, 0, 0);

      final ratio = contrastRatio(white, black);
      expect(ratio, equals(21.0));

      final conformance = checkWcag(ratio);
      expect(conformance.aaNormal, isTrue);
      expect(conformance.aaaNormal, isTrue);
    });

    test('computes contrast ratio for teal on white', () {
      const teal = RgbColor(15, 118, 110);
      const white = RgbColor(255, 255, 255);

      final ratio = teal.contrastWith(white);
      expect(ratio, closeTo(5.47, 0.05));

      final conformance = checkWcag(ratio);
      expect(conformance.aaNormal, isTrue);
      expect(conformance.aaLarge, isTrue);
      expect(conformance.aaaNormal, isFalse);
    });
  });

  group('OKLCH Conversion', () {
    test('converts sRGB to OKLCH and back to sRGB', () {
      const original = RgbColor(15, 118, 110);
      final oklch = rgbToOklch(original.r, original.g, original.b);

      expect(oklch.l, closeTo(0.51, 0.01));
      expect(oklch.c, closeTo(0.09, 0.01));
      expect(oklch.h, closeTo(186.2, 1.0));

      final reconstructed = oklch.toRgb();
      expect(reconstructed.r, equals(original.r));
      expect(reconstructed.g, equals(original.g));
      expect(reconstructed.b, equals(original.b));
    });
  });
}
