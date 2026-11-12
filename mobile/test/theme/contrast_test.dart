import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/tokens.dart';

void main() {
  test('the contrast maths matches known values', () {
    expect(contrastRatio(0xFF000000, 0xFFFFFFFF), closeTo(21, 0.01));
    expect(contrastRatio(0xFF777777, 0xFFFFFFFF), closeTo(4.48, 0.05));
  });

  test('body text is at least 4.5:1 in both themes', () {
    for (final page in [pageLight, pageDark]) {
      expect(
        contrastRatio(page.foreground, page.background),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  for (final spec in tokenSpecs) {
    for (final (label, tone, page) in [
      ('light', spec.light, pageLight),
      ('dark', spec.dark, pageDark),
    ]) {
      test('${spec.name} $label: chip text is at least 4.5:1', () {
        expect(
          contrastRatio(tone.foreground, tone.background),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('${spec.name} $label: chip border is at least 3:1 on the page', () {
        expect(
          contrastRatio(tone.foreground, page.background),
          greaterThanOrEqualTo(3),
        );
      });
    }

    test(
      '${spec.name}: dark is its own palette, not the light one flipped',
      () {
        expect(luminance(spec.light.background), greaterThan(0.5));
        expect(luminance(spec.dark.background), lessThan(0.1));
        expect(spec.dark.foreground, isNot(spec.light.background));
      },
    );
  }
}
