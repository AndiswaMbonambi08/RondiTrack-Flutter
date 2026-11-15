import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/session/session.dart';

/// Dev flavour only: the shell does not build it in staging or prod.
class PersonaMenu extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person),
      tooltip: 'Switch person',
      onSelected: (id) =>
          unawaited(ref.read(authProvider.notifier).switchTo(id)),
      itemBuilder: (_) => [
        for (final p in personas)
          PopupMenuItem(value: p.id, child: Text(p.name)),
      ],
    );
  }
}
