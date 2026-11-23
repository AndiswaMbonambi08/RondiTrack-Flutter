import 'package:drift/drift.dart';

@DataClassName('StokvelRow')
class StokvelRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get contributionCents => integer()();
  TextColumn get role => text()();
  TextColumn get cycleId => text().nullable()();
  IntColumn get cycleNumber => integer().nullable()();
  TextColumn get cycleStatus => text().nullable()();
  DateTimeColumn get cycleDueDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ContributionRow')
class ContributionRows extends Table {
  TextColumn get id => text()();
  TextColumn get stokvelId => text()();
  TextColumn get memberId => text()();
  TextColumn get memberName => text()();
  IntColumn get amountCents => integer()();
  TextColumn get status => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
