import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

class StokvelsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = toViewState<List<HomeEntry>>(
      ref.watch(homeControllerProvider),
      isEmpty: (entries) => entries.isEmpty,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Stokvels')),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => const Center(
          child: Text('You are not in any stokvels yet.'),
        ),
        ViewData(:final data) => ListView(
          key: const PageStorageKey<String>('stokvels-list'),
          children: [
            for (final e in data)
              ListTile(
                title: Text(e.name),
                subtitle: Text('Your role: ${roleLabel(e.role)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => StokvelRoute(id: e.stokvelId).go(context),
              ),
          ],
        ),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: () => ref.invalidate(homeControllerProvider),
        ),
      },
    );
  }
}
