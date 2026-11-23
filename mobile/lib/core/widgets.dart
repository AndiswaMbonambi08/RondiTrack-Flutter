import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ronditrack/core/failure/failure.dart';

class LoadingView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Shows a failure in its own words. A server failure also shows its
/// reference, copyable. "No answer" offers Try again.
class FailureView extends StatelessWidget {
  const new({
    required this.message,
    required this.onRetry,
    this.failure,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final reference = switch (failure) {
      ServerFailure(:final correlationId) => correlationId,
      _ => null,
    };
    final retryLabel = failure is NoAnswerFailure ? 'Try again' : 'Retry';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (reference != null) ...[
            const SizedBox(height: 8),
            SelectableText('Reference: $reference'),
            TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: reference)),
              child: const Text('Copy reference'),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
