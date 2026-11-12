import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

class Persona {
  const new({required this.id, required this.name});

  final String id;
  final String name;
}

const personas = [
  Persona(id: 'sipho', name: 'Sipho'),
  Persona(id: 'nomsa', name: 'Nomsa'),
  Persona(id: 'broken', name: 'Broken (dev)'),
  Persona(id: 'platform-admin', name: 'Platform admin'),
];

/// Stands in for the signed-in person until Week 11.
@Riverpod(keepAlive: true)
class CurrentPersona extends _$CurrentPersona {
  @override
  String build() => 'sipho';

  // Reason: a named command method reads better than a setter here.
  // ignore: use_setters_to_change_properties
  void select(String id) => state = id;
}

/// Fake sign-in accounts, the same people as the API's demo seed.
/// lindiwe@example.com is inactive in the API, so it is not listed.
const personaEmails = <String, String>{
  'sipho@example.com': 'sipho',
  'nomsa@example.com': 'nomsa',
  'admin@example.com': 'platform-admin',
  'broken@example.com': 'broken',
};

String? personaIdForEmail(String email) =>
    personaEmails[email.trim().toLowerCase()];

/// Who is signed in: a persona id, or null when signed out.
/// Week 11 replaces the fake with the API. The gate only reads this.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  String? build() => null;

  /// Signs in by email. Returns false for an unknown or inactive account.
  bool signInWithEmail(String email) {
    final id = personaIdForEmail(email);
    if (id == null) return false;
    signInAs(id);
    return true;
  }

  void signInAs(String id) {
    ref.read(currentPersonaProvider.notifier).select(id);
    state = id;
  }

  void signOut() => state = null;
}
