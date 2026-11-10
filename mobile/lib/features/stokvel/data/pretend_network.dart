Future<void> pretendNetwork(int milliseconds, double scale) =>
    Future<void>.delayed(Duration(milliseconds: (milliseconds * scale).round()));