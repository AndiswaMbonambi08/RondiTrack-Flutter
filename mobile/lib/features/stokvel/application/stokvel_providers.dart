import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

part 'stokvel_providers.g.dart';

/// The only line Week 11 changes: names the implementation.
@Riverpod(keepAlive: true)
StokvelRepository stokvelRepository(Ref ref) =>
    FakeStokvelRepository(personaId: ref.watch(currentPersonaProvider));

/// One instance per stokvel id: two ids never share state.
@riverpod
Future<StokvelDetail> stokvelDetail(Ref ref, String id) {
  // Log the id only: never a name or an amount.
  ref.onDispose(() => debugPrint('stokvelDetail disposed id=$id'));
  return ref.watch(stokvelRepositoryProvider).fetchDetail(id);
}