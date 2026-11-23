import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/database/database_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/core/sync/sync_tracker.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/data/home_cache.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';

const homeSyncKey = 'home';

final homeCacheProvider = Provider<HomeCache>(
  (ref) => HomeCache(ref.watch(appDatabaseProvider)),
);

/// What the phone has, at once, with or without signal.
final StreamProvider<CachedValue<List<HomeEntry>>?> cachedHomeProvider =
    StreamProvider.autoDispose<CachedValue<List<HomeEntry>>?>((ref) {
      ref.watch(sessionScopeProvider);
      return ref.watch(homeCacheProvider).watch();
    });

/// Fetch in the background and put the answer in the cache.
final homeRefreshProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => ref.read(syncTrackerProvider.notifier).run(homeSyncKey, () async {
        final entries = await ref.read(homeRepositoryProvider).fetchHome();
        await ref
            .read(homeCacheProvider)
            .replace(entries, DateTime.now().toUtc());
      }),
);
