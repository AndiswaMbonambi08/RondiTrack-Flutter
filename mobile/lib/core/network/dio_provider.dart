import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/network/dio_factory.dart';
import 'package:ronditrack/core/session/access_token.dart';

part 'dio_provider.g.dart';

/// The flavour's API address. main() overrides it from the flavour config, so
/// no address is typed into code.
@Riverpod(keepAlive: true)
String apiBaseUrl(Ref ref) =>
    throw UnimplementedError('main() overrides apiBaseUrlProvider');

/// The one Dio client. Nothing outside data/ may use it.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) => buildDio(
  baseUrl: ref.watch(apiBaseUrlProvider),
  readToken: () => ref.read(accessTokenProvider),
  logSink: kDebugMode ? debugPrint : null,
);
