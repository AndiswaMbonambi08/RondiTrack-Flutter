import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/core/settings/locale_controller.dart';
import 'package:ronditrack/features/payments/application/payment_providers.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const new({super.key});

  /// Sign-out empties the database, outbox included, so it asks first when a
  /// payment has not been sent.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final waiting = await ref.read(outboxStoreProvider).countAll();
    if (!context.mounted) return;
    if (waiting > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l.signOutTitle),
          content: Text(l.signOutOutboxWarning(waiting)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l.signOutConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(localeProvider)?.languageCode;
    final languages = <(String?, String)>[
      (null, l.languageSystem),
      ('en', l.languageEnglish),
      ('zu', l.languageZulu),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.homeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.profileSignedIn),
          const SizedBox(height: 16),
          Text(
            l.languageTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final (code, label) in languages)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              selected: current == code,
              trailing: current == code ? const Icon(Icons.check) : null,
              onTap: () => unawaited(ref.read(localeProvider.notifier).choose(code)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('sign-out-button'),
            onPressed: () => unawaited(_signOut(context, ref)),
            child: Text(l.signOut),
          ),
        ],
      ),
    );
  }
}