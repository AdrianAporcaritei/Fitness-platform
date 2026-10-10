# Slice 1 – Identity, Auth and Coach–Client Linking: Design

**Date:** 2026-10-10
**Status:** design approved section by section; written spec awaiting review
**Scope:** step 1 of `docs/domain-model.md` §11 plus the project foundations every later slice relies on.
**Brainstorm record:** `docs/plans/brainstorm-wip.md`

---

## 1. Goal and success criteria

Give the platform working identity and access control so every later feature can rely on them.

Success means:
- A coach can sign up, verify their email and generate personal invite codes.
- A client can sign up with a code and is immediately linked to that coach. A client with no current coach can link with a new code while logged in.
- Anyone can log in, refresh their session, log out, verify their email and reset their password, on web and mobile through the same API.
- A coach can list, pause, resume and end relationships with their clients; a client can leave their coach.
- One reusable authorization check (`ClientAccessPolicy`) enforces "a client sees only their own data, a coach sees only their current clients, ADMIN sees no client data".
- Everything is covered by Testcontainers integration tests and unit tests.

## 2. Decisions

| # | Topic | Decision |
|---|---|---|
| D1 | Client–coach linking | Personal invite code/link. Client signs up with it; client + `coach_client` (`ACTIVE`) created together. |
| D2 | Spring Boot | Keep **4.1.1** (Jackson 3, Spring Security 7, springdoc 3.x). Update `CLAUDE.md`. |
| D3 | Sessions | Self-issued access JWT (15 min) + opaque rotating refresh token (30 days) with reuse detection. Same API for web and mobile; refresh token in the response body. |
| D4 | Invite codes | Single use, per person, optional label, 7-day expiry, revocable, shown once. |
| D5 | Email | Email verification and password reset included. Mailpit locally, SMTP via config in production. |
| D6 | Coach signup | Fully open; coach is `ACTIVE` once email is verified. |
| D7 | Implementation | Own auth endpoints + `NimbusJwtEncoder` for signing + Spring `oauth2ResourceServer().jwt()` for validation + `ClientAccessPolicy` for data access. |
| D8 | First ADMIN | Created at startup from `ADMIN_EMAIL` / `ADMIN_PASSWORD` if no ADMIN exists. |
| D9 | `INVITED` status | Removed from `coach_client.status`. |
| D10 | `PAUSED` | Relationship still counts as the one current coach; coach keeps **read-only** access, cannot assign new things; chat stays open. |
| D11 | Ending a relationship | Coach or client can end it; only the coach can pause/resume. |
| D12 | Duplicate signup email | `409 EMAIL_TAKEN` (account enumeration accepted, mitigated by rate limits). |
| D13 | JWT signing | HS256 with a 256-bit secret from env; RS256 only if other services ever verify tokens. |
| D14 | Unverified clients | No restrictions (banner only). Unverified coaches cannot create invites. |
| D15 | Emails | Plain text from `MessageSource`; no template engine yet. |

## 3. Out of scope

`client_profile` and onboarding (slice 2), ADMIN endpoints including suspend/reactivate (set `SUSPENDED` in the DB until the admin slice), account deletion flow (§8.2, slice 4), `audit_log` (slice 2), `notification` table, HTML emails, MinIO, the Flutter app itself.

## 4. Data model

All tables follow the domain-model conventions: `uuid` PKs, `created_at` / `updated_at` `timestamptz`, enums as `varchar` + `CHECK`.

### 4.1 `app_user` (existing in the model)
- `email` stored lowercase: `CHECK (email = lower(email))`, unique index.
- `role` CHECK `('COACH','CLIENT','ADMIN')`.
- `status` CHECK `('PENDING','ACTIVE','SUSPENDED')`:
  - `PENDING` – email not verified; can log in (see §5.4 for restrictions).
  - `ACTIVE` – email verified.
  - `SUSPENDED` – cannot log in or refresh; refresh tokens revoked.
- `locale` CHECK `('ro','en')`, `timezone` (IANA name, validated in the service). Both set at signup.
- `email_verified_at`, `last_login_at` nullable.

### 4.2 `coach_profile` (existing)
Created automatically at coach signup with empty `bio` and empty `specializations`. No change.

### 4.3 `coach_client` (changed)
- `status` CHECK `('ACTIVE','PAUSED','ENDED')` – **`INVITED` removed**.
- Partial unique index `ON coach_client (client_id) WHERE status IN ('ACTIVE','PAUSED')`.
- Index on `coach_id`.
- `invited_at` = creation time of the invite that was used; `started_at` set on linking; `ended_at` set on ending.
- Transitions: `ACTIVE ↔ PAUSED`, `ACTIVE | PAUSED → ENDED`. `ENDED` is final. Other transitions → `409 INVALID_RELATIONSHIP_TRANSITION`.

### 4.4 `coach_invite` (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| code_hash | varchar, unique | SHA-256 of the normalized code |
| label | varchar(100), null | e.g. "Maria P." |
| status | varchar | `PENDING`, `USED`, `REVOKED` |
| expires_at | timestamptz | creation + 7 days |
| used_at | timestamptz, null | |
| used_by_client_id | uuid, null FK → app_user | `ON DELETE SET NULL` |

- Code: 10 characters from Crockford base32 (no `I`, `L`, `O`, `U`), ~50 bits, displayed as `XXXXX-XXXXX`. Normalized (uppercase, dashes and spaces removed) before hashing.
- Link: `{APP_BASE_URL}/join/{code}`.
- Plaintext code returned only in the create response; never stored.
- Expiry is derived from `expires_at`. APIs report `EXPIRED` for a `PENDING` invite past its expiry; it is not stored.

### 4.5 `refresh_token` (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK → app_user | `ON DELETE CASCADE` |
| token_hash | varchar, unique | SHA-256 |
| family_id | uuid | one family per login; indexed |
| expires_at | timestamptz | issue + 30 days; each rotation issues a fresh 30 days (sliding session) |
| revoked_at | timestamptz, null | |
| replaced_by_id | uuid, null FK → refresh_token | |

### 4.6 `user_action_token` (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK → app_user | `ON DELETE CASCADE` |
| purpose | varchar | `EMAIL_VERIFICATION` (48 h), `PASSWORD_RESET` (1 h) |
| token_hash | varchar, unique | SHA-256 |
| expires_at | timestamptz | |
| used_at | timestamptz, null | |

Issuing a token for a purpose marks the user's earlier unused tokens for that purpose as used.

Refresh tokens and action tokens are 32 random bytes from `SecureRandom`, base64url-encoded.

### 4.7 Migrations
- `V1__identity.sql` – `app_user`, `coach_profile`, `coach_client`.
- `V2__auth_tokens_and_invites.sql` – `coach_invite`, `refresh_token`, `user_action_token`.

Account deletion (§8.2) remains possible: new tables cascade with `app_user` or null their reference.

## 5. Auth flows

### 5.1 Token response
Login, signup, refresh and password-reset confirm return:
```json
{
  "accessToken": "...", "accessTokenExpiresAt": "...",
  "refreshToken": "...", "refreshTokenExpiresAt": "...",
  "user": { "id": "...", "email": "...", "role": "COACH", "status": "PENDING",
            "firstName": "...", "lastName": "...", "locale": "ro", "timezone": "Europe/Bucharest" }
}
```
Access token claims: `sub` (user id), `role`, `jti`, `iat`, `exp`. HS256. Status is not in the token; status-dependent checks read the DB.

### 5.2 Coach signup – `POST /auth/register/coach`
Body: email, password, firstName, lastName, locale, timezone.
Creates COACH `PENDING` + `coach_profile`, issues an `EMAIL_VERIFICATION` token, sends the email after commit, returns tokens.
Errors: `409 EMAIL_TAKEN`, `400 VALIDATION_FAILED`.

### 5.3 Client signup – `GET /invites/{code}` then `POST /auth/register/client`
- `GET /invites/{code}` (public) → `{ coachFirstName, coachLastName, valid: true }`, or `404 INVITE_NOT_FOUND` / `410 INVITE_EXPIRED` / `410 INVITE_USED` / `410 INVITE_REVOKED`.
- `POST /auth/register/client` body: code + the coach-signup fields. One transaction:
  1. Find the invite by hash with `SELECT … FOR UPDATE`; check `PENDING` and not expired.
  2. Create CLIENT `PENDING`.
  3. Create `coach_client` `ACTIVE` (`invited_at` = invite creation, `started_at` = now).
  4. Mark the invite `USED`, set `used_at`, `used_by_client_id`.
  5. Issue verification token; after commit send email; return tokens.
- `client_profile` is not created here.

### 5.4 Linking a client without a coach – `POST /me/coach-link {code}`
CLIENT only. Same steps 1, 3 and 4 inside one transaction. If the client already has an `ACTIVE`/`PAUSED` relationship → `409 ALREADY_HAS_COACH` (also the outcome when the partial unique index rejects a concurrent link).

**Unverified-user restrictions:** a `PENDING` coach gets `403 EMAIL_NOT_VERIFIED` on `POST /coach/invites`. A `PENDING` client has no restrictions.

### 5.5 Login – `POST /auth/login`
- Unknown email or wrong password → `401 INVALID_CREDENTIALS`. When the email is unknown, a dummy BCrypt check still runs so timing does not reveal account existence.
- `SUSPENDED` → `403 ACCOUNT_SUSPENDED`.
- Success: new refresh-token family, `last_login_at` updated, tokens returned.

### 5.6 Refresh – `POST /auth/refresh {refreshToken}`
- Valid, unrevoked, unexpired → mark it revoked, create a new token in the same family with `replaced_by_id` linking, return tokens.
- Token already revoked **and** has `replaced_by_id` (reuse) → revoke the entire family, `401 REFRESH_TOKEN_REUSED`.
- Unknown, expired or revoked → `401 INVALID_REFRESH_TOKEN`.
- User `SUSPENDED` → revoke family, `403 ACCOUNT_SUSPENDED`.
- The Flutter client keeps at most one refresh request in flight.

### 5.7 Logout
- `POST /auth/logout {refreshToken}` → revokes that token's family. `204`, also when the token is unknown.
- `POST /auth/logout-all` (authenticated) → revokes all the user's families. `204`.
- Access tokens stay valid until they expire (≤15 min).

### 5.8 Email verification
- Email contains `{APP_BASE_URL}/verify-email?token=…`. The app calls `POST /auth/verify-email {token}` → status `ACTIVE`, `email_verified_at` = now, token used. `204`. Invalid/expired → `400 INVALID_TOKEN`.
- Verifying a `SUSPENDED` user sets `email_verified_at` but leaves the status `SUSPENDED`.
- `POST /auth/verify-email/resend` (authenticated, `PENDING` only) → new token and email. `204`.

### 5.9 Password reset and change
- `POST /auth/password-reset/request {email}` → always `202`. If the user exists and is not `SUSPENDED`, issue `PASSWORD_RESET` and email `{APP_BASE_URL}/reset-password?token=…`.
- `POST /auth/password-reset/confirm {token, newPassword}` → set password, revoke all refresh tokens, mark token used; if the user was `PENDING`, set `ACTIVE` and `email_verified_at`. Returns tokens (new family). Invalid/expired → `400 INVALID_TOKEN`.
- `POST /me/password {currentPassword, newPassword}` → wrong current → `400 INVALID_CURRENT_PASSWORD`. On success revoke all families except the current one (the request carries `refreshToken` to identify it). `204`.

### 5.10 Password policy
10–64 characters, any characters, no composition rules. BCrypt via Spring's `DelegatingPasswordEncoder` (BCrypt's 72-byte input limit drives the 64-character maximum).

### 5.11 Rate limiting
In-memory fixed-window counters (single instance; no new dependency). Defaults, configurable:

| Action | Limit |
|---|---|
| Login failures | 5 per email per 15 min; 20 per IP per 15 min |
| Signup (coach and client) | 10 per IP per hour |
| Password reset request | 3 per email per hour; 10 per IP per hour |
| Verification resend | 3 per user per hour |
| Invite lookup and coach-link | 20 per IP per 15 min |

Exceeded → `429 RATE_LIMITED` with `Retry-After`.

### 5.12 First ADMIN
An `ApplicationRunner` checks for an ADMIN. If none exists and `ADMIN_EMAIL` and `ADMIN_PASSWORD` are set, it creates one (`ACTIVE`, verified). If none exists and they are not set, it logs a warning and continues.

### 5.13 Email delivery
Emails are published as events and sent by an `@TransactionalEventListener(phase = AFTER_COMMIT)` + `@Async` handler through a `MailSender` interface (SMTP implementation; test fake). Language = user's `locale`. Failures are logged; the request never fails because of email.

## 6. API and authorization

### 6.1 Conventions
- Base path `/api/v1`.
- `docs/api/openapi.yaml` is hand-written and is the contract; it is updated before each endpoint is implemented. springdoc 3.x serves Swagger UI for that file only.
- Errors: RFC 9457 `ProblemDetail` with extra properties `code` (stable, machine-readable) and, for validation, `errors: [{ field, code }]`. `detail` is localized from the user's `locale`, or `Accept-Language` when unauthenticated. Clients rely on `code`.
- Request DTOs validated with Bean Validation (`spring-boot-starter-validation`). Controllers use DTOs only.

### 6.2 Endpoints
| Endpoint | Who | Purpose |
|---|---|---|
| `POST /auth/register/coach` | public | §5.2 |
| `POST /auth/register/client` | public | §5.3 |
| `POST /auth/login` | public | §5.5 |
| `POST /auth/refresh` | public | §5.6 |
| `POST /auth/logout` | public | §5.7 |
| `POST /auth/logout-all` | authenticated | §5.7 |
| `POST /auth/verify-email` | public | §5.8 |
| `POST /auth/verify-email/resend` | authenticated | §5.8 |
| `POST /auth/password-reset/request` | public | §5.9 |
| `POST /auth/password-reset/confirm` | public | §5.9 |
| `GET /invites/{code}` | public | §5.3 |
| `GET`, `PATCH /me` | authenticated | own names, locale, timezone (email change out of scope) |
| `POST /me/password` | authenticated | §5.9 |
| `POST /me/coach-link` | CLIENT | §5.4 |
| `GET /me/coach` | CLIENT | current coach (names, bio, specializations, relationship status) or `404 NO_COACH` |
| `DELETE /me/coach` | CLIENT | end current relationship → `ENDED`. `204` |
| `GET`, `PATCH /coach/profile` | COACH | bio, specializations |
| `POST /coach/invites` | COACH, verified | `{label?}` → invite incl. plaintext `code` and `link`, returned once |
| `GET /coach/invites` | COACH | own invites with derived status (`PENDING`/`USED`/`REVOKED`/`EXPIRED`), newest first |
| `POST /coach/invites/{id}/revoke` | COACH | `PENDING` → `REVOKED`; otherwise `409 INVITE_NOT_REVOCABLE` |
| `GET /coach/clients` | COACH | current clients (`ACTIVE` + `PAUSED`): id, names, email, status, startedAt |
| `PATCH /coach/clients/{clientId}/relationship` | COACH | `{status: PAUSED | ACTIVE | ENDED}` on the current relationship (§4.3) |

### 6.3 Authorization
1. **URL rules** (`SecurityFilterChain`): `/auth/*` public except `logout-all` and `verify-email/resend`; `GET /invites/*` public; `/me/**` authenticated; `/coach/**` role COACH; `/admin/**` role ADMIN (reserved). Stateless, CSRF off (no cookies), CORS from `CORS_ALLOWED_ORIGINS`.
2. **Data rules** (services) via `ClientAccessPolicy`:
   - `requireReadAccess(clientId)` – passes for the client themselves, or a coach with an `ACTIVE` or `PAUSED` relationship to that client.
   - `requireWriteAccess(clientId)` – passes for the client themselves, or a coach with an `ACTIVE` relationship.
   - ADMIN never passes. A coach with only `ENDED` relationships never passes.
   - Failure → `404` (not `403`) so client existence is not revealed.
   - Not used by slice 1 endpoints beyond `/coach/clients/{clientId}/relationship`, but built and fully tested here for later slices.
3. The current user comes from `CurrentUser`, built from the JWT `sub`, never from request parameters.

## 7. Infrastructure and configuration

- `docker-compose.yml`: PostgreSQL 17 and Mailpit (UI on `localhost:8025`), pinned image versions. MinIO added in slice 2.
- `application.properties` holds shared settings and reads secrets from the environment with **no defaults**. `application-local.properties` holds dev defaults (local DB, Mailpit, a dev JWT secret, a dev ADMIN). Local run becomes `./mvnw spring-boot:run -Dspring-boot.run.profiles=local`; the command in `CLAUDE.md` is updated. Tests set their own values.
- Production settings from environment: `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET` (startup fails if missing or shorter than 256 bits), `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_FROM`, `APP_BASE_URL`, `CORS_ALLOWED_ORIGINS`.
- A `java.time.Clock` bean is injected wherever time matters.
- Localization: `messages.properties` (en) and `messages_ro.properties` hold error `detail` texts and email subjects/bodies.

### 7.1 New dependencies
| Dependency | Why |
|---|---|
| `spring-boot-starter-validation` | Bean Validation on request DTOs |
| `spring-boot-starter-mail` | Sending verification and reset emails |
| `springdoc-openapi` 3.x (webmvc UI) | Swagger UI for the hand-written contract; already listed in `CLAUDE.md` |

### 7.2 Packages
- `auth` – users, signup, login, tokens, verification, reset, rate limiting, ADMIN bootstrap.
- `client` – `coach_client`, invites, coach profile, `ClientAccessPolicy`.
- `common` – error format, security configuration, `MailSender`, `CurrentUser`.

## 8. Testing

**Integration tests** (Testcontainers PostgreSQL via the existing `TestcontainersConfiguration`, MockMvc, a recording fake `MailSender`, a controllable `Clock`):
- Coach signup → verify → create invite; client signup with that code; client linking with `/me/coach-link`.
- Two concurrent signups with the same code: exactly one succeeds, the other gets `410 INVITE_USED`.
- Expired, revoked and used invites rejected; unverified coach cannot create invites.
- Refresh rotation; reuse of a rotated token revokes the family; logout and logout-all.
- Login: wrong credentials, suspended user, `last_login_at` updated.
- Verification and reset tokens: success, expiry, single use, newer token invalidates older; reset revokes sessions and verifies a `PENDING` user.
- Access matrix: other coach's client → 404; ADMIN on client data → 404; coach of a `PAUSED` client can read but not write; `ENDED` coach has no access; client cannot link to a second coach.
- Relationship transitions, including invalid ones; client leaving a coach.
- DB constraints: duplicate email (case-insensitive) rejected; partial unique index on `coach_client`.
- Rate limiting returns `429` with `Retry-After`.
- Error responses follow the `ProblemDetail` format with the right `code` and localized `detail` in `ro` and `en`.

**Unit tests:** invite code generation and normalization, token hashing, password policy, rate limiter windows, `ClientAccessPolicy` decisions, relationship transition rules.

## 9. Documentation updates in this slice

- `docs/domain-model.md` → **v0.5**: tables from §4, `INVITED` removed, `PAUSED` semantics (D10), ending rules (D11), new decisions added to §9, open question §10 #3 (ADMIN) partly answered for this slice.
- `CLAUDE.md`: Spring Boot 4, the new dependencies and why, Mailpit in local infra.
- `docs/api/openapi.yaml`: created; each endpoint is added before it is implemented.
