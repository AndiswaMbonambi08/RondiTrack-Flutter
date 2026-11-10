import 'package:flutter/material.dart';
import 'package:ronditrack/app/app.dart';
import 'package:ronditrack/app/config.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(RondiTrackApp(config: config));
}