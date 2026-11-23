import 'package:dio/dio.dart';

import 'package:ronditrack/core/network/safe_log_interceptor.dart';

// Timeouts are decisions, and the README says why each number (see
// "Decisions"). Receive is the longest on purpose: when the API's database is
// down it can take a while to fail, and the person should see its 500 and
// reference rather than "you're offline". Confirm against the measurement.
const connectTimeout = Duration(seconds: 10);
const sendTimeout = Duration(seconds: 15);
const receiveTimeout = Duration(seconds: 30);

/// Puts the access token on every request. It never clears the token:
/// signing out is the session's decision, not the transport's, so a 403 does
/// not sign anyone out.
class BearerInterceptor extends Interceptor {
  new(this._readToken);

  final String? Function() _readToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

Dio buildDio({
  required String baseUrl,
  required String? Function() readToken,
  LogSink? logSink,
  Interceptor? session,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        Headers.acceptHeader: 'application/json, application/problem+json',
      },
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(session ?? BearerInterceptor(readToken));
  if (logSink != null) dio.interceptors.add(SafeLogInterceptor(logSink));
  return dio;
}

/// A client with no session interceptor. The refresh, the retry and the auth
/// calls go through it, so none of them can wait on the session.
Dio buildBareDio({required String baseUrl, HttpClientAdapter? adapter}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        Headers.acceptHeader: 'application/json, application/problem+json',
      },
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  return dio;
}
