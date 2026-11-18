import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'access_token.g.dart';

/// The access token lives in memory only: never in storage, never in a log.
@Riverpod(keepAlive: true)
class AccessToken extends _$AccessToken {
  @override
  String? build() => null;

  // Reason: a named command method reads better than a setter here.
  // ignore: use_setters_to_change_properties
  void set(String? token) => state = token;
}
