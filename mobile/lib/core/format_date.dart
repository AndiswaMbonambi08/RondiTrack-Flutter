/// Date-only, ISO form (2026-10-31), in South African time (UTC+2, no DST).
/// A date-only value (UTC midnight) keeps its date; an instant such as
/// nextPayoutUtc is shown on the Johannesburg calendar day.
String formatDate(DateTime date) {
  final local = date.toUtc().add(const Duration(hours: 2));
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
