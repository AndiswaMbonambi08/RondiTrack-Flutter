/// Every reportable failure goes through one reporter, from one place.
abstract class ErrorReporter {
  Future<void> report(Object error, StackTrace? stack, {String? correlationId});
}

class NoopReporter implements ErrorReporter {
  const NoopReporter();
  @override
  Future<void> report(
    Object error,
    StackTrace? stack, {
    String? correlationId,
  }) async {}
}

/// For tests: shows what would have been reported, no Sentry account needed.
class RecordingReporter implements ErrorReporter {
  final reports = <({Object error, String? correlationId})>[];
  @override
  Future<void> report(
    Object error,
    StackTrace? stack, {
    String? correlationId,
  }) async => reports.add((error: error, correlationId: correlationId));
}
