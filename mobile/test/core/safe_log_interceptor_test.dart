import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/safe_log_interceptor.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);

  final int status;
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

Future<String> _call(int status, String body) async {
  final lines = <String>[];
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _Adapter(status, body)
    ..interceptors.add(SafeLogInterceptor(lines.add));
  try {
    await dio.post<dynamic>(
      '/api/v1/stokvels/abc/contributions?amount=987654&name=Thandi',
      data: {'amount': 987654, 'memberName': 'Thandi Nkosi'},
      options: Options(
        headers: {
          'Authorization': 'Bearer SECRET-TOKEN',
          'Cookie': 'refresh_token=SECRET-COOKIE',
        },
      ),
    );
  } on DioException {
    // The interceptor has already logged it.
  }
  return lines.join('\n');
}

void main() {
  void expectNoPersonalData(String log) {
    for (final leak in [
      'SECRET',
      'Bearer',
      'Cookie',
      'refresh_token',
      '987654',
      'Thandi',
      'amount',
      '5000',
    ]) {
      expect(log, isNot(contains(leak)), reason: 'log leaked "$leak"');
    }
  }

  test('a success logs method, path, status and time only', () async {
    final log = await _call(200, '{"memberName":"Thandi Nkosi"}');
    expect(log, contains('POST /api/v1/stokvels/abc/contributions 200'));
    expect(log, contains('ms'));
    expectNoPersonalData(log);
  });

  test('an error adds the correlationId and nothing from the body', () async {
    final log = await _call(
      500,
      '{"detail":"Thandi owes 5000","correlationId":"0HN1:0001"}',
    );
    expect(log, contains(' 500 '));
    expect(log, contains('correlationId=0HN1:0001'));
    expectNoPersonalData(log);
  });

  test('a correlationId that is not a plain id is not logged', () async {
    final log = await _call(500, '{"correlationId":"Thandi Nkosi owes R5000"}');
    expect(log, isNot(contains('correlationId=')));
    expectNoPersonalData(log);
  });
}
