import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/core/layout/breakpoints.dart';
import 'package:ronditrack/features/home/presentation/persona_menu.dart';

const List<({IconData icon, String label, IconData selectedIcon})> _tabs = [
  (label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  (label: 'Stokvels', icon: Icons.groups_outlined, selectedIcon: Icons.groups),
  (
    label: 'Activity',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
  ),
  (label: 'Profile', icon: Icons.person_outline, selectedIcon: Icons.person),
];

/// The same four branches everywhere: a bottom bar on compact windows, a side
/// rail on wider ones, each destination with its label. In the dev flavour a
/// persona switcher sits over every screen; in staging and prod it is not
/// built at all.
class AppShell extends ConsumerWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  // Tapping the tab you are on returns to that tab's first screen.
  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shell = switch (windowSizeOf(context)) {
      WindowSize.compact => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      ),
      WindowSize.medium || WindowSize.expanded => Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.selectedIcon),
                    label: Text(t.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    };
    if (!ref.watch(appConfigProvider).devToolsEnabled) return shell;
    return Stack(
      fit: StackFit.expand,
      children: [
        shell,
        const PositionedDirectional(
          top: 0,
          end: 0,
          child: SafeArea(
            child: Material(
              type: MaterialType.transparency,
              child: PersonaMenu(),
            ),
          ),
        ),
      ],
    );
  }
}
