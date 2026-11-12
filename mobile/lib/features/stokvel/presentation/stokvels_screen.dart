import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/layout/breakpoints.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';

const _listPaneWidth = 340.0;

class StokvelsScreen extends ConsumerWidget {
  const new({this.selectedId, super.key});

  /// The stokvel in the address, if any.
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideBySide = windowSizeOf(context) == WindowSize.expanded;
    final id = selectedId;
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
        ViewData(:final data) =>
          sideBySide
              ? Row(
                  children: [
                    SizedBox(
                      width: _listPaneWidth,
                      child: _StokvelList(entries: data, selectedId: id),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: id == null
                          ? const Center(child: Text('Select a stokvel'))
                          : StokvelDetailScreen(stokvelId: id, embedded: true),
                    ),
                  ],
                )
              : _StokvelList(entries: data, selectedId: id),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: () => ref.invalidate(homeControllerProvider),
        ),
      },
    );
  }
}

class _StokvelList extends StatelessWidget {
  const new({required this.entries, required this.selectedId});

  final List<HomeEntry> entries;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('stokvels-list'),
      children: [
        for (final e in entries)
          ListTile(
            title: Text(e.name),
            subtitle: Text('Your role: ${roleLabel(e.role)}'),
            selected: e.stokvelId == selectedId,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => StokvelRoute(id: e.stokvelId).go(context),
          ),
      ],
    );
  }
}
