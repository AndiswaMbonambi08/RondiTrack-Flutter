// Wire strings are taken from the API (README, Contract notes: Payouts).
// Case matters. A string the API adds later becomes `unknown`, never an
// exception.

enum PayoutStatus {
  paid('Paid'),
  next('Next'),
  waiting('Waiting'),
  unknown('');

  new(this.wire);

  final String wire;

  static PayoutStatus parse(String? value) => values.firstWhere(
    (e) => e != unknown && e.wire == value,
    orElse: () => unknown,
  );
}
