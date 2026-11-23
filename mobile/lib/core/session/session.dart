import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:ronditrack/core/session/auth_controller.dart';
export 'package:ronditrack/core/session/auth_failure.dart';
export 'package:ronditrack/core/session/auth_state.dart';

class Persona {
  const new({required this.id, required this.name});

  final String id;
  final String name;
}

const personas = [
  Persona(id: 'sipho', name: 'Sipho'),
  Persona(id: 'nomsa', name: 'Nomsa'),
  Persona(id: 'mpho', name: 'Mpho'),
  Persona(id: 'broken', name: 'Broken (dev)'),
  Persona(id: 'platform-admin', name: 'Platform admin'),
];

/// Which fake person the fake repositories answer for. Fakes only.
class CurrentPersona extends Notifier<String> {
  @override
  String build() => 'sipho';

  // Reason: a named command method reads better than a setter here.
  // ignore: use_setters_to_change_properties
  void select(String id) => state = id;
}

final currentPersonaProvider = NotifierProvider<CurrentPersona, String>(
  CurrentPersona.new,
);

/// Demo accounts, the same people as the API's demo seed. Dev flavour only
/// fills these into the sign-in form. The password is always typed.
const personaEmails = <String, String>{
  'sipho@example.com': 'sipho',
  'nomsa@example.com': 'nomsa',
  'admin@example.com': 'platform-admin',
  'broken@example.com': 'broken',
};

String? personaEmailFor(String id) => personaEmails.entries
    .where((e) => e.value == id)
    .map((e) => e.key)
    .firstOrNull;
