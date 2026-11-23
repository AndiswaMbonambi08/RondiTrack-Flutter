import 'package:flutter/material.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

/// Cached data stays on screen under this. It says what happened (offline or
/// could not refresh), how old the data is, and offers Try again.
class OfflineBanner extends StatelessWidget {
  const new({
    required this.failure,
    required this.fetchedAt,
    required this.onRetry,
    super.key,
  });

  final Failure failure;
  final DateTime? fetchedAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final at = fetchedAt;
    final headline = failure is NoAnswerFailure
        ? l.bannerOffline
        : l.bannerRefreshFailed;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: scheme.secondaryContainer,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: scheme.onSecondaryContainer),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const ExcludeSemantics(child: Icon(Icons.cloud_off)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (at != null)
                        Text(
                          l.bannerUpdated(
                            ageText(l, DateTime.now().toUtc().difference(at)),
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(onPressed: onRetry, child: Text(l.tryAgain)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nothing cached and the first fetch failed.
class NoCacheView extends StatelessWidget {
  const new({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(child: Icon(Icons.cloud_off, size: 48)),
            const SizedBox(height: 12),
            Text(failureText(l, failure), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l.tryAgain)),
          ],
        ),
      ),
    );
  }
}