import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/network/api_mode.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/home/data/api_home_repository.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/domain/home_repository.dart';

part 'home_providers.g.dart';

/// The only place that names the implementation: fakes or the API.
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  if (ref.watch(useFakesProvider)) {
    return FakeHomeRepository(personaId: ref.watch(currentPersonaProvider));
  }
  return ApiHomeRepository(
    ref.watch(dioProvider),
    ref.watch(devSessionProvider),
  );
}

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<List<HomeEntry>> build() =>
      ref.watch(homeRepositoryProvider).fetchHome();
}
