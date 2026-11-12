import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/layout/breakpoints.dart';

void main() {
  test('under 600 dp is compact', () {
    expect(windowSizeForWidth(360), WindowSize.compact);
    expect(windowSizeForWidth(599.9), WindowSize.compact);
  });

  test('600 to 839 dp is medium', () {
    expect(windowSizeForWidth(600), WindowSize.medium);
    expect(windowSizeForWidth(839.9), WindowSize.medium);
  });

  test('840 dp or wider is expanded', () {
    expect(windowSizeForWidth(840), WindowSize.expanded);
    expect(windowSizeForWidth(1280), WindowSize.expanded);
  });
}
