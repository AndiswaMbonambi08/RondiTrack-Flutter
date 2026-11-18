/// An instant from the API, kept in UTC.
DateTime? utcInstant(Object? value) =>
    value is String ? DateTime.parse(value).toUtc() : null;

/// A date-only value (yyyy-MM-dd) as UTC midnight, never shifted by a time zone.
DateTime? dateOnly(Object? value) {
  if (value is! String || value.length < 10) return null;
  final parts = value.substring(0, 10).split('-');
  if (parts.length != 3) return null;
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}