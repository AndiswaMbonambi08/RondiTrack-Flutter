import 'package:dio/dio.dart';
import 'package:ronditrack/core/network/session_manager.dart';

const _sentWith = 'session.sentWith';
const _retried = 'session.retried';

class SessionEnded implements Exception {
  const new();
}

/// The one interceptor that owns the session. It puts the token on every
/// request, refreshes a little before expiry, and on a 401 refreshes once and
/// sends that request again once. A 401 for a request sent with a token that
/// has since been replaced is retried with the new token, never refreshed.
class SessionInterceptor extends Interceptor {
  new({
    required this.session,
    required this.bare,
    required this.onSessionEnded,
  });

  final SessionManager session;
  final Dio bare;
  final Future<void> Function() onSessionEnded;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (session.needsRefresh || session.accessToken == null) {
      final outcome = await session.refresh();
      if (outcome is Refused) {
        await onSessionEnded();
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: const SessionEnded(),
          ),
        );
        return;
      }
    }
    final token = session.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    options.extra[_sentWith] = token;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.extra[_retried] == true) {
      handler.next(err);
      return;
    }
    final sent = options.extra[_sentWith] as String?;
    final current = session.accessToken;
    String token;
    if (current != null && current != sent) {
      token = current;
    } else {
      final outcome = await session.refresh();
      switch (outcome) {
        case Refreshed(:final accessToken):
          token = accessToken;
        case Refused():
          await onSessionEnded();
          handler.next(err);
          return;
        case Unavailable() || Cancelled():
          handler.next(err);
          return;
      }
    }
    options.headers['Authorization'] = 'Bearer $token';
    options.extra[_retried] = true;
    try {
      handler.resolve(await bare.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
