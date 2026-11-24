import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio adapter that answers from a function, so tests need no server.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonReply(
  int status, {
  String body = '{}',
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  body,
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    ...headers,
  },
);

/// What a phone with no signal looks like to Dio.
DioException noSignal(RequestOptions options) => DioException(
  requestOptions: options,
  type: DioExceptionType.connectionError,
);
