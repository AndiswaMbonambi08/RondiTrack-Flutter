/// Whole cents. Every amount in the domain is a [Cents]; never a double.
extension type const Cents(int value) {
  static const zero = Cents(0);

  Cents operator +(Cents other) => Cents(value + other.value);
  Cents operator -(Cents other) => Cents(value - other.value);

  bool get isNegative => value < 0;
}