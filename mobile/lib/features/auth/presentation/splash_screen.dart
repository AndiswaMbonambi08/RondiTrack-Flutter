import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/session/session.dart';

/// Shown while the stored session is checked. Never the sign-in form first.
/// With no signal the person stays signed in and can try again or sign out.
class SplashScreen extends ConsumerWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final offline = auth is Restoring && auth.offline;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: offline
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No connection',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are still signed in. Check your connection and try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () =>
                          unawaited(ref.read(authProvider.notifier).restore()),
                      child: const Text('Try again'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          unawaited(ref.read(authProvider.notifier).signOut()),
                      child: const Text('Sign out'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  semanticsLabel: 'Restoring your session',
                ),
        ),
      ),
    );
  }
}
