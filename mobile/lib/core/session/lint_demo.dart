import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lint_demo.g.dart';

@riverpod
class LintDemo extends _$LintDemo {
  // Public field on a notifier: only riverpod_lint reports this.
  int counter = 0;

  @override
  int build() => 0;
}