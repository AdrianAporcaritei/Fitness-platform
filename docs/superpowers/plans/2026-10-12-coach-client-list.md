# Coach – Add Client & Client List Implementation Plan

**Goal:** A coach adds a client (name + email → one-time invite link) and sees a paginated, searchable, filterable list of invited and linked clients; pending invites can be regenerated or cancelled.

**Branch:** `feature/coach-client-list`. Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

**Design:** `docs/design/coach-dashboard/coach-client-list.html` (only the columns name, email, status, invitation date).

## Decision log (approved 2026-10-12)

| # | Decision |
|---|---|
| P1 | `coach_invite` gets `email varchar(254) null` (lowercase CHECK); `label` holds the invitee's name (required through the API). `INVITED` is NOT reintroduced in `coach_client`; the INVITED rows of the list come from pending invites. Domain model decision #32. |
| P2 | Old endpoints `POST /coach/invites`, `GET /coach/invites`, `POST /coach/invites/{id}/revoke` are removed. New: `POST /coach/clients`, paginated `GET /coach/clients`, `POST /coach/invites/{id}/regenerate`, `DELETE /coach/invites/{id}`. Prefix stays `/coach/invites`. |
| P3 | ENDED appears only with the explicit `status=ENDED` filter, read-only, one row per client (most recent relationship), and never for a client who is currently linked to the same coach. Default list = INVITED + ACTIVE + PAUSED. |
| P4 | Expired pending invites are listed under INVITED with `invitationExpired = true`; they can be regenerated or cancelled. Regenerate keeps the row id and `created_at`, rotates the code hash and resets `expires_at` to now + 7 days. |
| P5 | Search is case-insensitive only (name and email); accent-insensitive search deferred (domain model §10). |
| P6 | Below ~840 px the sidebar becomes a drawer; below ~600 px the table becomes a card list. |
| P7 | No new dependencies (Spring JdbcTemplate for the UNION query; Flutter `Clipboard`, `Timer`, `intl`). |
| P8 | Duplicate checks only within the coach's own data: `INVITE_ALREADY_PENDING` (a non-expired pending invite with that email), `ALREADY_YOUR_CLIENT` (a current client with that email). Other accounts are never revealed. |
| P9 | A PENDING (unverified) coach sees the list but cannot add or regenerate (`403 EMAIL_NOT_VERIFIED`); cancel is allowed. |
| P10 | Invitee email is informational: the client may register with any email. No email is sent (the coach shares the link). |

## Always / Never

- Always: contract in `openapi.yaml` first; integration tests written before the implementation; generated files only through the generators.
- Never (this slice): goal/workout/measurement/diary/message/flag columns, KPI cards, attention sort, automatic email, bulk actions, pause/end UI, accent-insensitive search.

## Steps

| # | Step | Verification |
|---|---|---|
| 1 | Docs: domain-model.md (P1, decision #32, §10 note for P5), openapi.yaml (P2) | `./mvnw test -Dtest=OpenApiContractServedTest` |
| 2 | Backend tests first (`CoachRosterTest`, `CoachInvitationActionsTest`, updates to existing tests), then V3 migration, services, controllers | `cd backend && ./mvnw test` all green |
| 3 | Regenerate Flutter API client | `flutter analyze` clean |
| 4 | Coach shell (sidebar, disabled items) + routing (coach lands on `/coach/clients`) | `flutter test test/core/routing` |
| 5 | Client list page: table/cards, search (debounced, URL state), status filter, server paging, loading/error/empty/no-match | widget tests |
| 6 | Add-client dialog (link once + copy), regenerate (link once), cancel with confirmation | widget tests |
| 7 | l10n ro/en, manual E2E in browser | `flutter test`, notes below |

## Progress

| Step | Status |
|---|---|
| 1 | done |
| 2 | done (223 backend tests green) |
| 3 | pending |
| 4 | pending |
| 5 | pending |
| 6 | pending |
| 7 | pending |
