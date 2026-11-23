import 'package:drift/drift.dart';
import 'package:ronditrack/core/database/app_database.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

const _key = 'home';

/// Home lives in Drift. Nothing above data/ sees a row.
class HomeCache {
  const new(this._db);

  final AppDatabase _db;

  /// Null means nothing has ever been cached. An empty list is a real answer.
  Stream<CachedValue<List<HomeEntry>>?> watch() {
    final meta = _db.select(_db.cacheMetaRows)
      ..where((t) => t.metaKey.equals(_key));
    return meta.watchSingleOrNull().asyncMap<CachedValue<List<HomeEntry>>?>((
      m,
    ) async {
      if (m == null) return null;
      final rows = await (_db.select(
        _db.homeRows,
      )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
      return CachedValue([
        for (final r in rows)
          HomeEntry(
            stokvelId: r.stokvelId,
            name: r.name,
            role: StokvelRole.parse(r.role),
            paid: Cents(r.paidCents),
            owed: Cents(r.owedCents),
            arrears: Cents(r.arrearsCents),
            nextPayout: r.nextPayoutUtc?.toUtc(),
          ),
      ], m.fetchedAt.toUtc());
    });
  }

  Future<void> replace(List<HomeEntry> entries, DateTime now) =>
      _db.transaction(() async {
        await _db.delete(_db.homeRows).go();
        var position = 0;
        for (final e in entries) {
          await _db
              .into(_db.homeRows)
              .insert(
                HomeRowsCompanion.insert(
                  stokvelId: e.stokvelId,
                  name: e.name,
                  role: e.role.wire,
                  paidCents: e.paid.value,
                  owedCents: e.owed.value,
                  arrearsCents: e.arrears.value,
                  nextPayoutUtc: Value(e.nextPayout),
                  position: position++,
                ),
              );
        }
        await _db
            .into(_db.cacheMetaRows)
            .insertOnConflictUpdate(
              CacheMetaRowsCompanion.insert(metaKey: _key, fetchedAt: now),
            );
      });
}
