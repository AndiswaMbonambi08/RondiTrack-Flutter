import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('nothing of the last person survives a switch', (tester) async {
    final app = await pumpApp(tester, signedInAs: 'sipho');
    await app.go('/stokvels/umoja-family-fund');
    final close = find.text(
      actionLabel(StokvelAction.closeCycle),
      skipOffstage: false,
    );
    final confirm = find.text(
      actionLabel(StokvelAction.confirmContributions),
      skipOffstage: false,
    );
    final lebo = find.text('Lebo', skipOffstage: false);
    expect(close, findsOneWidget); // Sipho is Treasurer here.

    await tester.tap(find.byTooltip('Switch person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mpho'));

    // Every frame of the switch: once Mpho is the person, no frame may carry
    // Sipho's actions or the contributions of his stokvel.
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (app.container.read(currentPersonaProvider) == 'mpho') {
        expect(close, findsNothing, reason: 'frame $frame');
        expect(confirm, findsNothing, reason: 'frame $frame');
        expect(lebo, findsNothing, reason: 'frame $frame');
      }
    }
    await tester.pumpAndSettle();
    expect(app.container.read(currentPersonaProvider), 'mpho');
    expect(find.text('Stokvel not found'), findsOneWidget);
  });

  testWidgets('signing out tears everything down; signing in starts fresh', (
    tester,
  ) async {
    final app = await pumpApp(tester, signedInAs: 'sipho');
    await app.go('/stokvels/umoja-family-fund');
    app.container.read(authProvider.notifier).signOut();
    await tester.pumpAndSettle();
    expect(find.text('Sign in to open the link you followed.'), findsOneWidget);
    expect(
      find.text(actionLabel(StokvelAction.closeCycle), skipOffstage: false),
      findsNothing,
    );
    await app.signInAs('nomsa');
    expect(find.text('Umoja Family Fund'), findsWidgets);
  });
}
