import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/domain/home_repository.dart';

part 'home_providers.g.dart';

/// The only line Week 11 changes: names the implementation.
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) =>
    FakeHomeRepository(personaId: ref.watch(currentPersonaProvider));

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<HomeEntry>> build() =>
      ref.watch(homeRepositoryProvider).fetchHome();
}
