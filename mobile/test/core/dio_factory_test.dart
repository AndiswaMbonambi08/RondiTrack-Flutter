import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/dio_factory.dart';
import 'package:ronditrack/core/session/access_token.dart';

class _Recorder implements HttpClientAdapter {
  new(this.status);

  final int status;
  RequestOptions? last;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  test('the token goes on every request, as it is at that moment', () async {
    String? token = 't1';
    final recorder = _Recorder(200);
    final dio = buildDio(
      baseUrl: 'http://api.test',
      readToken: () => token,
      adapter: recorder,
    );

    await dio.get<dynamic>('/a');
    expect(recorder.last!.headers['Authorization'], 'Bearer t1');

    token = 't2';
    await dio.get<dynamic>('/b');
    expect(recorder.last!.headers['Authorization'], 'Bearer t2');
  });

  test('with no token there is no Authorization header', () async {
    final recorder = _Recorder(200);
    final dio = buildDio(
      baseUrl: 'http://api.test',
      readToken: () => null,
      adapter: recorder,
    );
    await dio.get<dynamic>('/a');
    expect(recorder.last!.headers.containsKey('Authorization'), isFalse);
  });

  test('a 403 does not sign anyone out', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(accessTokenProvider.notifier).set('t1');

    final dio = buildDio(
      baseUrl: 'http://api.test',
      readToken: () => container.read(accessTokenProvider),
      adapter: _Recorder(403),
    );
    await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));

    expect(container.read(accessTokenProvider), 't1');
  });

  test('the timeouts are set, not left to the defaults', () {
    final dio = buildDio(baseUrl: 'http://api.test', readToken: () => null);
    expect(dio.options.connectTimeout, connectTimeout);
    expect(dio.options.sendTimeout, sendTimeout);
    expect(dio.options.receiveTimeout, receiveTimeout);
    expect(dio.options.baseUrl, 'http://api.test');
  });
}
