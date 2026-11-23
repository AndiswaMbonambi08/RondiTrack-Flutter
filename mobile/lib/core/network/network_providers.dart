import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/core/network/auth_api.dart';
import 'package:ronditrack/core/network/dio_factory.dart';
import 'package:ronditrack/core/network/session_manager.dart';
import 'package:ronditrack/core/session/refresh_store.dart';

/// The flavour's API address. main() overrides it from the flavour config, so
/// no address is typed into code.
final apiBaseUrlProvider = Provider<String>(
  (ref) => throw UnimplementedError('main() overrides apiBaseUrlProvider'),
);

/// Tests override this with the in-memory store.
final refreshStoreProvider = Provider<RefreshTokenStore>(
  (ref) => const SecureRefreshTokenStore(),
);

final bareDioProvider = Provider<Dio>(
  (ref) => buildBareDio(baseUrl: ref.watch(apiBaseUrlProvider)),
);

final sessionManagerProvider = Provider<SessionManager>(
  (ref) => SessionManager(
    bare: ref.watch(bareDioProvider),
    store: ref.watch(refreshStoreProvider),
    cookieName: ref.watch(appConfigProvider).refreshCookieName,
  ),
);

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(
    bare: ref.watch(bareDioProvider),
    cookieName: ref.watch(appConfigProvider).refreshCookieName,
  ),
);
