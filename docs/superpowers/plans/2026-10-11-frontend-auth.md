# Frontend – Auth Screens (Flutter web) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Flutter web app in `app/` where coaches and clients sign up, sign in, verify their email, reset their password and stay signed in, against the slice 1 backend.

**Architecture:** One Riverpod `AuthController` owns the session (access token in memory, refresh token in `flutter_secure_storage`) and exposes a sealed `AuthState` that drives go_router's redirect guard. All HTTP goes through one `Dio` with an `AuthInterceptor` (bearer header, proactive and 401-driven refresh, `Accept-Language`), wrapped by a client generated from `docs/api/openapi.yaml`. Refreshes are serialized by a `RefreshCoordinator` (one in-flight `Future` + `navigator.locks` across tabs).

**Tech Stack:** Flutter stable (web), Dart 3, flutter_riverpod 3 (no codegen), go_router, gen_l10n, dio, swagger_parser + retrofit + freezed/json_serializable, flutter_secure_storage, shared_preferences, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-11-frontend-auth-design.md` (section numbers below like "§7" refer to it). Project rules: `CLAUDE.md`. API contract: `docs/api/openapi.yaml`.

## Global Constraints

- Work on branch `feature/frontend-auth`. No backend changes. All commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Only these packages (§4): runtime `flutter_riverpod`, `go_router`, `flutter_localizations` (SDK), `intl`, `dio`, `retrofit`, `freezed_annotation`, `json_annotation`, `flutter_secure_storage`, `shared_preferences`; dev `swagger_parser`, `build_runner`, `retrofit_generator`, `freezed`, `json_serializable`, `flutter_lints`. Current stable versions with `^`, `pubspec.lock` committed. No mocking library, no `google_fonts`, no `riverpod_generator`. Anything else: stop and ask.
- `app/lib/core/api/generated/` is generated (`dart run swagger_parser && dart run build_runner build -d`), committed, never hand-edited.
- API base URL: `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api/v1')`.
- Path URLs (`usePathUrlStrategy()`); backend links are `/verify-email?token=…`, `/reset-password?token=…`, `/join/{code}`. Dev server: `flutter run -d web-server --web-port 5173`.
- Every visible string comes from `app_en.arb` / `app_ro.arb` (Romanian with diacritics). Error text comes from `error_<CODE>` keys; the server's `detail` is never shown.
- Password rule: 10–64 **code points** (`String.runes.length`) and ≤ 72 UTF-8 bytes (`utf8.encode(v).length`). Names ≤ 100, email ≤ 254 (trimmed).
- Proactive refresh threshold: access token expiring within **60 s**. Web lock name: `anafitlab-refresh`. Secure-storage keys: `refresh_token`, `refresh_token_expires_at`. Prefs key: `locale`.
- Theme tokens exactly as §11; pages never hard-code colors (read from `Theme`/`AppTokens`).
- Pages call `AuthController` or the generated client, never `Dio` directly. Time-dependent code takes the current time from `nowProvider` (`DateTime Function()`), never `DateTime.now()` directly.
- Tests: `flutter test` headless; HTTP faked with `test/support/fake_api.dart` (a Dio `HttpClientAdapter`).

## Review Focus

1. **Two tabs, access token expires in both at once.** Both must end with a valid session and the backend must never see the same refresh token twice (no `REFRESH_TOKEN_REUSED`). → Task 6 test `second caller after another tab rotated uses the stored token`.
2. **Backend down at start-up with a stored token.** User expects "Can't reach the server" + Retry, and the token must still be there after Retry succeeds — not a silent sign-out. → Task 7 test `start keeps token on network error`.
3. **`from` query param with an external or protocol-relative URL** (`?from=//evil.com`, `?from=https://evil.com`) after login must go to `/home`. → Task 9 test `login ignores external from`.
4. **Invite code typed or pasted loosely in the URL** (`/join/abcde-fghij`, `/join/ABCDE%20FGHIJ`) must be passed to the API unchanged (the backend normalizes it) — the app must not reject or re-format it. → Task 11 test `join passes the raw code to the API`.
5. **Verify-email page rebuilt or revisited** (hot reload, router refresh when auth state changes after `GET /me`) must not call `POST /auth/verify-email` a second time (the token is single use; a second call shows `INVALID_TOKEN` over the success). → Task 12 test `verify is called once even when auth state changes`.

---

## File Structure

Exactly §5 of the spec. Additions decided here:

```
app/lib/core/time.dart                        nowProvider
app/lib/core/storage.dart                     sharedPreferencesProvider (overridden in main)
app/lib/core/auth/web_lock_web.dart           js_interop implementation (conditional import target)
app/lib/core/auth/web_lock_stub.dart          in-process implementation
app/lib/core/locale/browser_time_zone_web.dart / _stub.dart
app/lib/core/routing/splash_page.dart         /loading (spinner, or "Can't reach the server" + Retry)
app/test/support/fake_api.dart                FakeApi adapter + FakeResponse
app/test/support/fixtures.dart                userJson(), tokenJson()
app/test/support/test_app.dart                pumpApp(): ProviderScope with overrides + MaterialApp.router
```

---

### Task 1: Toolchain, project scaffold, theme

**Files:**
- Create: `app/` via `flutter create`, `app/pubspec.yaml` (deps), `app/analysis_options.yaml`, `app/assets/fonts/Poppins-{Regular,Medium,SemiBold,Bold}.ttf` + `OFL.txt`, `app/web/index.html`, `app/lib/main.dart`, `app/lib/app.dart`, `app/lib/core/config.dart`, `app/lib/core/time.dart`, `app/lib/core/storage.dart`, `app/lib/core/theme/tokens.dart`, `app/lib/core/theme/app_theme.dart`
- Modify: `.gitignore` (Flutter: `app/.dart_tool/`, `app/build/`, `app/.flutter-plugins*`)
- Test: `app/test/core/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `const apiBaseUrl` (config.dart); `final nowProvider = Provider<DateTime Function()>((_) => DateTime.now)`; `final sharedPreferencesProvider = Provider<SharedPreferences>((_) => throw UnimplementedError())`; `abstract final class AppTokens { static const Color background, surface, surface2, surface3, border, borderStrong, text, textMuted, textSubtle, accent, accentHover, onAccent, errorText, errorSurface, errorBorder; static const double radius = 12, radiusSmall = 8; }`; `ThemeData buildAppTheme()`; `class App extends ConsumerWidget` (in app.dart).

- [x] **Step 1: Install Flutter** – `git clone https://github.com/flutter/flutter.git -b stable ~/flutter`, add `export PATH="$HOME/flutter/bin:$PATH"` to `~/.bashrc`, `flutter config --enable-web`, `flutter doctor`. Expected: Flutter and "Web Server" OK (Android/Chrome/iOS warnings are fine).
- [x] **Step 2: Scaffold** – `flutter create app --org com.anafitlab --platforms web,android,ios --project-name ana_fit_lab`; delete the counter demo and `test/widget_test.dart`. `flutter pub add` the runtime packages and `flutter pub add --dev` the dev packages from Global Constraints. Add `flutter: generate: true`, the Poppins font family (400/500/600/700) under `fonts:`. Download Poppins + OFL from the google/fonts GitHub repo (`ofl/poppins/`). `web/index.html`: `<title>Ana Fit Lab</title>`, `theme-color` `#0e0e0f`, body background `#0e0e0f`.
- [x] **Step 3: Write the failing test** `app_theme_test.dart`:
  - `buildAppTheme()` is dark (`brightness == Brightness.dark`), `scaffoldBackgroundColor == Color(0xFF0E0E0F)`, `colorScheme.primary == Color(0xFFFB923C)`, `colorScheme.onPrimary == Color(0xFF1F0D02)`, `colorScheme.error == Color(0xFFFF8A80)`, `textTheme.bodyMedium!.fontFamily == 'Poppins'`.
- [x] **Step 4: Run** `cd app && flutter test test/core/theme` – Expected: FAIL (`buildAppTheme` not defined).
- [x] **Step 5: Implement** `tokens.dart` with the §11 values and `buildAppTheme()` (Material 3, `fontFamily: 'Poppins'`, `ColorScheme.dark` mapped from tokens, `InputDecorationTheme` filled `surface2` with `border` outline / `accent` focused / `errorBorder` error, `FilledButtonThemeData` accent background + onAccent text, radius 12, height 48). `config.dart`, `time.dart`, `storage.dart` as in Interfaces. `main.dart`: `usePathUrlStrategy()`, `final prefs = await SharedPreferences.getInstance()`, `runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const App()))`. `App` temporarily renders `MaterialApp(theme: buildAppTheme(), home: SizedBox())` (router comes in Task 8).
- [x] **Step 6: Run** `flutter test && flutter analyze` – Expected: PASS, no issues. `flutter build web` succeeds.
- [x] **Step 7: Commit** – `git add .gitignore app && git commit -m "feat(app): Flutter web scaffold, dependencies, dark theme tokens"`

### Task 2: Generated API client

**Files:**
- Create: `app/swagger_parser.yaml`, `app/lib/core/api/generated/**` (generated), `app/build.yaml` (only if needed to scope build_runner to `lib/core/api/generated`)
- Test: `app/test/core/api/generated_models_test.dart`

**Interfaces:**
- Produces: one retrofit client class over `Dio` with methods named after the `operationId`s (`login`, `registerCoach`, `registerClient`, `refresh`, `logout`, `verifyEmail`, `resendVerificationEmail`, `requestPasswordReset`, `confirmPasswordReset`, `previewInvite`, `getMe`, …) and freezed models named after the schemas (`TokenResponse`, `UserResponse`, `LoginRequest`, `RegisterCoachRequest`, `RegisterClientRequest`, `RefreshRequest`, `LogoutRequest`, `VerifyEmailRequest`, `PasswordResetRequest`, `PasswordResetConfirmRequest`, `InvitePreviewResponse`). **After generating, write the actual root client class name and the enum type names for `UserResponse.role`/`status`/`locale` into this Interfaces block** (later tasks refer to them as `ApiClient`, `UserRole`, `UserStatus`, `UserLocale`).

- [x] **Step 1: Configure** `swagger_parser.yaml`: `schema_path: ../docs/api/openapi.yaml`, `output_directory: lib/core/api/generated`, `language: dart`, `json_serializer: freezed`, `root_client: true`, `root_client_name: ApiClient`, `merge_clients: true` (the contract has no tags), `enums_to_json: true`, `unknown_enum_value: true`.
- [x] **Step 2: Generate** – `dart run swagger_parser && dart run build_runner build -d`. Expected: no errors; `flutter analyze lib/core/api` clean (add `analyzer: exclude: [lib/core/api/generated/**]` only for lints, not errors). If OpenAPI 3.1 `type: [string, 'null']` is not understood (field generated as non-nullable or as `dynamic`), stop and report – do not edit the contract or generated files.
- [x] **Step 3: Write the test** `generated_models_test.dart`:
  - `TokenResponse.fromJson(tokenJson())` round-trips: `user.email`, `user.role` is COACH, `accessTokenExpiresAt` parses as a UTC `DateTime`.
  - `RegisterCoachRequest(...).toJson()` has exactly the keys `email, password, firstName, lastName, locale, timezone` and `locale == 'en'`.
  - Create `test/support/fixtures.dart` here: `Map<String, dynamic> userJson({String role = 'COACH', String status = 'PENDING', String locale = 'en', String email = 'ana@example.ro', String firstName = 'Ana'})`, `Map<String, dynamic> tokenJson({Map<String, dynamic>? user, String access = 'access-1', String refresh = 'refresh-1', Duration accessValidFor = const Duration(minutes: 15), DateTime? now})`.
- [x] **Step 4: Run** `flutter test test/core/api` – Expected: PASS.
- [x] **Step 5: Commit** – `git add app && git commit -m "feat(app): API client generated from openapi.yaml"`

### Task 3: API errors and the fake API

**Files:**
- Create: `app/lib/core/errors/api_error.dart`, `app/test/support/fake_api.dart`
- Test: `app/test/core/errors/api_error_test.dart`

**Interfaces:**
- Produces:
  - `class ApiError implements Exception { final int? status; final String code; final List<FieldError> fieldErrors; final Duration? retryAfter; factory ApiError.fromDio(DioException e); String? fieldCode(String field); }`, `record FieldError(String field, String code)` (or a small class). Codes `NETWORK` and `INTERNAL_ERROR` are produced locally.
  - `class FakeApi implements HttpClientAdapter { void on(String method, String path, FakeHandler handler); final List<RequestOptions> requests; int count(String method, String path); }` where `typedef FakeHandler = FutureOr<FakeResponse> Function(RequestOptions r)`; `FakeResponse.json(int status, Object? body)`, `FakeResponse.empty(int status)`, `FakeResponse.problem(int status, String code, {List<Map<String,String>> errors = const [], int? retryAfterSeconds})` (content type `application/problem+json`), `FakeResponse.networkError()` (adapter throws `DioException.connectionError`). `path` is matched against `RequestOptions.uri.path` with the `/api/v1` prefix stripped; an unmatched request fails the test with the method and path in the message. A handler may be a `Completer`-backed future so tests control timing.

- [x] **Step 1: Write the failing tests** `api_error_test.dart` (use a `Dio` with `FakeApi` and catch the `DioException`):
  - 400 problem with `errors: [{field: email, code: INVALID_EMAIL}]` → `status 400`, `code == 'VALIDATION_FAILED'`, `fieldCode('email') == 'INVALID_EMAIL'`.
  - 429 problem with `Retry-After: 120` → `code 'RATE_LIMITED'`, `retryAfter == Duration(seconds: 120)`.
  - `FakeResponse.networkError()` and a receive timeout → `code 'NETWORK'`, `status null`.
  - 500 with `text/html` body `<h1>oops</h1>` → `code 'INTERNAL_ERROR'`, `status 500`.
- [x] **Step 2: Run** `flutter test test/core/errors` – Expected: FAIL.
- [x] **Step 3: Implement** `ApiError.fromDio` and `FakeApi`. Connection error / timeouts / `unknown` without response → `NETWORK`; a response whose body is not a map with a string `code` → `INTERNAL_ERROR`.
- [x] **Step 4: Run** – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): ApiError from problem responses, FakeApi test adapter"`

### Task 4: Validators

**Files:**
- Create: `app/lib/core/validation/validators.dart`
- Test: `app/test/core/validation/validators_test.dart`

**Interfaces:**
- Produces: top-level functions returning an error **code** (same codes as the API, so one mapper turns both into text) or `null`: `String? validateRequired(String? v)` → `REQUIRED`; `String? validateEmail(String? v)` → `REQUIRED` / `INVALID_EMAIL` / `TOO_LONG` (>254 after trim); `String? validateName(String? v)` → `REQUIRED` / `TOO_LONG` (>100 after trim); `String? validateNewPassword(String? v)` → `REQUIRED` / `PASSWORD_POLICY`; `String? validatePasswordConfirmation(String? v, String password)` → `REQUIRED` / `PASSWORDS_DONT_MATCH`.

- [x] **Step 1: Write the failing tests:**
  - password: 9 ASCII chars → `PASSWORD_POLICY`; 10 → null; 64 → null; 65 → `PASSWORD_POLICY`; `'🔥' * 10` (10 code points, 40 bytes) → null; `'🔥' * 19` (76 bytes) → `PASSWORD_POLICY`; `'ă' * 37` (74 bytes) → `PASSWORD_POLICY`; `'ă' * 36` (72 bytes) → null; empty → `REQUIRED`.
  - email: `' ana@example.ro '` → null; `'ana'`, `'ana@'`, `'@x.ro'`, `'a b@x.ro'` → `INVALID_EMAIL`; 255-char valid-shaped address → `TOO_LONG`.
  - name: `'  '` → `REQUIRED`; 100 chars → null; 101 → `TOO_LONG`.
  - confirmation: mismatch → `PASSWORDS_DONT_MATCH`.
- [x] **Step 2: Run** `flutter test test/core/validation` – Expected: FAIL.
- [x] **Step 3: Implement.** Email shape: `^[^\s@]+@[^\s@]+\.[^\s@]+$` on the trimmed value (the server does the strict check).
- [x] **Step 4: Run** – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): client-side validators mirroring the API contract"`

### Task 5: Localization, error messages, language

**Files:**
- Create: `app/l10n.yaml`, `app/lib/core/l10n/app_en.arb`, `app/lib/core/l10n/app_ro.arb`, `app/lib/core/errors/error_messages.dart`, `app/lib/core/locale/locale_controller.dart`, `app/lib/core/locale/browser_time_zone.dart` (+ `_web.dart`, `_stub.dart`), `app/lib/core/widgets/language_switch.dart`
- Modify: `app/lib/app.dart` (localizationsDelegates, supportedLocales `en`, `ro`, `locale` from `localeControllerProvider`)
- Test: `app/test/core/errors/error_messages_test.dart`, `app/test/core/locale/locale_controller_test.dart`, `app/test/core/l10n/arb_parity_test.dart`

**Interfaces:**
- Consumes: `ApiError` (Task 3), `sharedPreferencesProvider` (Task 1).
- Produces:
  - `AppLocalizations` (generated; `l10n.yaml`: `arb-dir: lib/core/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`). Import as `package:ana_fit_lab/core/l10n/app_localizations.dart` (set `output-dir: lib/core/l10n`, `synthetic-package: false` if the Flutter version still needs it).
  - `String errorMessage(AppLocalizations l, ApiError e)` and `String fieldErrorMessage(AppLocalizations l, String code)`.
  - `final browserLocaleProvider = Provider<Locale>((_) => PlatformDispatcher.instance.locale)`; `class LocaleController extends Notifier<Locale> { void select(String languageCode); void applyUserLocale(String languageCode); }`; `final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new)`.
  - `String browserTimeZone()` (web: `Intl.DateTimeFormat().resolvedOptions().timeZone` via `dart:js_interop`; stub and any failure → `'UTC'`).
  - `class LanguageSwitch extends ConsumerWidget` – two compact text buttons `EN` / `RO`, the active one in accent.
- ARB keys (English text given; Romanian written with diacritics in `app_ro.arb`):
  - App/common: `appName` "Ana Fit Lab", `emailLabel` "Email", `passwordLabel` "Password", `newPasswordLabel` "New password", `confirmPasswordLabel` "Confirm password", `firstNameLabel` "First name", `lastNameLabel` "Last name", `passwordHint` "10–64 characters", `showPassword` "Show password", `hidePassword` "Hide password", `goToLogin` "Go to login", `goHome` "Go home", `retry` "Retry", `cantReachServer` "Can't reach the server".
  - Login: `loginTitle` "Sign in", `loginButton` "Sign in", `forgotPasswordLink` "Forgot password?", `newCoachPrompt` "New coach?", `createAccountLink` "Create an account", `sessionEndedNotice` "Your session ended. Please sign in again.", `accountSuspendedNotice` "Your account is suspended."
  - Register: `registerTitle` "Create your coach account", `registerButton` "Create account", `haveAccountPrompt` "Already have an account?", `signInLink` "Sign in".
  - Join: `joinTitle(coachName)` "You're joining {coachName}'s coaching", `joinButton` "Create account and join", `joinSignedIn(email)` "You're signed in as {email}", `joinSignOut` "Sign out to create a new account".
  - Verify: `verifyingEmail` "Confirming your email…", `emailConfirmedTitle` "Email confirmed", `emailConfirmedText` "Your account is ready."
  - Forgot/reset: `forgotTitle` "Reset your password", `forgotText` "Enter your email and we'll send you a link.", `forgotButton` "Send reset link", `forgotSent` "If an account exists for that email, we've sent a link to reset the password.", `resetTitle` "Set a new password", `resetButton` "Set new password".
  - Home: `homeGreeting(firstName)` "Hello, {firstName}", `roleCoach` "Coach", `roleClient` "Client", `roleAdmin` "Admin", `signOut` "Sign out", `pendingBanner(email)` "Confirm your email – we sent a link to {email}", `resend` "Resend", `resent` "Sent".
  - Link problems: `linkInviteExpiredTitle` "This invite has expired", `linkInviteExpiredText` "Ask your coach for a new one.", `linkInviteUsedTitle` "This invite was already used", `linkInviteUsedText` "If it was you, sign in.", `linkInviteRevokedTitle` "This invite is no longer valid", `linkInviteRevokedText` "Ask your coach for a new one.", `linkInviteNotFoundTitle` "We couldn't find this invite", `linkInviteNotFoundText` "Check the link and try again.", `linkCoachUnavailableTitle` "Your coach isn't available right now", `linkCoachUnavailableText` "Try again later or contact your coach.", `linkVerifyInvalidTitle` "This confirmation link is invalid or has expired", `linkVerifyAlreadyConfirmed` "Your email is already confirmed.", `linkVerifyResendText` "We can send you a new link.", `linkResetInvalidTitle` "This reset link is invalid or has expired", `linkResetAction` "Request a new link".
  - Errors: `error_UNKNOWN` "Something went wrong. Please try again.", `error_NETWORK` "Can't reach the server. Check your connection.", `error_INTERNAL_ERROR`, `error_INVALID_CREDENTIALS` "Email or password is incorrect.", `error_ACCOUNT_SUSPENDED` "Your account is suspended.", `error_RATE_LIMITED(minutes)` "Too many attempts. Try again in {minutes} min.", `error_EMAIL_TAKEN` "An account with this email already exists.", `error_ALREADY_HAS_COACH`, `error_REQUIRED` "Required", `error_TOO_LONG` "Too long", `error_INVALID_EMAIL` "Enter a valid email", `error_PASSWORD_POLICY` "Use 10–64 characters", `error_PASSWORDS_DONT_MATCH` "Passwords don't match", `error_INVALID_LOCALE`, `error_INVALID_TIMEZONE`, plus `error_<CODE>` for `INVITE_EXPIRED`, `INVITE_USED`, `INVITE_REVOKED`, `INVITE_NOT_FOUND`, `COACH_UNAVAILABLE`, `INVALID_TOKEN` (used when such a code appears outside a link-problem page).

- [x] **Step 1: Write the failing tests:**
  - `error_messages_test`: with `lookupAppLocalizations(Locale('en'))`: `INVALID_CREDENTIALS` → "Email or password is incorrect."; `RATE_LIMITED` with `retryAfter` 61 s → contains "2 min", 10 s → "1 min", null → "1 min"; unknown code `FOO` → `error_UNKNOWN` text; `fieldErrorMessage(l, 'PASSWORD_POLICY')` → "Use 10–64 characters"; with `ro` the `INVALID_CREDENTIALS` text differs from the English one.
  - `locale_controller_test` (prefs via `SharedPreferences.setMockInitialValues`, override `browserLocaleProvider`): saved `ro` + browser `en-US` → `ro`; nothing saved + browser `ro-RO` → `ro`; nothing saved + browser `de-DE` → `en`; `select('ro')` → state `ro` and prefs `locale == 'ro'`; `applyUserLocale('en')` after `select('ro')` → `en` and saved.
  - `arb_parity_test`: decode both ARB files; same set of non-`@` keys; every `error_` key referenced by `errorMessage`'s known-code list exists.
- [x] **Step 2: Run** `flutter test test/core` – Expected: FAIL.
- [x] **Step 3: Implement.** `errorMessage` is a `switch` over `e.code` to the generated getters (default → `error_UNKNOWN`); minutes = `max(1, (retryAfter.inSeconds / 60).ceil())`. Wire `App` to the delegates and locale. Write `app_ro.arb` translations.
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): en/ro localization, error messages, language choice"`

### Task 6: Token storage, cross-tab lock, refresh coordinator

**Files:**
- Create: `app/lib/core/auth/token_store.dart`, `app/lib/core/auth/web_lock.dart` (+ `web_lock_web.dart`, `web_lock_stub.dart`), `app/lib/core/auth/refresh_coordinator.dart`
- Test: `app/test/core/auth/refresh_coordinator_test.dart`, `app/test/core/auth/token_store_test.dart`

**Interfaces:**
- Consumes: `TokenResponse` (Task 2), `ApiError` (Task 3).
- Produces:
  - `class StoredRefreshToken { final String token; final DateTime expiresAt; }`; `abstract interface class TokenStore { Future<StoredRefreshToken?> read(); Future<void> write(String token, DateTime expiresAt); Future<void> clear(); }`; `class SecureTokenStore implements TokenStore` (keys `refresh_token`, `refresh_token_expires_at` ISO-8601 UTC; a missing or unparseable expiry reads as `null`); `class MemoryTokenStore implements TokenStore` (in lib, used by tests and handy for debugging); `final tokenStoreProvider = Provider<TokenStore>((_) => SecureTokenStore())`.
  - `abstract interface class CrossTabLock { Future<T> run<T>(String name, Future<T> Function() action); }`; `CrossTabLock createCrossTabLock()` via conditional import (`if (dart.library.js_interop) 'web_lock_web.dart'`); web: `navigator.locks.request(name, callback)` returning a JS Promise, and if `navigator.locks` is undefined falls back to the in-process lock; stub: in-process mutex (chained futures). `final crossTabLockProvider = Provider<CrossTabLock>((_) => createCrossTabLock())`.
  - `class RefreshCoordinator { RefreshCoordinator({required TokenStore store, required CrossTabLock lock, required Future<TokenResponse> Function(String refreshToken) callRefresh}); Future<TokenResponse> refresh(String usedRefreshToken); }` – throws `ApiError` on failure. Inside the lock: read the store; `null` → throw `ApiError(code: 'INVALID_REFRESH_TOKEN')` (another tab signed out); stored token ≠ `usedRefreshToken` → refresh with the stored one; on success `store.write(new token, expiry)` **before** leaving the lock. Concurrent `refresh` calls while one is in flight return the same `Future`.

- [x] **Step 1: Write the failing tests** (`MemoryTokenStore`, in-process lock, `callRefresh` backed by a counter / `Completer`):
  - `concurrent callers share one refresh`: three `refresh('r1')` calls before completion → `callRefresh` called once, all three get the same `TokenResponse`, store holds `r2`.
  - `second caller after another tab rotated uses the stored token`: store holds `r2` (another tab wrote it), `refresh('r1')` → `callRefresh` called with `r2`, never `r1`.
  - `two coordinators sharing a store and a lock never send the same token twice`: coordinator A and B (simulating two tabs) both call `refresh('r1')` at once → `callRefresh` receives `r1` then `r2`, store ends with `r3`.
  - `failure propagates and the next call retries`: `callRefresh` throws `ApiError('REFRESH_TOKEN_REUSED')` → `refresh` throws it; a later `refresh` invokes `callRefresh` again.
  - `store empty inside the lock` → throws code `INVALID_REFRESH_TOKEN` without calling `callRefresh`.
  - `token_store_test`: `MemoryTokenStore` write/read/clear round-trip (the secure store is covered by the manual E2E).
- [x] **Step 2: Run** `flutter test test/core/auth` – Expected: FAIL.
- [x] **Step 3: Implement.** `web_lock_web.dart`: `@JS('navigator.locks') external JSObject? get _locks;` and `request(name, ((JSAny lock) => action().then(...).toJS).toJS)`; convert the returned promise with `.toDart`. Keep the JS types confined to this file.
- [x] **Step 4: Run** `flutter test && flutter analyze && flutter build web` – Expected: PASS (the build proves the web lock compiles).
- [x] **Step 5: Commit** – `git commit -m "feat(app): refresh token store and single-flight cross-tab refresh"`

### Task 7: Auth controller, auth interceptor, API wiring

**Files:**
- Create: `app/lib/core/auth/session.dart`, `app/lib/core/auth/auth_state.dart`, `app/lib/core/auth/auth_controller.dart`, `app/lib/core/api/api_client.dart`, `app/lib/core/api/auth_interceptor.dart`
- Test: `app/test/core/auth/auth_controller_test.dart`, `app/test/core/api/auth_interceptor_test.dart`

**Interfaces:**
- Consumes: Tasks 2, 3, 5 (`localeControllerProvider`), 6, `nowProvider`.
- Produces:
  - `class Session { final String accessToken; final DateTime accessTokenExpiresAt; final String refreshToken; final DateTime refreshTokenExpiresAt; final UserResponse user; factory Session.from(TokenResponse t); }`
  - `enum SignedOutReason { sessionEnded, suspended }`; `sealed class AuthState`; `final class AuthUnknown extends AuthState { final bool unreachable; }`; `final class SignedOut extends AuthState { final SignedOutReason? reason; }`; `final class SignedIn extends AuthState { final UserResponse user; }`.
  - `class AuthController extends Notifier<AuthState>` with `Session? get session`; `Future<void> start()`; `Future<void> login(String email, String password)`; `Future<void> registerCoach(RegisterCoachRequest r)`; `Future<void> registerClient(RegisterClientRequest r)`; `Future<void> confirmPasswordReset(String token, String newPassword)`; `Future<void> applySession(TokenResponse t)`; `Future<String?> validAccessToken()` (refreshes when expiring within 60 s; `null` when signed out); `Future<String?> refreshAfterUnauthorized(String rejectedAccessToken)` (refreshes unless the current token already differs from the rejected one; `null` → caller signs out); `Future<void> reloadUser()` (`GET /me`); `Future<void> logout({SignedOutReason? reason})`. All API failures surface as `ApiError`. `final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new)`.
  - `final dioProvider = Provider<Dio>(...)` (base URL `apiBaseUrl`, JSON, `AuthInterceptor`); `final apiProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)))`; `final refreshCoordinatorProvider`. Tests override `dioProvider`'s adapter by overriding `httpAdapterProvider = Provider<HttpClientAdapter?>((_) => null)`.
  - `class AuthInterceptor extends Interceptor` – public paths: `/auth/register/`, `/auth/login`, `/auth/refresh`, `/auth/logout` (exact, not `/auth/logout-all`), `/auth/verify-email` (exact, not `/resend`), `/auth/password-reset/`, `/invites/`.

Behaviour (§7): `applySession` keeps the session in memory, writes the refresh token to the store, calls `localeController.applyUserLocale(user.locale)`, sets `SignedIn(user)`. Refresh failures inside `validAccessToken`/`refreshAfterUnauthorized`: `INVALID_REFRESH_TOKEN`/`REFRESH_TOKEN_REUSED` → clear store, `SignedOut(sessionEnded)`; `ACCOUNT_SUSPENDED` → clear, `SignedOut(suspended)`; `NETWORK` → rethrow, session kept. `login` failures leave state unchanged (pages show the error).

- [x] **Step 1: Write the failing tests** (`ProviderContainer` with `MemoryTokenStore`, in-process lock, `FakeApi`, `nowProvider` fixed):
  - `start without a stored token` → `SignedOut(reason: null)`, no request sent.
  - `start with an expired stored token` → `SignedOut`, no request, store cleared.
  - `start with a valid token` → `POST /auth/refresh` with `{refreshToken: r1}` → `SignedIn`, store holds `refresh-1` from the response, locale follows `user.locale`.
  - `start with a rejected token` (401 `INVALID_REFRESH_TOKEN`) → `SignedOut`, store cleared.
  - `start keeps token on network error` → `AuthUnknown(unreachable: true)`, store still holds `r1`; calling `start()` again after the fake recovers → `SignedIn`.
  - `login success` → `SignedIn`, session access token = response's; `login` with 401 → throws `ApiError('INVALID_CREDENTIALS')`, state still `SignedOut`.
  - `logout` → `POST /auth/logout {refreshToken}`, store cleared, `SignedOut`; logout still signs out when that call fails with `NETWORK`.
  - refresh failure mapping: `REFRESH_TOKEN_REUSED` → `SignedOut(sessionEnded)`; `ACCOUNT_SUSPENDED` (403) → `SignedOut(suspended)`; `NETWORK` → throws, still `SignedIn`.
  - `auth_interceptor_test` (signed in via `applySession`, then call the generated client):
    - `getMe` carries `Authorization: Bearer access-1` and `Accept-Language: en` (and `ro` after `select('ro')`).
    - `login`, `previewInvite`, `logout`, `verifyEmail` carry no `Authorization`; `resendVerificationEmail` and `getMe` do.
    - proactive: access token expiring in 30 s → `/auth/refresh` happens before `/me`, and `/me` carries the new token.
    - `401 then retry once`: `/me` returns 401 first, 200 second → one refresh, two `/me` requests, call succeeds.
    - `second 401 signs out`: `/me` returns 401 twice → call fails with `ApiError(status 401)`, state `SignedOut(sessionEnded)`, exactly one refresh.
    - two parallel `getMe` calls that both get 401 → exactly one `/auth/refresh`.
- [x] **Step 2: Run** `flutter test test/core` – Expected: FAIL.
- [x] **Step 3: Implement.** The interceptor reads the controller lazily (`ref.read(authControllerProvider.notifier)` at request time) to avoid a provider cycle; retries use `dio.fetch(options)` with `options.extra['retried'] = true`; errors are converted with `ApiError.fromDio` in `onError` (`handler.reject` keeps the `DioException`, with `error: ApiError`), so callers catch `DioException` → use a helper `Future<T> apiCall<T>(Future<T> Function() f)` in `api_error.dart` that rethrows the `ApiError`. Pages and the controller call the generated client through `apiCall`.
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): auth controller, session refresh and auth interceptor"`

### Task 8: Router, splash and shared widgets

**Files:**
- Create: `app/lib/core/routing/router.dart`, `app/lib/core/routing/splash_page.dart`, `app/lib/core/widgets/{auth_scaffold,app_text_field,primary_button,form_error_banner,link_problem_view}.dart`, placeholder pages `app/lib/features/**/<name>_page.dart` (each a `Text` with its route name, replaced in Tasks 9–13), `app/test/support/test_app.dart`
- Modify: `app/lib/app.dart` (`MaterialApp.router(routerConfig: ref.watch(routerProvider))`), `app/lib/main.dart` (`ref.read(authControllerProvider.notifier).start()` once on launch, e.g. in `App`'s first build via a provider)
- Test: `app/test/core/routing/router_test.dart`, `app/test/core/widgets/link_problem_view_test.dart`

**Interfaces:**
- Consumes: `authControllerProvider`, `AuthState` (Task 7).
- Produces:
  - `final routerProvider = Provider<GoRouter>(...)`; route paths as §6; `String? safeFrom(String? from)` (returns `from` only when it starts with `/`, not `//`, and has no scheme; else `null`).
  - `AuthScaffold({required String title, required Widget child, Widget? header})` – logo "A" in an accent rounded square + `appName`, `LanguageSwitch` top right, card `surface` with `border`, max width 420, 16 px side padding on narrow screens, scrollable.
  - `AppTextField({required String label, TextEditingController? controller, String? hint, String? errorText, bool obscure = false, Iterable<String>? autofillHints, TextInputType? keyboardType, String? Function(String?)? validator, void Function(String)? onSubmitted, TextInputAction? textInputAction})` – show/hide toggle when `obscure`; validator returns a code, displayed via `fieldErrorMessage`.
  - `PrimaryButton({required String label, required VoidCallback? onPressed, bool loading = false})` – full width, spinner and disabled while `loading`.
  - `FormErrorBanner(String message)` – `errorSurface` / `errorBorder` / `errorText`.
  - `LinkProblemView({required IconData icon, required String title, required String text, String? actionLabel, VoidCallback? onAction})` – inside `AuthScaffold`.
  - `Future<void> pumpApp(WidgetTester t, {FakeApi? api, TokenStore? store, String initialLocation = '/', Map<String, Object> prefs = const {}, Locale browserLocale = const Locale('en')})` in `test/support/test_app.dart`; returns after `start()` settles. Sets a 1280×900 surface.

- [x] **Step 1: Write the failing tests** (`router_test`):
  - signed out at `/home` → shows login, location `/login?from=%2Fhome`.
  - signed in at `/login` and `/register` → `/home`.
  - `/` → `/login` signed out, `/home` signed in; unknown `/nope` → `/login` (signed out).
  - while `start()` is pending (refresh `Completer` not completed) → splash (`CircularProgressIndicator`), then the originally requested `/home` once it completes.
  - unreachable start → splash shows `cantReachServer` + `retry`; tapping Retry with the fake recovered → `/home`.
  - `/verify-email?token=x`, `/reset-password?token=x` and `/join/abc` reachable both signed in and signed out (the join page renders its own signed-in variant, §6).
  - language switch: on `/login`, tapping `RO` changes the title from "Sign in" to its Romanian text and back with `EN`.
  - `safeFrom`: `/home` → `/home`; `//evil.com`, `https://evil.com`, `home`, `null` → `null`.
  - `link_problem_view_test`: renders title + text; action button only when `actionLabel` is given; tap calls `onAction`.
- [x] **Step 2: Run** `flutter test test/core/routing test/core/widgets` – Expected: FAIL.
- [x] **Step 3: Implement.** `GoRouter(refreshListenable: …)` with a `ChangeNotifier` that notifies on `authControllerProvider` changes; one `redirect` (§6 guards); `AuthUnknown` → `/loading?to=<encoded location>`, and from `/loading` back to `to` once known.
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): router with auth guards, splash, shared auth widgets"`

### Task 9: Login and home pages

**Files:**
- Modify: `app/lib/features/auth/login/login_page.dart`, `app/lib/features/home/home_page.dart`
- Test: `app/test/features/auth/login_page_test.dart`, `app/test/features/home/home_page_test.dart`

**Interfaces:**
- Consumes: `AuthController.login/logout/reloadUser`, `apiProvider` + `apiCall` (resend), widgets from Task 8, `safeFrom`.
- Produces: `LoginPage({String? from})`, `HomePage()`.

Login: §8 fields/links; `AutofillGroup`; Enter in password submits; client validation (`validateRequired` on both — no format check so any server-side `INVALID_CREDENTIALS` stays the single message); errors in `FormErrorBanner` via `errorMessage`; notice banner when the state is `SignedOut(sessionEnded)` / `SignedOut(suspended)`. On success navigate to `safeFrom(from) ?? '/home'`.
Home: `homeGreeting`, role label, `signOut`; `PENDING` banner with `resend` → `POST /auth/verify-email/resend` → button label `resent` (disabled); `RATE_LIMITED` → `errorMessage` text in the banner.

- [x] **Step 1: Write the failing tests:**
  - login: empty submit → two `error_REQUIRED` texts and no request; `INVALID_CREDENTIALS` → "Email or password is incorrect."; 429 `Retry-After: 900` → "Try again in 15 min."; success → home shows "Hello, Ana"; `from=/home` honoured; `login ignores external from` (`/login?from=//evil.com` → `/home`); after a forced `SignedOut(sessionEnded)` the login page shows `sessionEndedNotice`; button shows a spinner while the request is pending (`Completer`).
  - home: COACH ACTIVE → "Coach", no banner; CLIENT PENDING → banner with the email; tap Resend → `POST /auth/verify-email/resend` with bearer → "Sent"; 429 → rate-limit text; Sign out → `/login` and `POST /auth/logout`.
- [x] **Step 2: Run** `flutter test test/features` – Expected: FAIL.
- [x] **Step 3: Implement** both pages.
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): login and home pages"`

### Task 10: Coach registration page

**Files:**
- Modify: `app/lib/features/auth/register_coach/register_coach_page.dart`
- Create: `app/lib/features/auth/signup_form.dart` (shared first/last name, email, password fields + submit, reused by Task 11)
- Test: `app/test/features/auth/register_coach_page_test.dart`

**Interfaces:**
- Consumes: `AuthController.registerCoach`, `localeControllerProvider`, `browserTimeZone()`.
- Produces: `SignupForm({required String submitLabel, required Future<void> Function(SignupData) onSubmit})` with `class SignupData { final String firstName, lastName, email, password; }`; the form maps an `ApiError`'s `fieldErrors` (and `EMAIL_TAKEN` → `email`) under the fields, everything else to `FormErrorBanner`. Values are trimmed except the password.

- [x] **Step 1: Write the failing tests:**
  - client validation: password `short` → "Use 10–64 characters", no request.
  - request body: `{email: 'ana@example.ro', password, firstName: 'Ana', lastName: 'Pop', locale: 'ro', timezone: <browserTimeZone()>}` when the UI language is RO (fields typed with surrounding spaces arrive trimmed).
  - server 400 `errors: [{field: firstName, code: TOO_LONG}, {field: timezone, code: INVALID_TIMEZONE}]` → "Too long" under first name; the time-zone error (no such field) shows in the banner.
  - 409 `EMAIL_TAKEN` → message under the email field.
  - success with a PENDING user → home with the pending banner.
- [x] **Step 2: Run** – Expected: FAIL.
- [x] **Step 3: Implement.**
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): coach registration page"`

### Task 11: Join (invite) page

**Files:**
- Modify: `app/lib/features/auth/join/join_page.dart`
- Test: `app/test/features/auth/join_page_test.dart`

**Interfaces:**
- Consumes: `apiProvider.previewInvite`, `AuthController.registerClient/logout`, `SignupForm`, `LinkProblemView`.
- Produces: `JoinPage({required String code})`. Route `/join/:code` is reachable while signed in (the page renders the signed-in variant itself).

Behaviour: on open, `GET /invites/{code}` (raw code from the URL). Loading → spinner. 200 → `joinTitle('{first} {last}')` + `SignupForm(submitLabel: joinButton)` → `registerClient` with the same `code`. Preview or signup errors with an invite/coach code → `LinkProblemView` per §6 table (`INVITE_USED` → action `goToLogin`); `RATE_LIMITED`/`NETWORK` → `FormErrorBanner` + `retry`. Signed in → `joinSignedIn(email)` + `joinSignOut` button (logout, stays on `/join/:code` and then shows the preview).

- [x] **Step 1: Write the failing tests:**
  - preview → "You're joining Maria Ionescu's coaching".
  - `join passes the raw code to the API`: `/join/abcde-fghij` → request path `/invites/abcde-fghij`, signup body `code == 'abcde-fghij'`.
  - each of `INVITE_EXPIRED` (410), `INVITE_USED` (410, has "Go to login"), `INVITE_REVOKED` (410), `INVITE_NOT_FOUND` (404), `COACH_UNAVAILABLE` (409) → its title; only `INVITE_USED` has an action.
  - signup returns 410 `INVITE_USED` (invite used meanwhile) → link-problem view replaces the form.
  - signed in → signed-in text; tapping sign out → preview + form.
  - signup body has `locale` = current UI language and `timezone` = `browserTimeZone()`.
  - success → home ("Hello, …", role Client).
- [x] **Step 2: Run** – Expected: FAIL.
- [x] **Step 3: Implement.**
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): invite join page with link-problem states"`

### Task 12: Verify email page

**Files:**
- Modify: `app/lib/features/auth/verify_email/verify_email_page.dart`
- Test: `app/test/features/auth/verify_email_page_test.dart`

**Interfaces:**
- Consumes: `apiProvider.verifyEmail`, `resendVerificationEmail`, `AuthController.reloadUser`.
- Produces: `VerifyEmailPage({required String? token})`.

Behaviour: the verify call is started once per page instance in `initState` (stored `Future`); never from `build`. Missing/empty token → invalid variant without a request. Success → if signed in, `reloadUser()` (state becomes ACTIVE); show `emailConfirmedTitle` + button (`goHome` if signed in, else `goToLogin`). `INVALID_TOKEN` → §6 variant by auth state: signed in + PENDING → `linkVerifyResendText` + `resend`; signed in + ACTIVE → `linkVerifyAlreadyConfirmed` + `goHome`; signed out → `goToLogin`.

- [x] **Step 1: Write the failing tests:** success signed out → "Email confirmed" + "Go to login"; success signed in PENDING → `GET /me` called, then "Go home"; `verify is called once even when auth state changes` (`count('POST', '/auth/verify-email') == 1` after `reloadUser` changes the state and after `pumpAndSettle`); `INVALID_TOKEN` in the three auth variants; resend in the PENDING variant → "Sent"; no token → invalid variant and zero requests.
- [x] **Step 2: Run** – Expected: FAIL.
- [x] **Step 3: Implement.**
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): email verification page"`

### Task 13: Forgot and reset password pages

**Files:**
- Modify: `app/lib/features/auth/password_reset/forgot_password_page.dart`, `app/lib/features/auth/password_reset/reset_password_page.dart`
- Test: `app/test/features/auth/password_reset_test.dart`

**Interfaces:**
- Consumes: `apiProvider.requestPasswordReset`, `AuthController.confirmPasswordReset` (applies the returned session, replacing any current one).
- Produces: `ForgotPasswordPage()`, `ResetPasswordPage({required String? token})`.

- [x] **Step 1: Write the failing tests:**
  - forgot: invalid email → "Enter a valid email", no request; 202 for any email → `forgotSent` text replaces the form; 429 → rate-limit message; link back to login.
  - reset: mismatch → "Passwords don't match", no request; `PASSWORD_POLICY` client-side; 400 `INVALID_TOKEN` → `linkResetInvalidTitle` + "Request a new link" → `/forgot-password`; 403 `ACCOUNT_SUSPENDED` → banner text; success → home of the returned user; success while another user is signed in → home shows the new user's name and the store holds the new refresh token.
  - missing token → invalid variant, no request.
- [x] **Step 2: Run** – Expected: FAIL.
- [x] **Step 3: Implement.**
- [x] **Step 4: Run** `flutter test && flutter analyze` – Expected: PASS.
- [x] **Step 5: Commit** – `git commit -m "feat(app): forgot and reset password pages"`

### Task 14: Docs, full verification, running app for review

**Files:**
- Modify: `CLAUDE.md` (Commands + Stack/dependencies as §13), `docs/plans/frontend-auth.md` (status, done/left), this plan's checkboxes

- [x] **Step 1: Update `CLAUDE.md`:** run web `cd app && flutter run -d web-server --web-port 5173` (optional `--dart-define=API_BASE_URL=…`), regenerate client `cd app && dart run swagger_parser && dart run build_runner build -d`, `flutter test`; note that `app/lib/core/api/generated/` is generated and committed; list the frontend dependencies with one-line reasons (§4).
- [x] **Step 2: Full verification** – `cd app && flutter analyze && flutter test && flutter build web`; `cd backend && ./mvnw test`. Expected: all pass (backend: 203 tests).
- [ ] **Step 3: Manual E2E** (§12) with `docker compose up -d`, backend on the `local` profile, app on 5173, Mailpit at `http://localhost:8025`: coach signup → verify via the Mailpit link → login in a second tab (first stays signed in) → reload keeps the session → create an invite in Swagger UI → join as client in a private window → forgot/reset password → open the used invite link (link-problem page). Record any failure as a fix before continuing.
- [x] **Step 4: Commit** – `git commit -m "docs: frontend commands, dependencies and status"`
- [ ] **Step 5: Hand over** – leave the app running on `http://localhost:5173` and ask the user to review login, coach registration, invitation acceptance and the link-problem page (§1 item 8). Their feedback becomes follow-up commits on this branch.
