# Assignment 11.3 notes: Offline, Forms and Lists

Branch: assignment-11.3. Last pushed commit when these notes were written: 63a2e0e (2026-11-23).

## What is built

### Offline cache (Drift)
- Database: lib/core/database (app_database, cache_meta_table, database_provider). Tables live with their feature: home_tables, stokvel_tables, outbox_tables.
- Home, stokvel detail and the current cycle with its contributions are cached (home_cache, stokvel_cache). Screens draw from the cache at once and a background fetch updates it.
- Sync state (core/sync): CachedValue, SyncTracker and OfflineBanner/NoCacheView. The banner comes from what happened to a request, never from the connection type. It shows how old the data is and offers Try again.
- Opened with no signal, the app opens as the last signed-in person (auth_controller.restore reads savedUserId). The session interceptor now also refreshes when there is no access token.
- Sign-out empties the database (every cached row, the outbox and who was signed in). When the session ends on its own, sessionEnded keeps only the outbox.
- Sign-out asks first when a payment is unsent (profile_screen, OutboxStore.countAll).

### Payment outbox
- A payment is written to the outbox when Pay is tapped. Its Idempotency-Key is made once, at that tap, in OutboxStore.enqueue, and stored with it. Every attempt sends the stored key.
- One pending payment per member and cycle, so a second tap cannot make a second payment.
- Outcomes (payment_outcome.dart): Paid, Refused, Waiting (429, Retry-After), Pending (no answer), Expired, Gone.
- Maximum age 48 hours, shorter than the API's M of 168 hours (Housekeeping:IdempotencyRetentionHours).
- The phone never computes money. A pending payment is shown beside the server totals, marked pending, never added in.
- Pay form: rands parsed to cents with integers, field errors under their field, input kept on failure.

### Languages
- English and isiZulu through ARB files and gen-l10n (l10n.yaml, lib/l10n). The generated classes in lib/l10n/generated are committed.
- Language choice is kept in SharedPreferences (locale_controller), chosen on the Profile screen, survives restart and sign-out, and can follow the phone.
- Localised so far: Home, stokvel detail, cycle, payouts, stokvels list, status chips, pay form, profile, splash, sign-in, the treasurer and member action buttons, failures and ages.
- lib/l10n/labels.dart holds the label functions. The old English stokvel/presentation/labels.dart was deleted.

### Lints and dependencies
- dart analyze --fatal-infos was clean at commit 600fb72 and again at 4c541e8.
- dart fix removed redundant constructor names and added braces. SaDay is now @immutable. payment_service awaits its result.
- Riverpod family providers keep an explicit ignore with a reason, because the type is only in a private riverpod library and an import from lib/src is not allowed.
- tool/check_lock_age.ps1 fails when any hosted package in pubspec.lock is under 14 days old. It found four on 2026-11-23: cli_util 0.6.1, shared_preferences_android 2.5.5, shared_preferences_foundation 2.6.2 and sqlite3 3.9.2.
- dependency_overrides in pubspec.yaml hold those four and four others back, each with a removal date next to it. Remove a line on its date, run pub get, then run the checker. Not yet seen: a passing checker run after the new pubspec. Run it before opening the pull request.

## Decisions
- Keys are made in OutboxStore.enqueue with newUuid() (core/ids/secure_uuid), never in the code that sends.
- Paging is not written yet, so there is no decision on hand paging versus the package.
- Generated code is gitignored and built in CI, except the l10n files.

## Contract (from the API repo)
- API main: 49d043f. The cycleId and status filters on contribution-history, and the machine-readable codes for cycle-closed and cycle-paid-out conflicts, are only on branch feat/offline-contract-gaps (commits 75295b9 and ee86c6a). That branch must be merged or linked from the pull request.
- Page size is 25 and at most 100. The end marker is an empty nextPageToken. from is included and to is excluded, as UTC instants with a zone. A token only works with the filters it came from.
- Known gap: fetchDetail reads contribution-history unpaged and filters by cycle on the phone. It should send the cycle filter to the server once the branch is merged.

## Still to do
- Contributions list: paging with one request in flight, filters (cycle, status, member, South African day range), the six states, pull to refresh keeping old rows. It needs a list-row model with an instant, because Contribution has none. SaDay and SaRange already give the half-open bounds.
- Create-stokvel form: rands to cents, field errors under their fields, input kept on failure.
- Stretch: send the outbox by itself when a request gets through.
- Literal English still to move into the ARB files: the tab labels in app/shell.dart, and Retry, Reference and Copy reference in core/widgets.dart. Check payout/presentation/payout_chips.dart as well.
- CI: TZ=UTC and TZ=Africa/Johannesburg runs on Linux, a build_runner step, and the lock-age check.
- Tests for every layer in Part 8, the live test, and three tests broken on purpose with what was broken written down.
- API repo: pull request with its tests, linked from the app pull request.
- README sections: Contract notes for offline, Offline, Money and dates, Languages, Decisions. The current README has damaged sections (Payouts 10.3, Personas) and was left alone on purpose.
- Pull request evidence from a phone or emulator: airplane mode, the offline payment with restart and the API showing one contribution and one key, a stale edit, the pay form in both languages, the list for one day, TalkBack at 200% text, the live test output and the green CI run.

## Review needed
- The isiZulu strings are drafts, not yet read by a first-language speaker. Least sure of: Qopha inkokhelo (Record payout), Olandelayo (Next), ukuhleleka kwezinkokhelo (payout order), I-imeyili and Iphasiwedi (email and password). The README must name the reviewer and what they changed, or mark the translation as a draft.