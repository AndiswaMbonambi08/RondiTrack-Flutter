import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:ronditrack/core/session/auth_failure.dart';
import 'package:ronditrack/core/session/cookie.dart';

const authLoginPath = '/api/v1/auth/login';
const authRegisterPath = '/api/v1/auth/register';

class SessionGrant {
  const new({
    required this.accessToken,
    required this.expiresInSeconds,
    required this.refreshToken,
  });

  final String accessToken;
  final int expiresInSeconds;
  final String refreshToken;
}

/// The auth calls use Dio directly: the cookie is in a header and a generated
/// client returns only bodies.
class AuthApi {
  const new({required this.bare, required this.cookieName});

  final Dio bare;
  final String cookieName;

  Future<SessionGrant> login({
    required String email,
    required String password,
  }) async {
    final response = await _send(authLoginPath, {
      'email': email.trim(),
      'password': password,
    });
    if (response.statusCode == 200) return _grant(response);
    throw _failure(response);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _send(authRegisterPath, {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    });
    if (response.statusCode == 201 || response.statusCode == 200) return;
    throw _failure(response);
  }

  Future<Response<dynamic>> _send(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      return await bare.post<dynamic>(
        path,
        data: body,
        options: Options(validateStatus: (_) => true),
      );
    } on DioException {
      throw const NetworkDown();
    }
  }

  SessionGrant _grant(Response<dynamic> response) {
    final data = response.data;
    final token = data is Map ? data['accessToken'] : null;
    final seconds = data is Map ? data['expiresInSeconds'] : null;
    if (token is! String || seconds is! int) throw const ServerFailure();
    final String refresh;
    try {
      refresh = readSetCookie(response.headers['set-cookie'], cookieName);
    } on MissingCookieError {
      throw const ServerFailure();
    }
    return SessionGrant(
      accessToken: token,
      expiresInSeconds: seconds,
      refreshToken: refresh,
    );
  }

  AuthFailure _failure(Response<dynamic> response) {
    switch (response.statusCode ?? 0) {
      case 401:
        return const WrongCredentials();
      case 409:
        return const EmailTaken();
      case 429:
        final seconds =
            int.tryParse(response.headers.value('retry-after') ?? '') ?? 60;
        return RateLimited(
          Duration(seconds: math.max(1, math.min(seconds, 3600))),
        );
      case 400:
        return FieldErrors(_fieldErrors(response.data));
      default:
        return const ServerFailure();
    }
  }

  static Map<String, String> _fieldErrors(Object? data) {
    final out = <String, String>{};
    if (data is! Map) return out;
    final errors = data['errors'];
    if (errors is Map) {
      for (final entry in errors.entries) {
        final value = entry.value;
        final text = value is List && value.isNotEmpty
            ? '${value.first}'
            : '$value';
        out[entry.key.toString().toLowerCase()] = text;
      }
    } else if (errors is List) {
      for (final item in errors) {
        if (item is Map) {
          final field =
              item['field'] ?? item['property'] ?? item['propertyName'];
          final message =
              item['message'] ?? item['error'] ?? item['errorMessage'];
          if (field != null && message != null) {
            out['$field'.toLowerCase()] = '$message';
          }
        }
      }
    }
    if (out.isEmpty && data['detail'] is String)
      out['form'] = data['detail'] as String;
    return out;
  }
}
