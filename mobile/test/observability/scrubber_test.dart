import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/observability/scrubber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  const name = 'Thandi Nkosi';
  const email = 'thandi@example.co.za';
  const amount = 'R\u00A01\u00A0250,50';
  const token = 'Bearer eyJhbGciOi.eyJzdWIiOi.c2lnbmF0dXJl';
  const proof = 'Thandi_proof_Nov.jpg';
  const all = [
    name,
    email,
    amount,
    'eyJhbGciOi.eyJzdWIiOi.c2lnbmF0dXJl',
    proof,
  ];

  SentryEvent realistic() => SentryEvent(
    message: SentryMessage('$name paid $amount ($email) $proof'),
    exceptions: [
      SentryException(
        type: 'ApiError',
        value: '$name $email $amount $token $proof',
      ),
    ],
    breadcrumbs: [
      Breadcrumb(
        message: 'GET /stokvels?q=Nkosi $name $amount',
        data: {'url': '/members?email=$email', 'file': proof, 'amount': 1250.5},
      ),
    ],
    tags: {'note': '$name $amount', 'correlation_id': 'abc-123-corr'},
    user: SentryUser(id: '7', email: email, username: name),
    request: SentryRequest(
      url: 'https://api.example/pay?token=secret&q=$name',
      queryString: 'token=secret&q=$name',
      headers: {'Authorization': token},
      data: '{"amount": "$amount", "name": "$name"}',
    ),
  );

  test('no personal value survives anywhere, correlation id does', () {
    final scrubber = Scrubber(memberName: name, memberEmail: email);
    final out = scrubber.scrubEvent(realistic(), Hint())!;
    final dump = out.toJson().toString().toLowerCase();

    for (final secret in all) {
      expect(
        dump.contains(secret.toLowerCase()),
        isFalse,
        reason: 'LEAKED: $secret',
      );
    }
    expect(dump.contains('q=nkosi'), isFalse, reason: 'LEAKED: query string');
    expect(dump.contains('secret'), isFalse, reason: 'LEAKED: url token');
    expect(out.tags!['correlation_id'], 'abc-123-corr');
  });
}
