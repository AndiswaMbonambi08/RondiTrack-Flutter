import 'package:dio/dio.dart';
import 'package:ronditrack/core/failure/retry_policy.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/features/home/data/home_dto.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/domain/home_repository.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

HomeEntry toHomeEntry(HomeStokvelDto d) => HomeEntry(
  stokvelId: d.stokvelId,
  name: d.name,
  role: StokvelRole.parse(d.role),
  paid: Cents(d.paidCents),
  owed: Cents(d.owedCents),
  arrears: Cents(d.arrearsCents),
  nextPayout: d.nextPayoutUtc,
);

/// Throws a Failure (see core/failure) for anything that goes wrong.
class ApiHomeRepository implements HomeRepository {
  const new(this._dio, this._session);

  final Dio _dio;
  final DevSession _session;

  @override
  Future<List<HomeEntry>> fetchHome() => retryRead(() async {
    await _session.ensure();
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/me/home');
    return HomeDto.fromJson(response.data!).stokvels.map(toHomeEntry).toList();
  });
}