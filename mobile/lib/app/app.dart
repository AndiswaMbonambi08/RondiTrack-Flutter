import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/config.dart';
import 'package:ronditrack/app/router.dart';

class RondiTrackApp extends ConsumerWidget {
  const new({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: config.flavor == Flavor.prod
          ? 'RondiTrack'
          : 'RondiTrack ${config.flavor.name}',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
