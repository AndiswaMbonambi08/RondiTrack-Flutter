import 'package:drift/drift.dart';

@DataClassName('HomeRow')
class HomeRows extends Table {
  TextColumn get stokvelId => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  IntColumn get paidCents => integer()();
  IntColumn get owedCents => integer()();
  IntColumn get arrearsCents => integer()();
  DateTimeColumn get nextPayoutUtc => dateTime().nullable()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {stokvelId};
}