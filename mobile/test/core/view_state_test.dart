import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/view_state.dart';

void main() {
  bool isEmpty(List<int> v) => v.isEmpty;

  test('no items is empty, not data', () {
    expect(
      toViewState<List<int>>(const AsyncData([]), isEmpty: isEmpty),
      isA<ViewEmpty<List<int>>>(),
    );
  });

  test('items are data', () {
    expect(
      toViewState<List<int>>(const AsyncData([1]), isEmpty: isEmpty),
      isA<ViewData<List<int>>>(),
    );
  });

  test('loading and failure', () {
    expect(
      toViewState<List<int>>(const AsyncLoading(), isEmpty: isEmpty),
      isA<ViewLoading<List<int>>>(),
    );
    expect(
      toViewState<List<int>>(
        AsyncError(Exception('x'), StackTrace.empty),
        isEmpty: isEmpty,
      ),
      isA<ViewFailure<List<int>>>(),
    );
  });
}
