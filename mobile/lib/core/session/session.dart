import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

class Persona {
  const Persona({required this.id, required this.name});

  final String id;
  final String name;
}

const personas = [
  Persona(id: 'lerato', name: 'Lerato'),
  Persona(id: 'thabo', name: 'Thabo'),
  Persona(id: 'sipho', name: 'Sipho'),
];

/// Stands in for the signed-in person until Week 11.
@Riverpod(keepAlive: true)
class CurrentPersona extends _$CurrentPersona {
  @override
  String build() => 'lerato';

  // ignore: use_setters_to_change_properties
  void select(String id) => state = id;
}
