import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the refresh token lives between launches. Tests use the in-memory one.
abstract interface class RefreshTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureRefreshTokenStore implements RefreshTokenStore {
  const new([this._storage = const FlutterSecureStorage()]);

  static const _key = 'session.refresh';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class InMemoryRefreshTokenStore implements RefreshTokenStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String token) async => _value = token;

  @override
  Future<void> clear() async => _value = null;
}
