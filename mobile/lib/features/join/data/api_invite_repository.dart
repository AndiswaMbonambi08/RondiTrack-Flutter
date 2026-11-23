import 'package:dio/dio.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/retry_policy.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/features/join/data/invite_dto.dart';
import 'package:ronditrack/features/join/domain/invite.dart';
import 'package:ronditrack/features/join/domain/invite_repository.dart';

Invite toInvite(String code, InvitePreviewDto d) => Invite(
  code: code,
  stokvelId: d.stokvelId ?? '',
  stokvelName: d.stokvelName,
  contribution: Cents(d.contributionCents),
  alreadyMember: d.alreadyMember,
);

class ApiInviteRepository implements InviteRepository {
  const new(this._dio, this._session);

  final Dio _dio;
  final DevSession _session;

  @override
  Future<Invite?> preview(String code) async {
    try {
      return await retryRead(() async {
        await _session.ensure();
        final response = await _dio.get<Map<String, dynamic>>(
          '/api/v1/invites/${Uri.encodeComponent(code)}',
        );
        return toInvite(code, InvitePreviewDto.fromJson(response.data!));
      });
    } on NotFoundFailure {
      return null;
    }
  }
}
