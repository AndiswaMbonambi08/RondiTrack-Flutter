import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/layout/breakpoints.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

const _listPaneWidth = 340.0;

class StokvelsScreen extends ConsumerWidget {
  const new({this.selectedId, super.key});

  /// The stokvel in the address, if any.
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sideBySide = windowSizeOf(context) == WindowSize.expanded;
    final id = selectedId;
    final state = toViewState<List<HomeEntry>>(
      ref.watch(homeControllerProvider),
      isEmpty: (entries) => entries.isEmpty,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.stokvelsTitle)),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => Center(child: Text(l.homeEmptyTitle)),
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
                          ? Center(child: Text(l.selectStokvel))
                          : StokvelDetailScreen(stokvelId: id, embedded: true),
                    ),
                  ],
                )
              : _StokvelList(entries: data, selectedId: id),
        ViewFailure(:final message, :final failure) => FailureView(
          message: message,
          failure: failure,
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
    final l = AppLocalizations.of(context);
    return ListView(
      key: const PageStorageKey<String>('stokvels-list'),
      children: [
        for (final e in entries)
          ListTile(
            title: Text(e.name),
            subtitle: Text(l.yourRole(roleText(l, e.role))),
            selected: e.stokvelId == selectedId,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => StokvelRoute(id: e.stokvelId).go(context),
          ),
      ],
    );
  }
}
