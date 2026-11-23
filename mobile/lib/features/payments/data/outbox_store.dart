import 'package:drift/drift.dart';
import 'package:ronditrack/core/database/app_database.dart';
import 'package:ronditrack/core/ids/secure_uuid.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/payments/domain/pending_payment.dart';

class OutboxStore {
  const new(this._db);

  final AppDatabase _db;

  PendingPayment _toDomain(OutboxRow r) => PendingPayment(
    id: r.id,
    idempotencyKey: r.idempotencyKey,
    stokvelId: r.stokvelId,
    cycleId: r.cycleId,
    userId: r.userId,
    amount: Cents(r.amountCents),
    createdAt: r.createdAt.toUtc(),
    attempts: r.attempts,
    waitUntil: r.waitUntil?.toUtc(),
  );

  Stream<List<PendingPayment>> watch({
    required String userId,
    String? stokvelId,
  }) {
    final query = _db.select(_db.outboxRows)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    if (stokvelId != null) {
      query.where((t) => t.stokvelId.equals(stokvelId));
    }
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  /// Every unsent payment on this phone. Sign-out empties the outbox, so it
  /// asks first when this is above zero.
  Future<int> countAll() async =>
      (await _db.select(_db.outboxRows).get()).length;

  Future<PendingPayment?> find(String id) async {
    final row = await (_db.select(
      _db.outboxRows,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// How many unsent payments this person has. Sign-out asks first when > 0.
  Future<int> count(String userId) async {
    final rows = await (_db.select(
      _db.outboxRows,
    )..where((t) => t.userId.equals(userId))).get();
    return rows.length;
  }

  /// Writes the payment and its key, once, at the tap. A second tap for the
  /// same member and cycle returns the payment that is already waiting, with
  /// its original key, and never makes another.
  Future<PendingPayment> enqueue({
    required String stokvelId,
    required String cycleId,
    required String userId,
    required Cents amount,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.outboxRows)..where(
                (t) =>
                    t.stokvelId.equals(stokvelId) &
                    t.cycleId.equals(cycleId) &
                    t.userId.equals(userId),
              ))
              .getSingleOrNull();
      if (existing != null) return _toDomain(existing);
      final id = newUuid();
      final key = newUuid();
      await _db
          .into(_db.outboxRows)
          .insert(
            OutboxRowsCompanion.insert(
              id: id,
              idempotencyKey: key,
              stokvelId: stokvelId,
              cycleId: cycleId,
              userId: userId,
              amountCents: amount.value,
              createdAt: now,
            ),
          );
      return PendingPayment(
        id: id,
        idempotencyKey: key,
        stokvelId: stokvelId,
        cycleId: cycleId,
        userId: userId,
        amount: amount,
        createdAt: now,
        attempts: 0,
        waitUntil: null,
      );
    });
  }

  Future<void> recordAttempt(String id) async {
    final row = await find(id);
    if (row == null) return;
    await (_db.update(_db.outboxRows)..where((t) => t.id.equals(id))).write(
      OutboxRowsCompanion(attempts: Value(row.attempts + 1)),
    );
  }

  Future<void> setWait(String id, DateTime? until) =>
      (_db.update(_db.outboxRows)..where((t) => t.id.equals(id))).write(
        OutboxRowsCompanion(waitUntil: Value(until)),
      );

  Future<void> remove(String id) async {
    await (_db.delete(_db.outboxRows)..where((t) => t.id.equals(id))).go();
  }
}