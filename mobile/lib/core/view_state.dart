import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/errors.dart';

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
  const new(this.message);

  final String message;
}

String failureMessage(Object error) => error is NotFoundException
    ? 'Stokvel not found'
    : 'Something went wrong. Please try again.';

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
  if (async.hasError) return ViewFailure<T>(failureMessage(async.error!));
  return ViewLoading<T>();
}
