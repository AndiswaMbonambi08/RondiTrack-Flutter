import 'package:flutter/material.dart';
import 'package:ronditrack/core/layout/breakpoints.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvels_screen.dart';

/// One address, two layouts. At 840 dp or wider the list sits beside the
/// selected stokvel; narrower, the stokvel fills the screen over the list.
class StokvelRouteBody extends StatelessWidget {
  const new({required this.stokvelId, super.key});

  final String stokvelId;

  @override
  Widget build(BuildContext context) {
    return switch (windowSizeOf(context)) {
      WindowSize.expanded => StokvelsScreen(selectedId: stokvelId),
      WindowSize.compact ||
      WindowSize.medium => StokvelDetailScreen(stokvelId: stokvelId),
    };
  }
}
