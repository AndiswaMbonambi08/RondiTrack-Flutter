import 'package:drift/drift.dart';

/// A payment the member tapped Pay on. The idempotency key is made once, when
/// the row is written, and every attempt sends it.
@DataClassName('OutboxRow')
class OutboxRows extends Table {
  TextColumn get id => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get stokvelId => text()();
  TextColumn get cycleId => text()();
  TextColumn get userId => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get waitUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  /// One key per payment, and one pending payment per member per cycle, so a
  /// second tap can never make a second payment.
  @override
  List<Set<Column>> get uniqueKeys => [
    {idempotencyKey},
    {stokvelId, cycleId, userId},
  ];
}
