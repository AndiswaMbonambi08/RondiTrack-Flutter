// Wire strings are taken from the API (openapi/v1.json). Case matters.
// A string the API adds later becomes `unknown`, never an exception.

enum CycleStatus {
  open('Open'),
  closed('Closed'),
  paidOut('PaidOut'),
  unknown('');

  new(this.wire);

  final String wire;

  static CycleStatus parse(String? value) => values.firstWhere(
    (e) => e != unknown && e.wire == value,
    orElse: () => unknown,
  );
}

enum ContributionStatus {
  pending('Pending'),
  paid('Paid'),
  confirmed('Confirmed'),
  unknown('');

  new(this.wire);

  final String wire;

  static ContributionStatus parse(String? value) => values.firstWhere(
    (e) => e != unknown && e.wire == value,
    orElse: () => unknown,
  );
}

enum StokvelRole {
  member('Member'),
  treasurer('Treasurer'),
  admin('Admin'),
  unknown('');

  new(this.wire);

  final String wire;

  static StokvelRole parse(String? value) => values.firstWhere(
    (e) => e != unknown && e.wire == value,
    orElse: () => unknown,
  );
}
