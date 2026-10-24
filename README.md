# sunasty_color_math

Zero-dependency Dart and Flutter library for sRGB, OKLCH color space conversions, relative luminance, and WCAG 2.1 accessibility contrast calculation.

Developed for the [Sunasty Color Picker](https://sunasty.com/color-picker/) client-side tool and the Sunasty developer suite.

## Features

- **Zero dependencies**: Pure Dart implementation compatible with Flutter (Android, iOS, Web, Desktop) and standalone Dart VM.
- **Color space conversions**: Bi-directional conversions between sRGB, Hex, and cylindrical OKLCH coordinates.
- **Accessibility verification**: WCAG 2.1 relative luminance and contrast ratio calculation with AA / AAA compliance checks.

## Usage

```dart
import 'package:sunasty_color_math/sunasty_color_math.dart';

void main() {
  final text = parseHex('#0F766E')!;
  const background = RgbColor(255, 255, 255);

  final ratio = text.contrastWith(background);
  final conformance = checkWcag(ratio);

  print('Contrast: $ratio:1');
  print('Passes WCAG AA: ${conformance.aaNormal}');
}
```

## Online Playground

Interactive web demonstration available on [Sunasty](https://sunasty.com/color-picker/).

## License

MIT
