import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/dio_factory.dart';
import 'package:ronditrack/core/network/network_providers.dart';
import 'package:ronditrack/core/network/session_interceptor.dart';
import 'package:ronditrack/core/session/auth_controller.dart';

export 'package:ronditrack/core/network/network_providers.dart'
    show apiBaseUrlProvider;

/// The one Dio client. Nothing outside data/ may use it.
final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(sessionManagerProvider);
  return buildDio(
    baseUrl: ref.watch(apiBaseUrlProvider),
    readToken: () => session.accessToken,
    logSink: kDebugMode ? debugPrint : null,
    session: SessionInterceptor(
      session: session,
      bare: ref.watch(bareDioProvider),
      onSessionEnded: () => ref.read(authProvider.notifier).sessionEnded(),
    ),
  );
});
