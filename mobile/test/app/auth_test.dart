import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/session/session.dart';

void main() {
  test('starts signed out', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(authProvider), isNull);
  });

  test('signs in by email, ignoring case and spaces', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final ok = c
        .read(authProvider.notifier)
        .signInWithEmail(' Nomsa@Example.com ');
    expect(ok, isTrue);
    expect(c.read(authProvider), 'nomsa');
    expect(c.read(currentPersonaProvider), 'nomsa');
  });

  test('unknown and inactive accounts cannot sign in', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier);
    expect(auth.signInWithEmail('lindiwe@example.com'), isFalse);
    expect(auth.signInWithEmail('nobody@example.com'), isFalse);
    expect(c.read(authProvider), isNull);
  });

  test('sign-out returns to signed out', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(authProvider.notifier)
      ..signInAs('sipho')
      ..signOut();
    expect(c.read(authProvider), isNull);
  });
}
