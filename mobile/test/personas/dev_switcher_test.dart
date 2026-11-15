import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/config.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/features/home/presentation/persona_menu.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('the dev build has the switcher', (tester) async {
    await pumpApp(tester, signedInAs: 'sipho');
    expect(find.byTooltip('Switch person'), findsOneWidget);
  });

  for (final flavor in [Flavor.staging, Flavor.prod]) {
    testWidgets(
      'a ${flavor.name} build has no switcher and no address for it',
      (tester) async {
        final app = await pumpApp(tester, signedInAs: 'sipho', flavor: flavor);
        expect(find.byTooltip('Switch person'), findsNothing);
        expect(find.byType(PersonaMenu), findsNothing);
        await app.go('/dev/personas');
        expect(find.text('Page not found'), findsOneWidget);
        expect(find.byType(PersonaMenu), findsNothing);
      },
    );
  }

  test('a forgotten override fails closed: no dev tools', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(appConfigProvider).devToolsEnabled, isFalse);
  });
}
