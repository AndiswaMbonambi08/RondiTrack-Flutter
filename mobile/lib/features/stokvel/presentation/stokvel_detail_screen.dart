import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/core/sync/sync_tracker.dart';
import 'package:ronditrack/core/sync/sync_widgets.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_cache_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_cache_providers.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_body.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

/// The stokvel comes from the address. Switching stokvel changes the address,
/// and the data is keyed by id, so another stokvel's data never shows here.
///
/// [embedded] is the right-hand pane beside the list: no app bar and no
/// switcher, because the list is already on screen.
class StokvelDetailScreen extends ConsumerStatefulWidget {
  const new({required this.stokvelId, this.embedded = false, super.key});

  final String stokvelId;
  final bool embedded;

  @override
  ConsumerState<StokvelDetailScreen> createState() =>
      _StokvelDetailScreenState();
}

class _StokvelDetailScreenState extends ConsumerState<StokvelDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(StokvelDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stokvelId != widget.stokvelId) _refresh();
  }

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(stokvelRefreshProvider)(widget.stokvelId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final id = widget.stokvelId;
    final cached = ref.watch(cachedStokvelProvider(id));
    final sync = ref.watch(syncStateProvider(stokvelSyncKey(id)));
    final entries =
        ref.watch(cachedHomeProvider).value?.data ?? const <HomeEntry>[];
    final failure = sync.failure;
    final body = switch (cached) {
      AsyncData(value: final CachedValue<StokvelDetail> c) => Column(
        children: [
          if (failure != null)
            OfflineBanner(
              failure: failure,
              fetchedAt: c.fetchedAt,
              onRetry: () => unawaited(ref.read(stokvelRefreshProvider)(id)),
            ),
          if (sync.refreshing) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(stokvelRefreshProvider)(id),
              child: StokvelDetailBody(detail: c.data),
            ),
          ),
        ],
      ),
      AsyncData() when failure is NotFoundFailure => Center(
        child: Text(l.stokvelNotFound),
      ),
      AsyncData() when failure != null => NoCacheView(
        failure: failure,
        onRetry: () => unawaited(ref.read(stokvelRefreshProvider)(id)),
      ),
      _ => const LoadingView(),
    };
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.stokvelTitle),
        actions: [
          if (entries.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: l.switchStokvel,
              onSelected: (value) => StokvelRoute(id: value).go(context),
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
