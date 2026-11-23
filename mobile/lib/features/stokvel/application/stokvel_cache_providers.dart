import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/database/database_provider.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/failure_mapper.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/core/sync/sync_tracker.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/stokvel_cache.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

String stokvelSyncKey(String id) => 'stokvel:$id';

final stokvelCacheProvider = Provider<StokvelCache>(
  (ref) => StokvelCache(ref.watch(appDatabaseProvider)),
);

final cachedStokvelProvider = StreamProvider.autoDispose
    .family<CachedValue<StokvelDetail>?, String>((ref, id) {
      ref.watch(sessionScopeProvider);
      final userId = ref.watch(currentUserIdProvider);
      return ref.watch(stokvelCacheProvider).watch(id, userId);
    });

final stokvelRefreshProvider = Provider<Future<void> Function(String)>(
  (ref) =>
      (id) => ref.read(syncTrackerProvider.notifier).run(
        stokvelSyncKey(id),
        () async {
          try {
            final detail = await ref
                .read(stokvelRepositoryProvider)
                .fetchDetail(id);
            await ref
                .read(stokvelCacheProvider)
                .replace(detail, DateTime.now().toUtc());
          } on Object catch (error) {
            if (toFailure(error) is NotFoundFailure) {
              await ref.read(stokvelCacheProvider).remove(id);
            }
            rethrow;
          }
        },
      ),
);