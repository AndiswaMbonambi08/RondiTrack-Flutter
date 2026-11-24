import 'package:sentry_flutter/sentry_flutter.dart';

/// Removes anything personal from an event before it leaves the phone.
/// The correlation id tag is kept on purpose.
class Scrubber {
  Scrubber({this.memberName, this.memberEmail});

  /// A name cannot be found by a pattern, so it is passed in.
  final String? memberName;
  final String? memberEmail;

  static const redacted = '[redacted]';
  static const correlationTag = 'correlation_id';

  static final _patterns = <RegExp>[
    // Amounts, e.g. R 1 250,50 (en_ZA uses a no-break space).
    RegExp(r'R[\s\u00A0]*\d(?:[\d\s\u00A0]*\d)?(?:[,.]\d{1,2})?'),
    RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+'),
    RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
    RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+'),
    RegExp(r'\S*proof\S*\.(?:jpe?g|png|heic|webp|pdf)', caseSensitive: false),
    // Query strings, in URLs and in free text.
    RegExp(r'\?\S+'),
  ];

  String scrubText(String input) {
    var out = input;
    for (final name in [memberName, memberEmail]) {
      if (name != null && name.trim().isNotEmpty) {
        out = out.replaceAll(
          RegExp(RegExp.escape(name), caseSensitive: false),
          redacted,
        );
      }
    }
    for (final p in _patterns) {
      out = out.replaceAll(
        p,
        p.pattern.startsWith(r'\?') ? '?$redacted' : redacted,
      );
    }
    return out;
  }

  String? _s(String? v) => v == null ? null : scrubText(v);

  Map<String, dynamic>? _data(Map<String, dynamic>? m) =>
      m?.map((k, v) => MapEntry(k, v is String ? scrubText(v) : redacted));

  SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
    final msg = event.message;
    if (msg != null) {
      event.message = SentryMessage(
        scrubText(msg.formatted),
        template: _s(msg.template),
        params: msg.params
            ?.map((e) => e is String ? scrubText(e) : redacted)
            .toList(),
      );
    }

    for (final e in event.exceptions ?? const <SentryException>[]) {
      e.value = _s(e.value);
    }

    for (final b in event.breadcrumbs ?? const <Breadcrumb>[]) {
      b.message = _s(b.message);
      b.data = _data(b.data);
    }

    final tags = event.tags;
    if (tags != null) {
      event.tags = tags.map(
        (k, v) => MapEntry(k, k == correlationTag ? v : scrubText(v)),
      );
    }

    final user = event.user;
    if (user != null) {
      event.user = SentryUser(id: user.id);
    }

    final req = event.request;
    if (req != null) {
      event.request = SentryRequest(
        url: _s(req.url),
        method: req.method,
        queryString: req.queryString == null ? null : redacted,
        headers: req.headers.isEmpty ? null : {'redacted': redacted},
        data: req.data == null ? null : redacted,
      );
    }

    return event;
  }
}
