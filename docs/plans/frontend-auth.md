# Brainstorm WIP – Frontend: Auth screens (Flutter web)

**Status:** Design approved (sections 1–3, 2026-10-11); written spec `docs/superpowers/specs/2026-10-11-frontend-auth-design.md` awaiting user review. No code yet.
**Process:** superpowers `brainstorming` skill, **architectural** path (there is no `app/` yet: new Flutter project, structure, generated API client, auth flow) → clarifying questions → approaches → screen mockups → design sections → written spec (`docs/superpowers/specs/…`) → user review → `writing-plans`. No code until spec and plan are approved.
**Backend it builds on:** slice 1 (identity, auth, coach–client linking), merged into `master` (86c64a9, cleanup e626339). Contract: `docs/api/openapi.yaml`.

## 1. Findings from exploring the repo

- **No login/register design exists.** `docs/design/` has:
  - `landing/Ana Fit Lab Landing.html` – marketing page, en/ro, dark background (`#0e0e0f`, surfaces `#141415`/`#18181a`/`#222224`/`#262628`), Poppins, orange accent `#fb923c` (hover/light `#fdab6d`, text on accent `#1f0d02`), text `#f2f2f3` / muted `#a1a1a6` / `#8a8a8f`, error tones `#ff8a80` on `#2a1215`. CTAs "Start free" / "Start your free trial"; client steps say "Open the invite link from your coach and create your account".
  - `coach-dashboard/coach-client-list.html` – same visual language with slightly different values (accent `#ff9a3c`, greys `#141414`/`#1a1a1a`/`#2a2a2a`, text `#f2f2f2`).
  - `client-dashboard/` – empty.
  - Both files are self-unpacking bundles (open in a browser to view).
- **Flutter is not installed** in WSL.
- **The backend already fixes some frontend URLs** (emails, invite links), so the web app must serve them on `http://localhost:5173` with path URLs (no `#/`):
  - `/verify-email?token=…`
  - `/reset-password?token=…`
  - `/join/{code}`
- Backend CORS for the local profile allows `http://localhost:5173`.
- Spec D3 / brainstorm-wip: the Flutter client keeps **at most one refresh request in flight** (reuse of a rotated refresh token revokes the whole session family).
- Errors are RFC 9457 problems with a stable `code` and `errors[{field, code}]`; the app maps `code` to localized UI strings (it does not show the server `detail`).

## 2. Decisions made

| # | Topic | Decision |
|---|---|---|
| F1 | Missing auth designs | **Derive them from the landing + coach dashboard style** (dark, Poppins, orange accent). *Revised:* no mockup step and no visual companion – build directly in Flutter; the user reviews the running app (login, coach registration, invitation acceptance, link-problem page) and gives feedback. |
| F2 | Scope of this piece | **Full auth experience:** login; coach signup; client signup via invite link `/join/{code}` (invite preview "You're joining {coach}'s coaching" + form); verify email page; forgot password + reset page; minimal post-login home placeholder (name, role, logout); "verify your email – resend" banner for `PENDING` users; silent token refresh. Out of scope: coach invites UI, client list, profiles, dashboards. |
| F3 | Session persistence on web | **Persist the refresh token** (user stays signed in across reloads/restarts, up to 30 days) via `flutter_secure_storage` (web: browser storage; iOS/Android: Keychain/Keystore). Accepted risk: XSS could read it on web; mitigated by no third-party scripts, 15-min access tokens, reuse detection. **Dependency approved.** |
| F4 | API client generation | **`swagger_parser` + `retrofit` + `freezed`/`json_serializable` on `dio`**, generated from `docs/api/openapi.yaml` into `app/lib/api/generated/`. **Dependencies approved:** runtime `dio`, `retrofit`, `freezed_annotation`, `json_annotation`; dev `swagger_parser`, `build_runner`, `retrofit_generator`, `freezed`, `json_serializable`. Rejected: official `openapi-generator` dart-dio (verbose `built_value`, Java tool in the Flutter build); hand-written client (breaks "generated from the contract"). |
| F6–F10 | Language, `/` route, theme, `shared_preferences` (approved), cross-tab refresh lock | See spec §2. |
| F5 | Local tooling | Install Flutter stable into `~/flutter` (WSL). Run web as `flutter run -d web-server --web-port 5173` and open it in the Windows browser (no Chrome needed inside WSL). Tests headless with `flutter test`. |

Already given by `CLAUDE.md` (not re-decided): Flutter web first, Riverpod, go_router, organized by feature, UI strings via localization files (ro/en), `flutter_test`.

## 3. Done

- Explored `docs/design/`, toolchain and backend contract (findings above).
- Decisions F1–F10 approved; F2 confirmed as the full scope (option A); the expired-link page is one shared `LinkProblemView`.
- Design sections approved: 1 (defaults, structure, routing), 2 (auth state, tokens, refresh, errors), 3 (theme, localization, testing, tooling).
- Spec written: `docs/superpowers/specs/2026-10-11-frontend-auth-design.md`.

## 4. Left to do

1. User reviews the written spec.
2. `writing-plans` → implementation plan → user chooses execution method.
3. Implement on `feature/frontend-auth` (install Flutter first), then the user reviews the running app and gives feedback on the four key screens.

## 5. Where we left off

**Resume at:** user review of the spec.
