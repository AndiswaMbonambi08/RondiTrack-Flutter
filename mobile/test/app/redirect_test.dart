import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/redirect.dart';

String? _go(String to, {required bool signedIn}) =>
    redirectFor(signedIn: signedIn, location: Uri.parse(to));

Uri _target(String? r) => Uri.parse(r!);

void main() {
  group('signed out', () {
    test('a stokvel link goes to sign-in and remembers the address', () {
      final t = _target(_go('/stokvels/umoja-family-fund', signedIn: false));
      expect(t.path, '/sign-in');
      expect(t.queryParameters['from'], '/stokvels/umoja-family-fund');
    });

    test('a cycle link is remembered whole', () {
      final t = _target(
        _go('/stokvels/umoja-family-fund/cycles/c5', signedIn: false),
      );
      expect(
        t.queryParameters['from'],
        '/stokvels/umoja-family-fund/cycles/c5',
      );
    });

    test('/join/:code is remembered', () {
      final t = _target(_go('/join/abc123', signedIn: false));
      expect(t.path, '/sign-in');
      expect(t.queryParameters['from'], '/join/abc123');
    });

    test('Home goes to plain sign-in', () {
      expect(_go('/', signedIn: false), '/sign-in');
    });

    test('an address outside the app is not remembered', () {
      expect(_go('/somewhere-else', signedIn: false), '/sign-in');
    });

    test('the sign-in page itself is left alone', () {
      expect(_go('/sign-in', signedIn: false), isNull);
    });
  });

  group('signed in', () {
    test('app addresses pass through', () {
      expect(_go('/stokvels', signedIn: true), isNull);
      expect(_go('/join/abc123', signedIn: true), isNull);
    });

    test('the sign-in page sends you Home', () {
      expect(_go('/sign-in', signedIn: true), '/');
    });

    test('the remembered /join/:code is where you land', () {
      expect(
        _go('/sign-in?from=%2Fjoin%2Fabc123', signedIn: true),
        '/join/abc123',
      );
    });

    test('a remembered address from outside the app lands on Home', () {
      expect(
        _go('/sign-in?from=https%3A%2F%2Fevil.example', signedIn: true),
        '/',
      );
      expect(_go('/sign-in?from=%2F%2Fevil.example', signedIn: true), '/');
      expect(_go('/sign-in?from=%2Fsign-in', signedIn: true), '/');
      expect(_go('/sign-in?from=%2Funknown', signedIn: true), '/');
    });
  });

  group('isInAppAddress', () {
    const cases = <String?, bool>{
      '/': true,
      '/stokvels': true,
      '/stokvels/umoja-family-fund/cycles/c5': true,
      '/join/abc123': true,
      '/activity': true,
      '/profile': true,
      '/sign-in': false,
      '/sign-in?from=x': false,
      'https://evil.example': false,
      '//evil.example': false,
      'javascript:alert(1)': false,
      '/unknown': false,
      '': false,
      null: false,
    };
    for (final entry in cases.entries) {
      test('${entry.key} is ${entry.value}', () {
        expect(isInAppAddress(entry.key), entry.value);
      });
    }
  });
}
