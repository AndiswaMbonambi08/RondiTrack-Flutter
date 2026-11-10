import 'package:flutter/material.dart';
import 'package:ronditrack/app/config.dart';

class RondiTrackApp extends StatelessWidget {
  const RondiTrackApp({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RondiTrack',
      home: Scaffold(body: Center(child: Text(config.flavor.name))),
    );
  }
}