# Frontend – Auth Screens (Flutter web): Design

**Date:** 2026-10-11
**Status:** design approved section by section; written spec awaiting review
**Scope:** the first Flutter code in the repo – project setup, generated API client, session handling and every auth screen that slice 1's backend needs.
**Brainstorm record:** `docs/plans/frontend-auth.md`
**Backend:** slice 1, merged into `master` (86c64a9). Contract: `docs/api/openapi.yaml`. No backend changes in this piece.

---

## 1. Goal and success criteria

Let coaches and clients use the slice 1 backend from a real web app, in a style that matches `docs/design/`.

Done when:
1. A coach can sign up, gets the verification email, opens its link in the app and sees "Email confirmed".
2. A client can open an invite link `/join/{code}`, sees the coach's name, signs up and lands on home.
3. Login, logout, forgot password and reset password work end to end against the local backend.
4. A signed-in user stays signed in across reloads and browser restarts (up to the refresh token's 30 days), and several open tabs never trigger refresh-token reuse.
5. Expired, used or revoked links show one clear "link problem" page with a useful next step.
6. Every UI string exists in English and Romanian; the error `code` from the API is shown as a localized message, never the server's `detail`.
7. `flutter test` passes (unit + widget tests below); the backend suite still passes.
8. The user reviews the running app (`flutter run -d web-server --web-port 5173`) and approves the look of: login, coach registration, invitation acceptance, link-problem page.

## 2. Decisions

| # | Decision |
|---|---|
| F1 | No auth mockups exist. **No separate mockup step:** screens are built directly in Flutter in the style of `docs/design/` (near-black background, orange accent, Poppins); the user reviews the running app and gives feedback. |
| F2 | Scope = full auth experience: login, coach signup, client signup via invite, verify email, forgot/reset password, home placeholder with `PENDING` banner, silent refresh. |
| F3 | The refresh token is persisted with `flutter_secure_storage` (web: browser storage; mobile: Keychain/Keystore). The access token stays in memory. Accepted web risk: XSS could read the stored token (no third-party scripts, 15-min access tokens, reuse detection limit the damage). |
| F4 | API client generated from `docs/api/openapi.yaml` with `swagger_parser` → `retrofit` + `freezed`/`json_serializable` on `dio`. Generated code is committed. |
| F5 | Flutter stable in `~/flutter` (WSL). Dev run: `flutter run -d web-server --web-port 5173`, opened in the Windows browser. |
| F6 | Language: saved choice → else browser language (`ro*` → Romanian, otherwise English); EN/RO switch on auth screens; after login `user.locale` wins. Signup sends the current UI language and the browser's IANA time zone. |
| F7 | `/` → `/login` when signed out, `/home` when signed in. The landing page stays a separate site; its "Start free" CTAs will point to `/register` (later). |
| F8 | Dark theme only; Poppins bundled as font assets (no `google_fonts`). |
| F9 | Language choice persisted with `shared_preferences`. |
| F10 | Cross-tab refresh safety via the browser's Web Locks API (`navigator.locks`, through `dart:js_interop`); the stored token is re-read inside the lock. |

## 3. Out of scope

Coach invites UI, client list, coach profile, `PATCH /me`, change password, `POST /me/coach-link` (a signed-in client joining a coach), dashboards, light theme, porting the landing page, iOS/Android builds and their time-zone lookup, CI.

## 4. Dependencies

All approved (F3, F4, F9) or part of the stack in `CLAUDE.md`:

| Package | Kind | Why |
|---|---|---|
| `flutter_riverpod` | runtime | state management (stack) |
| `go_router` | runtime | routing, deep links, guards (stack) |
| `flutter_localizations` (SDK), `intl` | runtime | `gen_l10n` localization (stack) |
| `dio` | runtime | HTTP, interceptors for auth/refresh |
| `retrofit`, `freezed_annotation`, `json_annotation` | runtime | annotations used by the generated client |
| `flutter_secure_storage` | runtime | refresh token storage (F3) |
| `shared_preferences` | runtime | saved language choice (F9) |
| `swagger_parser`, `build_runner`, `retrofit_generator`, `freezed`, `json_serializable` | dev | client generation (F4) |
| `flutter_lints` | dev | default lints (comes with `flutter create`) |

Versions: the current stable releases at implementation time, pinned with `^` in `pubspec.yaml` and locked by the committed `pubspec.lock`. No other packages; tests use a hand-written fake `dio` adapter instead of a mocking library.

## 5. Project structure

`flutter create app --org com.anafitlab --platforms web,android,ios`, organized by feature:

```
app/
  pubspec.yaml, l10n.yaml, swagger_parser.yaml, analysis_options.yaml
  assets/fonts/            Poppins (Regular, Medium, SemiBold, Bold) + OFL.txt
  web/                     index.html (title, theme color, favicon "A")
  lib/
    main.dart              ProviderScope, usePathUrlStrategy(), runApp
    app.dart               MaterialApp.router: theme, locale, localizationsDelegates
    core/
      config.dart          API_BASE_URL from --dart-define (default http://localhost:8080/api/v1)
      api/
        generated/         swagger_parser + build_runner output (committed, never hand-edited)
        api_client.dart    Dio instance, interceptors, generated client provider
        auth_interceptor.dart
      auth/
        session.dart       Session {accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, user}
        auth_state.dart    sealed: AuthUnknown | SignedOut(reason?) | SignedIn(user)
        auth_controller.dart   Riverpod Notifier: start, login, registerCoach, registerClient, applySession, logout
        token_store.dart   flutter_secure_storage wrapper (refresh token + expiry)
        refresh_coordinator.dart   single in-flight refresh + cross-tab lock
        web_lock.dart      navigator.locks via js_interop (conditional import; non-web = in-process lock)
      errors/
        api_error.dart     ApiError {status, code, fieldErrors, retryAfter} + fromDio
        error_messages.dart    code → localized string
      l10n/                app_en.arb, app_ro.arb (+ generated AppLocalizations)
      locale/
        locale_controller.dart   saved choice / browser language / user.locale
        browser_time_zone.dart   Intl.DateTimeFormat().resolvedOptions().timeZone via js_interop (conditional import; fallback "UTC")
      routing/router.dart  go_router routes, redirect guards, refreshListenable = auth state
      theme/
        tokens.dart        colors, radii, spacing from docs/design
        app_theme.dart     ThemeData (dark, Poppins)
      validation/validators.dart   email, required, max length, password (10–64 chars, ≤72 UTF-8 bytes)
      widgets/
        auth_scaffold.dart       logo + title, centered card (max 420px), language switch
        app_text_field.dart      label, hint, error, password visibility toggle
        primary_button.dart      orange, loading state
        form_error_banner.dart   non-field errors
        link_problem_view.dart   shared "link problem" page
        language_switch.dart
    features/
      auth/
        login/login_page.dart
        register_coach/register_coach_page.dart
        join/join_page.dart              invite preview + client signup form
        verify_email/verify_email_page.dart
        password_reset/forgot_password_page.dart, reset_password_page.dart
      home/home_page.dart                placeholder + PENDING banner
  test/                    mirrors lib/ (unit + widget tests), support/fake_api.dart
```

Each page owns its form state (a small Riverpod notifier or `StatefulWidget` state); pages call the `AuthController` or the generated client, never `dio` directly.

## 6. Routing

Path URLs (`usePathUrlStrategy`), so the backend's links work as sent: `{APP_BASE_URL}/verify-email?token=…`, `/reset-password?token=…`, `/join/{code}`.

| Route | Access | Behaviour |
|---|---|---|
| `/` | – | redirect: signed in → `/home`, else `/login` |
| `/login` | signed out | form: email, password; links to `/forgot-password` and `/register`. Success → `from` query param if present, else `/home`. Shows a notice if it was reached because a session ended (`SignedOut(reason)`). |
| `/register` | signed out | coach signup: first name, last name, email, password. Success → `/home` (user is `PENDING`, banner shown). |
| `/join/:code` | signed out | loads `GET /invites/{code}`; shows "You're joining {first} {last}'s coaching" + client signup form (same fields as `/register`). Success → `/home`. Signed in → message "You're signed in as {email}" + "Sign out to create a new account" button. |
| `/verify-email?token=` | anyone | calls `POST /auth/verify-email` once on open; success → "Email confirmed" + button (home if signed in, else login); if signed in, the user in state is refreshed to `ACTIVE` (via `GET /me`). |
| `/forgot-password` | signed out | email field → `POST /auth/password-reset/request` → always "If an account exists, we've sent a link" (202 is returned whether or not the email exists). |
| `/reset-password?token=` | anyone | new password + confirm → `POST /auth/password-reset/confirm` → new session applied → `/home`. If someone else was signed in on this browser, their session is replaced. |
| `/home` | signed in | placeholder (§8). |
| unknown | – | `/` |

`from` is only honoured when it is an in-app path (starts with a single `/`, not `//`, no scheme); otherwise it is ignored (no open redirect).

Guards are one `redirect` function: while `AuthUnknown` → splash route `/loading` (keeps the requested location and returns to it); signed-in user on a signed-out-only route → `/home`; signed-out user on `/home` → `/login?from=/home`.

### Link-problem page (`LinkProblemView`)

One shared layout: icon, title, explanation, one primary action. Rendered by the page whose link failed (no separate route, so the URL stays what the user opened).

| Case (API code) | Title / text | Action |
|---|---|---|
| `INVITE_EXPIRED` | "This invite has expired" – ask your coach for a new one | — (no action; text only) |
| `INVITE_USED` | "This invite was already used" – if it was you, sign in | Go to login |
| `INVITE_REVOKED` | "This invite is no longer valid" – ask your coach for a new one | — |
| `INVITE_NOT_FOUND` | "We couldn't find this invite" – check the link | — |
| `COACH_UNAVAILABLE` | "Your coach isn't available right now" – try again later or contact your coach | — |
| verify `INVALID_TOKEN` | "This confirmation link is invalid or has expired" | signed in + `PENDING`: Resend email; signed in + `ACTIVE`: Go home ("already confirmed"); signed out: Go to login |
| reset `INVALID_TOKEN` | "This reset link is invalid or has expired" | Request a new link (`/forgot-password`) |

## 7. Session, tokens and refresh

**State:** `AuthController` holds `AuthUnknown` at start, then `SignedOut(reason?)` or `SignedIn(user)`. The router listens to it. The current `Session` (with the in-memory access token) lives beside the state in the controller.

**Storage:** `TokenStore` saves only `refreshToken` and `refreshTokenExpiresAt` (`flutter_secure_storage`). Every time a `TokenResponse` arrives (login, signup, refresh, reset confirm) the session is applied: access token in memory, refresh token saved, user in state.

**Start-up:** read the stored refresh token.
- none or expired → `SignedOut`.
- present → `POST /auth/refresh` → apply session → `SignedIn`.
- 401/403 → clear storage → `SignedOut`.
- network error → stay on the splash with "Can't reach the server" + Retry (token kept).

**`AuthInterceptor`** (on the Dio used by the generated client):
- Public calls (`/auth/register/*`, `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/verify-email`, `/auth/password-reset/*`, `/invites/*`) get no `Authorization` header. `/auth/verify-email/resend` is authenticated.
- Before an authenticated call: if the access token expires within 60 s, await a refresh first.
- On a 401 for an authenticated call that carried a token: refresh once, retry the call once. A second 401 → sign out.
- Every call carries `Accept-Language: <current UI language>`.

**`RefreshCoordinator`** – at most one refresh in flight:
- Concurrent callers share one `Future`.
- On web the refresh runs inside `navigator.locks.request('anafitlab-refresh', …)`. Inside the lock it re-reads the stored refresh token: if it differs from the one this tab used, another tab already rotated it, so it uses the stored token.
- Failure handling: `INVALID_REFRESH_TOKEN` / `REFRESH_TOKEN_REUSED` → clear, `SignedOut(sessionEnded)`; `ACCOUNT_SUSPENDED` → clear, `SignedOut(suspended)`; network error → the original call fails with `NETWORK`, session kept.

**Logout:** `POST /auth/logout {refreshToken}` best-effort (errors ignored), clear storage and memory, `SignedOut()` → `/login`.

## 8. Screens

All auth screens use `AuthScaffold`: orange "A" logo + "Ana Fit Lab" on top, content in a card (max width 420 px, centered) on desktop, full width with 16 px side margins on phones, EN/RO switch top right.

- **Login:** email, password (show/hide), "Forgot password?" link, primary "Sign in", secondary text "New coach? Create an account" → `/register`.
- **Coach registration:** first name, last name, email, password with hint "10–64 characters"; primary "Create account"; "Already have an account? Sign in".
- **Invitation acceptance (`/join/:code`):** loading state while the preview loads; header "You're joining {coach}'s coaching"; same form as registration; primary "Create account and join".
- **Verify email:** loading → "Email confirmed" (check icon) or link-problem page.
- **Forgot password:** email; primary "Send reset link"; confirmation text after submit (same text for every email).
- **Reset password:** new password + confirm (must match, checked in the app); primary "Set new password".
- **Home (placeholder):** "Hello, {firstName}", role label (Coach/Client), "Sign out". When `status == PENDING`: banner "Confirm your email – we sent a link to {email}" + "Resend" (`POST /auth/verify-email/resend`; on success "Sent"; `RATE_LIMITED` → wait message).

Buttons show a spinner and are disabled while a request runs; Enter submits forms; fields have proper `autofillHints` (email, password, new password, given/family name).

## 9. Errors and validation

- `ApiError.fromDio`: parses `application/problem+json` (`status`, `code`, `errors[{field, code}]`), `Retry-After` (seconds) for 429. Connection errors/timeouts → `code = NETWORK`; anything else unparseable → `INTERNAL_ERROR`.
- Messages come from ARB keys `error_<CODE>` with a generic fallback (`error_UNKNOWN`). The server's `detail` is never shown.
- Field errors (`REQUIRED`, `TOO_LONG`, `INVALID_EMAIL`, `PASSWORD_POLICY`, `INVALID_LOCALE`, `INVALID_TIMEZONE`) appear under the matching field (`field` names match the request properties); `EMAIL_TAKEN` is shown under the email field.
- `RATE_LIMITED` → "Too many attempts. Try again in {minutes} min." (rounded up from `Retry-After`).
- `INVALID_CREDENTIALS` → one message ("Email or password is incorrect"), never which one.
- Client-side validation mirrors the contract before sending: required fields, email format, names ≤ 100, email ≤ 254, password 10–64 characters and ≤ 72 UTF-8 bytes, passwords match (reset).

## 10. Localization

`gen_l10n` with `app_en.arb` (template) and `app_ro.arb` (Romanian with diacritics). Every visible string, including error messages and link-problem texts, comes from the ARB files. `LocaleController`: saved choice (`shared_preferences`) → else browser language → after login `user.locale` (the user's saved account language wins and is also saved locally). Changing the language on an auth screen changes the UI immediately and is what signup sends as `locale`.

## 11. Theme

Tokens from `docs/design/` (landing values are canonical; the dashboard's slightly different greys/orange are treated as the same tokens):

| Token | Value |
|---|---|
| background | `#0e0e0f` |
| surface / surface-2 / surface-3 | `#141415` / `#18181a` / `#222224` |
| border / border-strong | `#262628` / `#2a2a2c` |
| text / text-muted / text-subtle | `#f2f2f3` / `#a1a1a6` / `#8a8a8f` |
| accent / accent-hover / on-accent | `#fb923c` / `#fdab6d` / `#1f0d02` |
| error text / error surface / error border | `#ff8a80` / `#2a1215` / `#5c2b2e` |

Poppins for all text. `ThemeData` (Material 3, dark) maps these to `ColorScheme`, `InputDecorationTheme`, button themes and text styles, so pages do not hard-code colors.

## 12. Testing

`flutter test`, headless; the API is faked at the Dio layer with a small `FakeApi` adapter (`test/support/fake_api.dart`) that matches method + path and returns canned JSON / problems.

Unit:
- `ApiError.fromDio`: problem with field errors, 429 with `Retry-After`, network error, non-JSON body.
- `RefreshCoordinator`: concurrent callers share one refresh; stored token re-read inside the lock (another tab rotated it); reuse/invalid → `SignedOut(sessionEnded)`; suspended → `SignedOut(suspended)`; network error keeps the session.
- `AuthInterceptor`: no header on public calls; proactive refresh near expiry; 401 → refresh → single retry; second 401 → sign out; `Accept-Language` set.
- `AuthController.start`: no token / valid token / rejected token / network error.
- Validators: password length and the 72-byte limit with multi-byte characters; email; max lengths.
- `LocaleController`: saved choice, browser `ro-RO` → ro, `de` → en, `user.locale` override.

Widget (per screen, with `FakeApi`):
- Login: validation, `INVALID_CREDENTIALS` message, `RATE_LIMITED` message, success → `/home`, `from` honoured, session-ended notice.
- Register coach: field errors from the server mapped to fields, `EMAIL_TAKEN` under email, success → home with `PENDING` banner.
- Join: preview shows coach name; each link-problem code renders its variant; `COACH_UNAVAILABLE`; signed-in variant; success → home.
- Verify email: success; `INVALID_TOKEN` signed out / signed in `PENDING` (resend) / signed in `ACTIVE`.
- Forgot password: same confirmation for any email; reset: mismatch check, `INVALID_TOKEN` variant, success → home.
- Home: banner only for `PENDING`; resend success and `RATE_LIMITED`; sign out.
- Router guards: signed-out → `/login?from=…`; signed-in on `/login` → `/home`; splash while `AuthUnknown`.
- Language switch changes visible texts (en ↔ ro).

Manual end-to-end (local backend + Mailpit): coach signup → verify via Mailpit link → login in a second tab (no logout of the first) → reload keeps the session → create an invite (via Swagger UI, since the invites UI is out of scope) → join as client in a private window → forgot/reset password → expired-link page (use an already-used invite).

## 13. Tooling and documentation

- Install Flutter stable to `~/flutter`, add `~/flutter/bin` to `PATH`; `flutter config --enable-web`; `flutter doctor` must show web OK (Android/iOS toolchains not needed yet).
- `app/swagger_parser.yaml`: input `../docs/api/openapi.yaml`, output `lib/core/api/generated`, retrofit + freezed. Regenerate: `cd app && dart run swagger_parser && dart run build_runner build -d`.
- `CLAUDE.md`: add commands (web run on 5173 with `--dart-define=API_BASE_URL=…` optional, regenerate client, `flutter test`), note that `app/lib/core/api/generated/` is generated and committed, and list the new dependencies with their reasons (§4).
- `docs/plans/frontend-auth.md`: status updated when the spec is approved and when the plan exists.
