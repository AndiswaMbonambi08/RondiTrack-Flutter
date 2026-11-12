# RondiTrack Mobile

Flutter app (Android and iOS) for RondiTrack. Lives beside the API, three flavours, strict lints.

## Contract notes

Read from the API repo `AndiswaMbonambi08/RondiTrack` at commit `67a82a01f540f97ed481d0d01d1d6c201e0b7e6c`: its README and the generated types in `web/src/api/schema.d.ts`.
Contract copy: `contract/schema.d.ts` is the openapi-typescript output of the API's live OpenAPI document (`web/src/api/schema.d.ts`) at that commit. The committed `clients/typescript/openapi.json` export at that commit predates `arrearsCents`, so it is not the current contract; refreshing it is a backend follow-up.

1. **Spellings (case matters).** Contribution status is a real enum: `Pending`, `Paid`, `Confirmed`. Cycle status is a plain string, documented as `Open`, `Closed` (set by the cycle-close job) or `PaidOut`. Role is a plain string: `Member`, `Treasurer`, `Admin`. Any other string becomes `unknown`.
2. **Role.** `GET /api/v1/me/home` returns it per stokvel as `stokvels[].role`. It is never on the user or in the token (the token carries only `sub`, `jti` and, for platform admins, a `PlatformAdmin` role claim). The stokvel detail fake returns it on the stokvel the same way. Admin satisfies every Treasurer check.
3. **/me/home.** Per stokvel: `stokvelId`, `name`, `role`, `currentCycle` (`{id, label, status, dueDate}` or `null`), `paidCents`, `owedCents`, `arrearsCents` (int64 cents, never null) and `nextPayoutUtc` (date-time or `null`). The app shows them and never computes them. A user in no stokvels gets `200` with an empty list.
4. **Due dates.** `currentCycle.dueDate` is date-only (`2026-10-31`, nullable), modelled as a UTC-midnight `DateTime`. `nextPayoutUtc` is an instant (the last moment of the month in Johannesburg, `21:59:59Z`). Both are shown as a date in South African time (UTC+2, no daylight saving).
5. **Seed personas.** Sipho: Member of Ubuntu Savings Circle and Treasurer of Umoja Family Fund (one login, two roles). Nomsa: Admin of Umoja Family Fund. The platform admin (`admin@example.com`) stays out of stokvel membership, so it is the empty-Home persona. The fakes hold the same people and stokvels; contributors and amounts inside them are made-up fake data.

Backend gaps found: `role` and cycle `status` are published as plain `string` in the OpenAPI document, not as enums, so the contract does not list their spellings (only a description does). Recorded as a gap, not fixed this week: the app maps any unexpected string to `unknown`.

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
| `currentPersona` | Who is signed in (an id) | keepAlive | Tiny; must be cleared on sign-out | Would lose the session on every rebuild |
| `homeRepository` | Repository object, no data | keepAlive | Negligible memory | Recreated cheaply, but it rebuilds when the persona changes anyway |
| `stokvelRepository` | Repository object, no data | keepAlive | Negligible memory | Same as above |
| `homeController` | One card per stokvel | autoDispose | Small, but goes stale | A refetch and spinner when Home is reopened from nothing |
| `stokvelDetail(id)` | Stokvel, cycle, contributions for one id | autoDispose (family) | Grows per visited stokvel, holds paid data on a shared phone, goes stale | A refetch and spinner (about 3 s on Umoja Family Fund) |

Disposal proof: `test/stokvel/stokvel_detail_provider_test.dart` shows the id's state no longer exists once nothing listens; the provider also logs `stokvelDetail disposed id=<id>` (id only, never a name or an amount).

**Sign-out.** Sign-out will rebuild the root `ProviderScope` with a new key, which disposes every provider including the kept-alive ones (session, repositories, any cached data), so nothing survives into the next person's session on a shared phone. Sign-out will also clear the stored token first and invalidate `currentPersona` so a failed scope rebuild cannot leave an identity behind.

## CI catches a lint

To prove CI catches what only `riverpod_lint` reports, pull request #3 (`ci-demo-lint`) adds a public field on a notifier. The rule is `avoid_public_notifier_properties`.

- Red run: https://github.com/AndiswaMbonambi08/RondiTrack-Flutter/actions/runs/42940795867 (fails on the Analyze step, Test is skipped)
- Green run after the fix: https://github.com/AndiswaMbonambi08/RondiTrack-Flutter/actions/runs/42941090417
- Pull request: https://github.com/AndiswaMbonambi08/RondiTrack-Flutter/pull/3

`flutter analyze` alone would have let it through. It does not load analyser plugins, so `riverpod_lint` never runs under it. Only `dart analyze` loads the plugin, which is why CI runs `dart analyze --fatal-infos`.

## Routes

Every screen has an address. A signed-out visit to any address goes to sign-in and then comes back to it. Typed routes (`go_router_builder`) are the only way widgets navigate: there is no string path and no `Navigator.push`.

| Address | Screen and tab | Signed out | Not a member | Back goes to |
| --- | --- | --- | --- | --- |
| `/` | Home, Home tab | Sign-in, then `/` | Only your own stokvels are listed | Leaves the app |
| `/stokvels` | Stokvel list, Stokvels tab | Sign-in, then `/stokvels` | Only your own stokvels are listed | Leaves the app |
| `/stokvels/:id` | Stokvel detail, Stokvels tab. At 840 dp or wider it is the list and the detail side by side | Sign-in, then this address | "Stokvel not found", the same screen as for a stokvel that does not exist | `/stokvels` (the detail sits on the list, also from a cold start) |
| `/stokvels/:id/cycles/:cycleId` | Cycle, Stokvels tab | Sign-in, then this address | "Stokvel not found". A cycle id from a different stokvel: "Cycle not found" | `/stokvels/:id`, then `/stokvels` |
| `/activity` | Activity tab | Sign-in, then `/activity` | Only your own stokvels' contributions are listed | Leaves the app |
| `/profile` | Profile tab, with sign out | Sign-in, then `/profile` | Not applicable | Leaves the app |
| `/join/:code` | Invitation preview, on top of Home | Sign-in, then this address | Unknown code: "Invitation not found" | `/` (Home) |
| `/sign-in` (`?from=`) | Sign-in, no tabs | Stays | Not applicable | Leaves the app. Signed in: goes to `from` when it is inside the app, else `/` |
| anything else | "Page not found" with a Go to Home button | Sign-in, nothing remembered | Not applicable | Home |

**Tapping the tab you are on** returns to that tab's first screen (`goBranch(initialLocation: true)`). Tapping a different tab keeps that tab's stack and scroll position. Both are tested.

## The gate

One pure function, `redirectFor(signedIn, location)` in `lib/app/redirect.dart`, decides every navigation. It needs no widget, so `test/app/redirect_test.dart` tests it directly.

- **Signed out:** every address except `/sign-in` goes to `/sign-in`. If the address is inside the app and is not Home, it travels along as `?from=<address>`.
- **Signed in, on `/sign-in`:** go to `from` if it is an address inside the app, otherwise Home.
- **Signed in, anywhere else:** nothing changes.
- **What is remembered:** only an address that starts with a single `/`, has no scheme or host, and begins with a known root (`stokvels`, `activity`, `profile`, `join`). `https://...`, `//host`, `javascript:` and unknown paths land on Home.
- **When it runs:** the router listens to a notifier that bumps whenever the auth provider changes (`refreshListenable`), so signing out redirects immediately, not on the next tap. After sign-out the signed-in screens are gone from the stack, so back cannot return to them.
- **Week 11:** the fake `Auth` provider is replaced by the API. The gate only reads "signed in or not", so it does not change.

## Deep links

**Choice: a custom scheme**, `ronditrack://<applicationId>/<path>`. The host is the flavour's own application id, filled in by Gradle (`${applicationId}`) in the manifest's intent filter, so a link aimed at the dev build can only be claimed by the dev build. Flutter hands the router the path and query, so `/stokvels/:id`, `/stokvels/:id/cycles/:cycleId` and `/join/:code` open the same screens as in the app, while it is running and from a cold start. Signed out, the link goes to sign-in and then on to the address.

**dev** (application id `za.co.andiswa.ronditrack.dev`)

```powershell
# cold start: force-stop first, then open each link
adb shell am force-stop za.co.andiswa.ronditrack.dev
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.dev/stokvels/umoja-family-fund" za.co.andiswa.ronditrack.dev
adb shell am force-stop za.co.andiswa.ronditrack.dev
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.dev/stokvels/umoja-family-fund/cycles/cycle-umoja-5" za.co.andiswa.ronditrack.dev
adb shell am force-stop za.co.andiswa.ronditrack.dev
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.dev/join/ubuntu2026" za.co.andiswa.ronditrack.dev
```

**staging** (application id `za.co.andiswa.ronditrack.staging`)

```powershell
# cold start: force-stop first, then open each link
adb shell am force-stop za.co.andiswa.ronditrack.staging
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.staging/stokvels/umoja-family-fund" za.co.andiswa.ronditrack.staging
adb shell am force-stop za.co.andiswa.ronditrack.staging
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.staging/stokvels/umoja-family-fund/cycles/cycle-umoja-5" za.co.andiswa.ronditrack.staging
adb shell am force-stop za.co.andiswa.ronditrack.staging
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack.staging/join/ubuntu2026" za.co.andiswa.ronditrack.staging
```

**prod** (application id `za.co.andiswa.ronditrack`)

```powershell
# cold start: force-stop first, then open each link
adb shell am force-stop za.co.andiswa.ronditrack
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack/stokvels/umoja-family-fund" za.co.andiswa.ronditrack
adb shell am force-stop za.co.andiswa.ronditrack
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack/stokvels/umoja-family-fund/cycles/cycle-umoja-5" za.co.andiswa.ronditrack
adb shell am force-stop za.co.andiswa.ronditrack
adb shell am start -W -a android.intent.action.VIEW -d "ronditrack://za.co.andiswa.ronditrack/join/ubuntu2026" za.co.andiswa.ronditrack
```


Force-stop before each link, or you are only testing a running app. Back from the cycle link goes to the stokvel, then the list. Back from the invite link goes to Home.

**What a verified App Link would add.** An `https://` link that opens the app directly with no chooser, and nothing else can claim it. It needs a domain I own, a `/.well-known/assetlinks.json` file on it listing each flavour's package name and signing certificate fingerprint, and `android:autoVerify="true"` on an `https` intent filter. Anyone tapping the link without the app installed would land on a web page instead of a dead end.

**What an `adb` test does and does not prove.** It proves the intent filter matches, the right flavour is chosen by its application id, the cold start builds the right back stack and the redirect keeps the address through sign-in. It does not prove domain ownership or verification, how a messaging app, browser or email client treats the link, or that another app has not claimed the same scheme (a custom scheme is not exclusive).
