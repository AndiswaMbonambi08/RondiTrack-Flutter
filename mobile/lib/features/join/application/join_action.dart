import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/join/data/join_api.dart';
import 'package:ronditrack/features/join/domain/join_outcome.dart';

final joinApiProvider = Provider<JoinApi>(
  (ref) => JoinApi(ref.watch(dioProvider)),
);

/// One join per code while the join screen is open. It returns an outcome
/// instead of throwing, so Riverpod's automatic retry can never send it twice.
// Reason: the family's type is in a private riverpod library, so it cannot be
// written here without importing from lib/src.
// ignore: specify_nonobvious_property_types
final joinProvider = FutureProvider.autoDispose.family<JoinOutcome, String>((
  ref,
  code,
) {
  ref.watch(sessionScopeProvider);
  return ref.watch(joinApiProvider).join(code);
});
