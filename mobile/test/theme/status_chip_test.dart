import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/app_theme.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';
import 'package:ronditrack/features/stokvel/presentation/status_chips.dart';

Future<Color?> _textColour(
  WidgetTester tester,
  Brightness brightness,
  Widget chip,
  String label,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(brightness),
      home: Scaffold(body: chip),
    ),
  );
  // MaterialApp animates a theme change, so let it finish first.
  await tester.pumpAndSettle();
  expect(find.text(label), findsOneWidget);
  expect(find.byType(Icon), findsOneWidget);
  return tester.widget<Text>(find.text(label)).style?.color;
}

void main() {
  testWidgets('every contribution status says its words, in both themes', (
    tester,
  ) async {
    for (final status in ContributionStatus.values) {
      final label = contributionLabel(status);
      final chip = ContributionStatusChip(status: status);
      final light = await _textColour(tester, Brightness.light, chip, label);
      final dark = await _textColour(tester, Brightness.dark, chip, label);
      expect(light, isNot(dark), reason: '$status has one colour for both');
    }
  });

  testWidgets('every cycle status says its words, in both themes', (
    tester,
  ) async {
    for (final status in CycleStatus.values) {
      final label = cycleLabel(status);
      final chip = CycleStatusChip(status: status);
      final light = await _textColour(tester, Brightness.light, chip, label);
      final dark = await _textColour(tester, Brightness.dark, chip, label);
      expect(light, isNot(dark), reason: '$status has one colour for both');
    }
  });
}
