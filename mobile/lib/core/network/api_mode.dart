import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_mode.g.dart';

/// The one switch. True selects the fakes, false the API. Tests keep their
/// own overrides, so the Week 10 suite still runs on fakes.
@Riverpod(keepAlive: true)
bool useFakes(Ref ref) => !const bool.fromEnvironment('USE_API');
