| 1 | Which endpoint returns a cycle's payout order, and what does each entry hold? | `GET /api/v1/stokvels/{stokvelId}/cycles/{cycleId}/payouts/payout-order` returns `{ stokvelId, cycleId, items[] }`. Each item holds `memberId`, `memberName`, `position` (1-based), `amountCents` (the pot), `payoutDate` (`yyyy-MM-dd` in Johannesburg, or `null` until paid) and `status`. `PayoutEntry` copies this with `Cents`, a `DateTime?` and `PayoutStatus`. |

## Personas

Names follow the API's demo seed. Sipho plays the brief's "Lerato" (Treasurer of one stokvel, Member of another). Mpho plays the brief's "Sipho" (Member only). Platform admin is in no stokvels. Nomsa is Admin of Umoja, and Broken (dev) fails on purpose.

| Person | Home | Ubuntu Savings Circle | Umoja Family Fund | Payouts view |
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
