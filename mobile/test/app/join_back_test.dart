import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('back from an invite link lands on Home, not out of the app', (
    tester,
  ) async {
    final app = await pumpApp(tester, signedInAs: 'sipho');
    await app.go('/join/ubuntu2026');
    expect(find.text('Invitation'), findsOneWidget);

    await app.back();

    expect(find.text('Invitation'), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
