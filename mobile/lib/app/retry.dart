import 'package:ronditrack/core/errors.dart';

/// The ProviderScope's retry policy. Riverpod 3 retries every failed provider
/// and shows loading meanwhile, so a link to someone else's stokvel would sit
/// on a spinner for most of a minute.
Duration? appRetry(int retryCount, Object error) => switch (error) {
  // Asking again never turns a 404 into a 200.
  NotFoundException() => null,
  // Everything else shows its Retry button straight away; the person decides.
  _ => null,
};
