import 'package:dio/dio.dart';
import 'package:ronditrack/core/failure/retry_policy.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/features/stokvel/data/stokvel_dto.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

// The API sends a label, the domain wants a number: take the last number in it.
int _cycleNumber(String label) =>
    int.tryParse(
      RegExp(r'\d+').allMatches(label).lastOrNull?.group(0) ?? '',
    ) ??
    0;

Cycle toCycle(CycleDto d) => Cycle(
  id: d.id,
  number: _cycleNumber(d.label),
  status: CycleStatus.parse(d.status),
  // The domain has no "no due date" yet: epoch stands in until it does.
  dueDate: d.dueDate ?? DateTime.utc(1970),
);

Contribution toContribution(HistoryItemDto d) => Contribution(
  id: d.id,
  memberId: d.memberId,
  memberName: d.memberName,
  amount: Cents(d.amountCents),
  status: ContributionStatus.parse(d.status),
);

class ApiStokvelRepository implements StokvelRepository {
  const new(this._dio, this._session);

  final Dio _dio;
  final DevSession _session;

  @override
  Future<StokvelDetail> fetchDetail(String id) => retryRead(() async {
    await _session.ensure();
    final (detailResponse, historyResponse) = await (
      _dio.get<Map<String, dynamic>>('/api/v1/stokvels/$id'),
      _dio.get<Map<String, dynamic>>(
        '/api/v1/stokvels/$id/contribution-history',
      ),
    ).wait;
    final detail = StokvelDetailDto.fromJson(detailResponse.data!);
    final cycle = detail.currentCycle;
    final items = [
      for (final i in historyResponse.data!['items']! as List<dynamic>)
        HistoryItemDto.fromJson(i! as Map<String, dynamic>),
    ].where((i) => cycle != null && i.cycleId == cycle.id).toList();
    final contributions = items.map(toContribution).toList();
    return StokvelDetail(
      stokvel: Stokvel(
        id: detail.id,
        name: detail.name,
        contributionAmount: Cents(detail.contributionCents),
      ),
      role: StokvelRole.parse(detail.role),
      cycle: cycle == null ? null : toCycle(cycle),
      contributions: contributions,
      myContribution: contributions
          .where((c) => c.memberId == _session.userId)
          .firstOrNull
          ?.status,
    );
  });
}