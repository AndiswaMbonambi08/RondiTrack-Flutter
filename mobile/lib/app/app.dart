import 'package:flutter/material.dart';
import 'package:ronditrack/app/config.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';

class RondiTrackApp extends StatelessWidget {
  const new({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.flavor == Flavor.prod
          ? 'RondiTrack'
          : 'RondiTrack ${config.flavor.name}',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(),
    );
  }
}
