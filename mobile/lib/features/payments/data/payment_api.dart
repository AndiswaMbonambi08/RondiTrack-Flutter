import 'package:dio/dio.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/failure_mapper.dart';
import 'package:ronditrack/core/money/cents.dart';

class PaymentApi {
  const new(this._dio);

  final Dio _dio;

  /// Null when the API accepted the payment (201, or the stored answer to a
  /// repeat of the same key), otherwise the Failure. Never throws.
  Future<Failure?> send({
    required String stokvelId,
    required String cycleId,
    required String userId,
    required Cents amount,
    required String idempotencyKey,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/stokvels/$stokvelId/contributions',
        data: {
          'userId': userId,
          'contributionCycleId': cycleId,
          'amountInCents': amount.value,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return null;
    } on Object catch (error) {
      return toFailure(error);
    }
  }
}
