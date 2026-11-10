import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

part 'home_entry.freezed.dart';

/// One card on Home. The numbers come from the API; the app never computes.
@freezed
abstract class HomeEntry with _$HomeEntry {
  const factory HomeEntry({
    required String stokvelId,
    required String name,
    required StokvelRole role,
    required Cents paid,
    required Cents owed,
    required Cents arrears,
    required DateTime? nextPayout,
  }) = _HomeEntry;
}
