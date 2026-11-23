import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/network_providers.dart';
import 'package:ronditrack/core/session/session.dart';

const _spoil = '__spoil';
const _expire = '__expire';

/// Dev flavour only: the shell does not build it in staging or prod. A person
/// fills in the sign-in email (the password is typed). The two session tools
/// spoil the access token or make it expire now.
class PersonaMenu extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.build_circle_outlined),
      tooltip: 'Dev tools',
      onSelected: (value) {
        final session = ref.read(sessionManagerProvider);
        switch (value) {
          case _spoil:
            session.spoilAccessToken();
          case _expire:
            session.expireAccessTokenNow();
          default:
            final email = personaEmailFor(value);
            if (email == null) return;
            ref.read(signInPrefillProvider.notifier).set(email);
            unawaited(ref.read(authProvider.notifier).signOut());
        }
      },
      itemBuilder: (_) => [
        for (final p in personas)
          if (personaEmailFor(p.id) != null)
            PopupMenuItem(value: p.id, child: Text('Sign in as ${p.name}')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: _spoil, child: Text('Spoil access token')),
        const PopupMenuItem(
          value: _expire,
          child: Text('Expire access token now'),
        ),
      ],
    );
  }
}
