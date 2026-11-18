import 'package:dio/dio.dart';

typedef LogSink = void Function(String line);

/// Logs the method, the path, the status, the time and an error's
/// correlationId. Never a header, a cookie, a body or a query value: under
/// POPIA a member's name, amounts and arrears are personal information.
class SafeLogInterceptor extends Interceptor {
  SafeLogInterceptor(this._sink, {DateTime Function() now = DateTime.now})
    : _now = now;

  final LogSink _sink;
  final DateTime Function() _now;

  static const _startedKey = 'safeLog.startedAt';
  static final _safeId = RegExp(r'^[A-Za-z0-9:_-]{1,64}$');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = _now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _sink(_line(response.requestOptions, status: response.statusCode));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    _sink(
      _line(
        err.requestOptions,
        status: response?.statusCode,
        correlationId: _correlationId(response?.data),
        failure: response == null ? err.type.name : null,
      ),
    );
    handler.next(err);
  }

  String _line(
    RequestOptions options, {
    int? status,
    String? correlationId,
    String? failure,
  }) {
    final started = options.extra[_startedKey];
    final ms = started is DateTime
        ? _now().difference(started).inMilliseconds
        : null;
    return [
      options.method,
      options.uri.path,
      status?.toString() ?? 'no-answer',
      if (ms != null) '${ms}ms',
      ?failure,
      if (correlationId != null) 'correlationId=$correlationId',
    ].join(' ');
  }

  String? _correlationId(Object? data) {
    if (data is! Map) return null;
    final id = data['correlationId'];
    return id is String && _safeId.hasMatch(id) ? id : null;
  }
}
