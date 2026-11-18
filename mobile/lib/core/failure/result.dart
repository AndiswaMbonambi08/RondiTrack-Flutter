import 'failure.dart';

/// What a repository returns: a value, or the [Failure] that stopped it.
/// A sealed class, so a `switch` must handle both cases.
sealed class Result<T> {
  const Result();

  /// For providers: returns the value, or throws the [Failure] so Riverpod
  /// holds an AsyncError whose error is that Failure.
  T unwrap() => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>(:final failure) => throw failure,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
