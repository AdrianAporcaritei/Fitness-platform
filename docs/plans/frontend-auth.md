# Brainstorm WIP – Frontend: Auth screens (Flutter web)

**Status:** Brainstorming in progress (decisions 1–4 below approved 2026-10-11). No code yet.
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
| F1 | Missing auth designs | **Derive them from the landing + coach dashboard style** (dark, Poppins, orange accent). Show mockups of the screens for approval **before** any Flutter code. |
| F2 | Scope of this piece | **Full auth experience:** login; coach signup; client signup via invite link `/join/{code}` (invite preview "You're joining {coach}'s coaching" + form); verify email page; forgot password + reset page; minimal post-login home placeholder (name, role, logout); "verify your email – resend" banner for `PENDING` users; silent token refresh. Out of scope: coach invites UI, client list, profiles, dashboards. |
| F3 | Session persistence on web | **Persist the refresh token** (user stays signed in across reloads/restarts, up to 30 days) via `flutter_secure_storage` (web: browser storage; iOS/Android: Keychain/Keystore). Accepted risk: XSS could read it on web; mitigated by no third-party scripts, 15-min access tokens, reuse detection. **Dependency approved.** |
| F4 | API client generation | **`swagger_parser` + `retrofit` + `freezed`/`json_serializable` on `dio`**, generated from `docs/api/openapi.yaml` into `app/lib/api/generated/`. **Dependencies approved:** runtime `dio`, `retrofit`, `freezed_annotation`, `json_annotation`; dev `swagger_parser`, `build_runner`, `retrofit_generator`, `freezed`, `json_serializable`. Rejected: official `openapi-generator` dart-dio (verbose `built_value`, Java tool in the Flutter build); hand-written client (breaks "generated from the contract"). |
| F5 | Local tooling | Install Flutter stable into `~/flutter` (WSL). Run web as `flutter run -d web-server --web-port 5173` and open it in the Windows browser (no Chrome needed inside WSL). Tests headless with `flutter test`. |

Already given by `CLAUDE.md` (not re-decided): Flutter web first, Riverpod, go_router, organized by feature, UI strings via localization files (ro/en), `flutter_test`.

## 3. Done

- Explored `docs/design/`, toolchain and backend contract (findings above).
- Decisions F1–F5 approved.

## 4. Left to do

1. **Screen mockups** (F1): login, coach signup, join-by-invite, verify email, forgot/reset password, home placeholder with PENDING banner → user approval.
2. **Remaining open questions** (I will propose defaults):
   - Language: default from browser locale + ro/en switcher on auth screens? Signup sends the chosen `locale` and the browser timezone?
   - Landing page: is the Flutter app's `/` the login screen (landing stays a separate static site), or is the landing ported later?
   - Where "Start free" / "Start your free trial" point (coach signup).
   - Password rules shown in the UI (mirror backend validation).
3. **Design sections** (each approved separately): app structure (folders, feature modules); routing and guards (go_router, deep links above); auth state + token storage + refresh (single refresh in flight, 401 → refresh once → retry); error mapping (`code` → localized message, field errors); localization; theming from the design tokens; testing (widget tests per screen, unit tests for the auth/refresh logic, API mocked at the `dio` layer).
4. Write spec to `docs/superpowers/specs/YYYY-MM-DD-frontend-auth-design.md` → self-review → user review.
5. `writing-plans` → implementation plan → user chooses execution method → implement on a feature branch.
6. Before implementing: install Flutter (F5); update `CLAUDE.md` commands (web-server on 5173, API client regeneration command) and list the new dependencies there.

## 5. Where we left off

**Resume at:** step 1 of §4 – produce the screen mockups for approval.
