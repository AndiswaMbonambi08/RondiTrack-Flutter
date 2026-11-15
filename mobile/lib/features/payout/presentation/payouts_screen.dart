import 'package:flutter/material.dart';

/// Placeholder until the screen commit: the route is reachable first.
class PayoutsScreen extends StatelessWidget {
  const new({required this.stokvelId, required this.cycleId, super.key});

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: const Center(child: Text('Rotation and payouts')),
    );
  }
}
