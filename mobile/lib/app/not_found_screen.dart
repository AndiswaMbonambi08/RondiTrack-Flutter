import 'package:flutter/material.dart';
import 'package:ronditrack/app/routes.dart';

class NotFoundScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RondiTrack')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => const HomeRoute().go(context),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
