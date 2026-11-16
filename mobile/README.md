| 1 | Which endpoint returns a cycle's payout order, and what does each entry hold? | `GET /api/v1/stokvels/{stokvelId}/cycles/{cycleId}/payouts/payout-order` returns `{ stokvelId, cycleId, items[] }`. Each item holds `memberId`, `memberName`, `position` (1-based), `amountCents` (the pot), `payoutDate` (`yyyy-MM-dd` in Johannesburg, or `null` until paid) and `status`. `PayoutEntry` copies this with `Cents`, a `DateTime?` and `PayoutStatus`. |

## Personas

Names follow the API's demo seed. Sipho plays the brief's "Lerato" (Treasurer of one stokvel, Member of another). Mpho plays the brief's "Sipho" (Member only). Platform admin is in no stokvels. Nomsa is Admin of Umoja, and Broken (dev) fails on purpose.

| Person | Home | Ubuntu Savings Circle | Umoja Family Fund | Payouts view |
Read from the API repo `AndiswaMbonambi08/RondiTrack` at commit `67a82a01f540f97ed481d0d01d1d6c201e0b7e6c`: its README and the generated types in `web/src/api/schema.d.ts`.
Contract copy: `contract/schema.d.ts` is the openapi-typescript output of the API's live OpenAPI document (`web/src/api/schema.d.ts`) at that commit. The committed `clients/typescript/openapi.json` export at that commit predates `arrearsCents`, so it is not the current contract; refreshing it is a backend follow-up.

1. **Spellings (case matters).** Contribution status is a real enum: `Pending`, `Paid`, `Confirmed`. Cycle status is a plain string, documented as `Open`, `Closed` (set by the cycle-close job) or `PaidOut`. Role is a plain string: `Member`, `Treasurer`, `Admin`. Any other string becomes `unknown`.
2. **Role.** `GET /api/v1/me/home` returns it per stokvel as `stokvels[].role`. It is never on the user or in the token (the token carries only `sub`, `jti` and, for platform admins, a `PlatformAdmin` role claim). The stokvel detail fake returns it on the stokvel the same way. Admin satisfies every Treasurer check.
3. **/me/home.** Per stokvel: `stokvelId`, `name`, `role`, `currentCycle` (`{id, label, status, dueDate}` or `null`), `paidCents`, `owedCents`, `arrearsCents` (int64 cents, never null) and `nextPayoutUtc` (date-time or `null`). The app shows them and never computes them. A user in no stokvels gets `200` with an empty list.
4. **Due dates.** `currentCycle.dueDate` is date-only (`2026-10-31`, nullable), modelled as a UTC-midnight `DateTime`. `nextPayoutUtc` is an instant (the last moment of the month in Johannesburg, `21:59:59Z`). Both are shown as a date in South African time (UTC+2, no daylight saving).
5. **Seed personas.** Sipho: Member of Ubuntu Savings Circle and Treasurer of Umoja Family Fund (one login, two roles). Nomsa: Admin of Umoja Family Fund. The platform admin (`admin@example.com`) stays out of stokvel membership, so it is the empty-Home persona. The fakes hold the same people and stokvels; contributors and amounts inside them are made-up fake data.

Backend gaps found: `role` and cycle `status` were published as plain `string` in the OpenAPI document, so the contract did not list their spellings. Fixed in the API repo with a contract test: https://github.com/AndiswaMbonambi08/RondiTrack/pull/20. The app still maps any unexpected string to `unknown`.

## Running it

- API repo: `AndiswaMbonambi08/RondiTrack`. Nothing calls it yet: the app runs on fake repositories with the seed personas, so no API needs to be started this week. In Week 11 the dev flavour points at it (start it with `docker compose up` or `dotnet run` as its README says).
- Flutter 3.47.7. First Gradle build can take over ten minutes.
- `flutter run --flavor dev --dart-define-from-file=config/dev.json`
- `flutter run --flavor staging --dart-define-from-file=config/staging.json`
- `flutter run --flavor prod --dart-define-from-file=config/prod.json`
- Each `config/<flavor>.json` holds `FLAVOR` and `API_BASE_URL` only, nothing secret. The app refuses to start without a config, and refuses a build whose native flavour differs from the config's `FLAVOR` (unit-tested).
- Flavours: dev (`.dev`, "RondiTrack Dev"), staging (`.staging`, "RondiTrack Staging"), prod (no suffix, "RondiTrack"). The launcher name is set with a manifest placeholder, not `resValue`.
- Lint rule `public_member_api_docs` is switched off on purpose: this is an app, not a package, so doc comments on every public member add noise.

## Generated code

**Ignored in Git, generated in CI.** Reason: generated files make noisy diffs and merge conflicts and can go stale; CI always builds them from source. CI order works with this: `pub get`, format check (before generation, so generated files are never formatted-checked), `build_runner build`, `dart analyze --fatal-infos`, `flutter test`.

## Money

- `Cents` extension type over `int`; no `double` anywhere near money.
- Formatter: en-ZA, no-break spaces, integer arithmetic: `R 0,10`, `R 150,50`, `R 1 500,00`, `R 1 000 000,00`, negative as `-R 150,00`.
- Parser accepts `150`, `150,50`, `R150`, `R 1 500`, `1 500,50` (space or no-break space). Refuses `1,500.50`, `150,505`, `150.`, empty and letters.
- **Full-stop decision:** a single full stop IS accepted as a decimal separator (`150.50` = R150,50) because many phone keyboards have no comma. It is only accepted with 1-2 digits after it and never together with a comma.

## When the API adds a status

I added `archived('Archived')` to `CycleStatus` and ran `dart analyze`. It reported:

```
Analyzing mobile...

  error - lib\features\stokvel\domain\actions.dart:21:25 - The type '(CycleStatus, ContributionStatus?)' isn't exhaustively matched by the switch cases since it doesn't match the pattern '(CycleStatus.archived, _)'. Try adding a wildcard pattern or cases that match '(CycleStatus.archived, _)'. - non_exhaustive_switch_expression
  error - lib\features\stokvel\domain\actions.dart:42:28 - The type '(StokvelRole, CycleStatus)' isn't exhaustively matched by the switch cases since it doesn't match the pattern '(StokvelRole.member, CycleStatus.archived)'. Try adding a wildcard pattern or cases that match '(StokvelRole.member, CycleStatus.archived)'. - non_exhaustive_switch_expression
  error - lib\features\stokvel\presentation\labels.dart:4:42 - The type 'CycleStatus' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'CycleStatus.archived'. Try adding a wildcard pattern or cases that match 'CycleStatus.archived'. - non_exhaustive_switch_expression

3 issues found.
```

At run time on a phone with an old install, the new string `Archived` is not in the old app's enum, so `CycleStatus.parse` returns `unknown`. Nothing throws; the screen shows "Status unavailable" and no actions are offered for that cycle until the app is updated.

## Provider lifetimes

| Provider | Holds | Lifetime | Cost of keeping (entry-level phone) | Cost of disposing |
|---|---|---|---|---|
| Sipho | Two cards: Ubuntu (Member), Umoja (Treasurer) | Member: Pay, no treasurer action | Treasurer: Confirm contributions, Close cycle | Ubuntu: no Record payout. Umoja: Record payout while someone is Next |
| Nomsa | One card: Umoja (Admin) | Not found | Admin: the same actions as a Treasurer | Umoja: Record payout. Ubuntu: not found |
| Mpho | One card: Ubuntu (Member) | Member: Upload proof, no treasurer action | Not found | Ubuntu: no Record payout. Umoja: not found |
| Platform admin | "You are not in any stokvels yet." and what to do next | Not found | Not found | Not found |

**How to switch (dev build only):** tap the person icon at the top right of any screen and pick someone. It signs out and signs in as them through the fake auth state, so the gate and every provider react as to a real sign-in, and you come back to the same address. Staging and prod build no switcher: no widget, no route, no address. `test/personas/dev_switcher_test.dart` builds both and proves it.

## Architecture rules

`test/architecture/architecture_test.dart` fails CI when:

- a file under `lib/features` types a colour (`Colors.`, `Color(`, `Color.from...`): ask the theme;
- a screen (a file in a `presentation/` folder, or under `lib/app`) imports a `data/` folder, Dio or Drift: go through a provider.

Every exception is a record in the test with the file, the reason and the week it ends; an exception with no reason, a missing file or a passed end week fails the test.

| File | Rule | Reason | Ends |
|---|---|---|---|
| none | | There are no exceptions today. | |
