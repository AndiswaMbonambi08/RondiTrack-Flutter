import 'package:flutter/widgets.dart';

/// Window width classes. Written once; nothing asks "is this a tablet?".
enum WindowSize { compact, medium, expanded }

const mediumMinWidth = 600.0;
const expandedMinWidth = 840.0;

WindowSize windowSizeForWidth(double width) => switch (width) {
  >= expandedMinWidth => WindowSize.expanded,
  >= mediumMinWidth => WindowSize.medium,
  _ => WindowSize.compact,
};

/// From the window, so a split screen or a rotated tablet is classed by the
/// space it really has.
WindowSize windowSizeOf(BuildContext context) =>
    windowSizeForWidth(MediaQuery.sizeOf(context).width);
