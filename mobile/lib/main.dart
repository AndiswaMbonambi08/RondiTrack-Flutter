import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/app.dart';
import 'package:ronditrack/app/config.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(ProviderScope(child: RondiTrackApp(config: config)));
}