import 'package:flutter/material.dart';
import 'package:ronditrack/core/theme/status_colors.dart';

/// A status in words, with an icon and a coloured border. Colour helps, it
/// never says the status alone.
class StatusChip extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.style,
    super.key,
  });

  final String label;
  final IconData icon;
  final StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        border: Border.all(color: style.foreground),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: style.foreground),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: style.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
