import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_body.dart';

/// The stokvel comes from the address. Switching stokvel changes the address,
/// and the data is keyed by id, so another stokvel's data never shows here.
///
/// [embedded] is the right-hand pane beside the list: no app bar and no
/// switcher, because the list is already on screen.
class StokvelDetailScreen extends ConsumerWidget {
  const new({required this.stokvelId, this.embedded = false, super.key});

  final String stokvelId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries =
        ref.watch(homeControllerProvider).value ?? const <HomeEntry>[];
    final state = toViewState<StokvelDetail>(
      ref.watch(stokvelDetailProvider(stokvelId)),
      isEmpty: (detail) => detail.contributions.isEmpty,
    );
    final body = switch (state) {
      ViewLoading() => const LoadingView(),
      ViewEmpty() => const Center(child: Text('No contributions yet.')),
      ViewData(:final data) => StokvelDetailBody(detail: data),
      ViewFailure(:final message) => FailureView(
        message: message,
        onRetry: () => ref.invalidate(stokvelDetailProvider(stokvelId)),
      ),
    };
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stokvel'),
        actions: [
          if (entries.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch stokvel',
              onSelected: (id) => StokvelRoute(id: id).go(context),
              itemBuilder: (_) => [
                for (final e in entries)
                  PopupMenuItem(value: e.stokvelId, child: Text(e.name)),
              ],
            ),
        ],
      ),
      body: body,
    );
  }
}
