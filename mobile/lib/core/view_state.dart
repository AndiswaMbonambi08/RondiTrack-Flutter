import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/core/failure/failure.dart';

sealed class ViewState<T> {
  const new();
}

final class ViewLoading<T> extends ViewState<T> {
  const new();
}

final class ViewEmpty<T> extends ViewState<T> {
  const new();
}

final class ViewData<T> extends ViewState<T> {
  const new(this.data, {this.refreshing = false});

  final T data;
  final bool refreshing;
}

final class ViewFailure<T> extends ViewState<T> {
  const new(this.message, {this.failure});

  final String message;

  /// The typed Failure behind the message, when there is one. A screen reads
  /// it for the wait, the reference and the retry. It never sees Dio.
  final Failure? failure;
}

String failureMessage(Object error) => switch (error) {
  NotFoundException() => 'Stokvel not found',
  final Failure failure => failure.message,
  _ => 'Something went wrong. Please try again.',
};

/// Turns provider state into the sealed view state. Old data stays on screen
/// while reloading; "no items" is empty, not data.
ViewState<T> toViewState<T>(
  AsyncValue<T> async, {
  required bool Function(T value) isEmpty,
}) {
  if (async.hasValue) {
    final value = async.requireValue;
    if (isEmpty(value)) return ViewEmpty<T>();
    return ViewData<T>(value, refreshing: async.isLoading);
  }
  if (async.isLoading) return ViewLoading<T>();
  if (async.hasError) {
    final error = async.error!;
    return ViewFailure<T>(
      failureMessage(error),
      failure: error is Failure ? error : null,
    );
  }
  return ViewLoading<T>();
}
