import 'package:flutter/foundation.dart' show immutable;

/// South Africa is UTC+2 all year (SAST, no daylight saving). Everything here
/// is UTC arithmetic, so the phone's own time zone changes nothing.
const saOffset = Duration(hours: 2);

/// One calendar day in South Africa.
@immutable
class SaDay {
  const new(this.year, this.month, this.day);

  /// The South African day an instant falls on. 00:30 SAST on 1 November is
  /// 22:30 UTC on 31 October, and is still 1 November here.
  factory fromInstant(DateTime instant) {
    final sast = instant.toUtc().add(saOffset);
    return SaDay(sast.year, sast.month, sast.day);
  }

  final int year;
  final int month;
  final int day;

  /// 00:00 SAST on this day, as a UTC instant. Inside the day.
  DateTime get startUtc => DateTime.utc(year, month, day).subtract(saOffset);

  /// 00:00 SAST on the next day. Outside the day: the range is half-open.
  DateTime get endUtc => DateTime.utc(year, month, day + 1).subtract(saOffset);

  @override
  bool operator ==(Object other) =>
      other is SaDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

/// Half-open bounds [from, to) for a run of South African days.
class SaRange {
  const new(this.first, this.last);

  final SaDay first;
  final SaDay last;

  DateTime get fromUtc => first.startUtc;
  DateTime get toUtc => last.endUtc;
}

/// A UTC instant with a zone, the form the API accepts, for example
/// 2026-10-31T22:00:00.000Z
String instantParam(DateTime instant) => instant.toUtc().toIso8601String();
