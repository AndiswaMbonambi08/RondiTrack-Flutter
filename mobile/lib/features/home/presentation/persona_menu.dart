import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/session/session.dart';

class PersonaMenu extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person),
      tooltip: 'Switch person',
      onSelected: (id) => ref.read(authProvider.notifier).signInAs(id),
      itemBuilder: (_) => [
        for (final p in personas)
          PopupMenuItem(value: p.id, child: Text(p.name)),
      ],
    );
  }
}
