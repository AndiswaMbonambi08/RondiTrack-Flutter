import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

/// CI goldens (text as blocks) run everywhere.
/// Platform goldens (real text) run on Windows only.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: Platform.isWindows),
      ciGoldensConfig: const CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
