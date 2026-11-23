import 'package:dio/dio.dart';
import 'package:ronditrack/features/join/domain/join_outcome.dart';

class JoinApi {
  const new(this._dio);

  final Dio _dio;

  /// Never throws: every answer from the API becomes an outcome.
  Future<JoinOutcome> join(String code) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/invites/${Uri.encodeComponent(code)}/join',
      );
      final id = response.data?['stokvelId'];
      return id is String ? Joined(id) : const JoinFailed();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 410) return const InvalidInvite();
      if (status == 409) {
        final data = e.response?.data;
        final id = data is Map ? data['stokvelId'] : null;
        return AlreadyMember(id is String ? id : null);
      }
      return const JoinFailed();
    }
  }
}
