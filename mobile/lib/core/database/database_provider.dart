import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/database/app_database.dart';

/// One database for the whole app. Tests override it with an in-memory one.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'ronditrack'));
  ref.onDispose(db.close);
  return db;
});
