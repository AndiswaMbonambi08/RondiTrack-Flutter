import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/access_token.dart';
import 'package:ronditrack/core/session/session.dart';

part 'dev_session.g.dart';

/// Dev only: signs the current persona in for real, once, before the first
/// call. The password comes from --dart-define=SEED_PASSWORD and is never
/// committed. The token goes to memory only.
class DevSession {
  DevSession(this._dio, this._setToken, this._email, this._password);

  final Dio _dio;
  final void Function(String?) _setToken;
  final String _email;
  final String _password;

  Future<void>? _login;
  String? userId;

  Future<void> ensure() => _login ??= _signIn();

  Future<void> _signIn() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {'email': _email, 'password': _password},
      );
      final token = response.data!['accessToken']! as String;
      _setToken(token);
      userId = _subject(token);
    } on Object {
      _login = null;
      rethrow;
    }
  }

  static String? _subject(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    final id =
        payload['sub'] ??
        payload['nameid'] ??
        payload['http://schemas.xmlsoap.org/ws/2005/08/identity/claims/nameidentifier'];
    return id is String ? id : null;
  }
}

@Riverpod(keepAlive: true)
DevSession devSession(Ref ref) {
  final persona = ref.watch(currentPersonaProvider);
  final email = personaEmails.entries
      .firstWhere(
        (e) => e.value == persona,
        orElse: () => const MapEntry('', ''),
      )
      .key;
  return DevSession(
    ref.watch(dioProvider),
    ref.read(accessTokenProvider.notifier).set,
    email,
    const String.fromEnvironment('SEED_PASSWORD'),
  );
}
