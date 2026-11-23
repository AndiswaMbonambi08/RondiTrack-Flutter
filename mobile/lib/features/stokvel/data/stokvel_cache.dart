import 'package:drift/drift.dart';
import 'package:ronditrack/core/database/app_database.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

String _key(String id) => 'stokvel:$id';

/// A stokvel, its current cycle and that cycle's contributions, in Drift.
class StokvelCache {
  const new(this._db);

  final AppDatabase _db;

  Stream<CachedValue<StokvelDetail>?> watch(String id, String? userId) {
    final meta = _db.select(_db.cacheMetaRows)
      ..where((t) => t.metaKey.equals(_key(id)));
    return meta.watchSingleOrNull().asyncMap<CachedValue<StokvelDetail>?>((
      m,
    ) async {
      if (m == null) return null;
      final s = await (_db.select(
        _db.stokvelRows,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (s == null) return null;
      final rows =
          await (_db.select(_db.contributionRows)
                ..where((t) => t.stokvelId.equals(id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      final contributions = [
        for (final c in rows)
          Contribution(
            id: c.id,
            memberId: c.memberId,
            memberName: c.memberName,
            amount: Cents(c.amountCents),
            status: ContributionStatus.parse(c.status),
          ),
      ];
      final cycleId = s.cycleId;
      return CachedValue(
        StokvelDetail(
          stokvel: Stokvel(
            id: s.id,
            name: s.name,
            contributionAmount: Cents(s.contributionCents),
          ),
          role: StokvelRole.parse(s.role),
          cycle: cycleId == null
              ? null
              : Cycle(
                  id: cycleId,
                  number: s.cycleNumber ?? 0,
                  status: CycleStatus.parse(s.cycleStatus),
                  dueDate: s.cycleDueDate?.toUtc() ?? DateTime.utc(1970),
                ),
          contributions: contributions,
          myContribution: contributions
              .where((c) => c.memberId == userId)
              .firstOrNull
              ?.status,
        ),
        m.fetchedAt.toUtc(),
      );
    });
  }

  Future<void> replace(StokvelDetail d, DateTime now) =>
      _db.transaction(() async {
        final id = d.stokvel.id;
        final cycle = d.cycle;
        await (_db.delete(
          _db.contributionRows,
        )..where((t) => t.stokvelId.equals(id))).go();
        await _db
            .into(_db.stokvelRows)
            .insertOnConflictUpdate(
              StokvelRowsCompanion.insert(
                id: id,
                name: d.stokvel.name,
                contributionCents: d.stokvel.contributionAmount.value,
                role: d.role.wire,
                cycleId: Value(cycle?.id),
                cycleNumber: Value(cycle?.number),
                cycleStatus: Value(cycle?.status.wire),
                cycleDueDate: Value(cycle?.dueDate),
              ),
            );
        var position = 0;
        for (final c in d.contributions) {
          await _db
              .into(_db.contributionRows)
              .insertOnConflictUpdate(
                ContributionRowsCompanion.insert(
                  id: c.id,
                  stokvelId: id,
                  memberId: c.memberId,
                  memberName: c.memberName,
                  amountCents: c.amount.value,
                  status: c.status.wire,
                  position: position++,
                ),
              );
        }
        await _db
            .into(_db.cacheMetaRows)
            .insertOnConflictUpdate(
              CacheMetaRowsCompanion.insert(metaKey: _key(id), fetchedAt: now),
            );
      });

  /// The API said not found (or not yours): forget it.
  Future<void> remove(String id) => _db.transaction(() async {
    await (_db.delete(_db.stokvelRows)..where((t) => t.id.equals(id))).go();
    await (_db.delete(
      _db.contributionRows,
    )..where((t) => t.stokvelId.equals(id))).go();
    await (_db.delete(
      _db.cacheMetaRows,
    )..where((t) => t.metaKey.equals(_key(id)))).go();
  });
}