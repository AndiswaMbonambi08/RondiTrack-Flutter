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
