import 'package:drift/drift.dart';

/// When each cache was last filled, plus a few small facts about this phone
/// (who was signed in). Sign-out deletes every row.
@DataClassName('CacheMetaRow')
class CacheMetaRows extends Table {
  TextColumn get metaKey => text()();
  TextColumn get metaValue => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {metaKey};
}
