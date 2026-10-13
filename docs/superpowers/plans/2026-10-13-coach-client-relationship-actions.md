# Coach – Pause, Resume and End a Client Relationship

**Goal:** From the client list, a coach pauses an active client, resumes a paused one, or ends the relationship with either. Flutter only: `PATCH /coach/clients/{clientId}/relationship` and its tests already exist in the backend.

**Branch:** `feature/coach-client-relationship-actions`. Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Decision log (2026-10-13, proposed defaults; Adrian said to continue)

| # | Decision |
|---|---|
| R1 | The ⋮ menu also appears on ACTIVE rows (Pause, End relationship) and PAUSED rows (Resume, End relationship). ENDED rows have no menu. The tooltip becomes "Client actions" on these rows. |
| R2 | End asks for confirmation in a red dialog that says it is final and the coach loses access to the client's data. Pause and resume run immediately and show a snack bar. |
| R3 | The list reloads after every action, also after a failure. New messages for `INVALID_RELATIONSHIP_TRANSITION` and `CLIENT_NOT_FOUND`. |
| R4 | Allowed for unverified (PENDING) coaches, as in the backend. |

No contract, domain model or dependency changes.

## Steps

| # | Step | Verification |
|---|---|---|
| 1 | `ClientsRepository.changeRelationship` | analyzer |
| 2 | Widget tests first: menus per status, pause/resume request and snack, end confirmation (confirm and keep), error message and reload | tests fail |
| 3 | Menu, actions, error messages, l10n ro/en | `flutter analyze`, `flutter test` |
| 4 | Browser check by Adrian | notes below |

## Progress

| Step | Status |
|---|---|
| 1 | done |
| 2 | done |
| 3 | done (235 Flutter tests green) |
| 4 | pending |

## Verification notes (2026-10-13)

- Flutter: `flutter analyze` clean, `flutter test` – 235 tests green (10 new in `relationship_actions_test.dart`). Mutation check: skipping the End confirmation makes "Keep client sends nothing" fail.
- Browser check: pending.
