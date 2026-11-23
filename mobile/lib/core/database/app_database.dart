import 'package:drift/drift.dart';
import 'package:ronditrack/core/database/cache_meta_table.dart';
import 'package:ronditrack/features/home/data/home_tables.dart';
import 'package:ronditrack/features/payments/data/outbox_tables.dart';
import 'package:ronditrack/features/stokvel/data/stokvel_tables.dart';

part 'app_database.g.dart';

const _signedInUserKey = 'signedInUser';

@DriftDatabase(
  tables: [CacheMetaRows, HomeRows, StokvelRows, ContributionRows, OutboxRows],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  @override
  int get schemaVersion => 1;

  /// Sign-out: every cached row, the outbox and who was signed in.
  Future<void> wipe() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });

  /// The session ended on its own (the refresh was refused). Everything the
  /// last person saw goes, but a payment that was never sent stays: it is
  /// only shown to, and sent for, the person it belongs to.
  Future<void> wipeCaches() => transaction(() async {
    for (final table in allTables) {
      if (table.actualTableName == outboxRows.actualTableName) continue;
      await delete(table).go();
    }
  });

  Future<String?> savedUserId() async {
    final row = await (select(
      cacheMetaRows,
    )..where((t) => t.metaKey.equals(_signedInUserKey))).getSingleOrNull();
    return row?.metaValue;
  }

  Future<void> saveUserId(String userId) =>
      into(cacheMetaRows).insertOnConflictUpdate(
        CacheMetaRowsCompanion.insert(
          metaKey: _signedInUserKey,
          metaValue: Value(userId),
          fetchedAt: DateTime.now().toUtc(),
        ),
      );
}
