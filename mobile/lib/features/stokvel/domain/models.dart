import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

part 'models.freezed.dart';

/// The role belongs to the membership. There is no User.role.
@freezed
abstract class Membership with _$Membership {
  const factory({required String stokvelId, required StokvelRole role}) =
      _Membership;
}

@freezed
abstract class Stokvel with _$Stokvel {
  const factory({
    required String id,
    required String name,
    required Cents contributionAmount,
  }) = _Stokvel;
}

@freezed
abstract class Cycle with _$Cycle {
  const factory({
    required String id,
    required int number,
    required CycleStatus status,
    // Date-only (UTC midnight), not an instant.
    required DateTime dueDate,
  }) = _Cycle;
}

@freezed
abstract class Contribution with _$Contribution {
  const factory({
    required String id,
    required String memberId,
    required String memberName,
    required Cents amount,
    required ContributionStatus status,
  }) = _Contribution;
}

@freezed
abstract class StokvelDetail with _$StokvelDetail {
  const factory({
    required Stokvel stokvel,
    required StokvelRole role,
    required Cycle? cycle,
    required List<Contribution> contributions,
    required ContributionStatus? myContribution,
  }) = _StokvelDetail;
}
