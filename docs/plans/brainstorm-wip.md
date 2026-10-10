# Brainstorm WIP – Slice 1: Identity, Auth, Coach–Client Linking

**Status:** paused (2026-10-08) during the design-presentation phase.
**Process:** superpowers `brainstorming` skill, **architectural** path → design sections → written spec (`docs/superpowers/specs/…`) → user review → `writing-plans`. No code until spec and plan are approved.
**Scope:** step 1 of `docs/domain-model.md` §11 – `app_user` (COACH/CLIENT/ADMIN), `coach_profile`, `coach_client`, JWT auth, ro/en localization – plus project foundations.

---

## 1. Repo state found at start

- `backend/` is a bare Spring Initializr skeleton (no domain code). pom already has: webmvc, security, oauth2-resource-server, data-jpa, flyway (+ postgresql), websocket, actuator, Testcontainers.
- **Spring Boot 4.1.1** in pom, while `CLAUDE.md` says Spring Boot 3.
- Missing: `docs/api/openapi.yaml`, `docker-compose.yml`, springdoc dependency, `app/` (Flutter).

## 2. Decisions taken

| # | Topic | Decision |
|---|---|---|
| D1 | How a client links to a coach | **Invite code/link (option B).** Coach generates a code; client signs up with it; client account + `coach_client` (ACTIVE) created together. No email needed for inviting. |
| D2 | Spring Boot version | **Keep Boot 4.1.1**; update `CLAUDE.md` as part of this slice. Implications: Jackson 3 (`tools.jackson`), Spring Security 7, springdoc 3.x. |
| D3 | Token strategy | **Self-issued short-lived access JWT (~15 min) + opaque rotating refresh token** (stored hashed in a `refresh_token` table, reuse of a rotated token revokes the whole family). Same token API for web and mobile; refresh token in the response body. New table approved in principle. |
| D4 | Invite code semantics | **Personal, single-use code per client (option A)**: optional label, expiry (7 days), coach can revoke, coach sees pending/used invites. New table `coach_invite`. |
| D5 | Email in this slice | **Include email verification and password reset (option A).** Mailpit in `docker-compose.yml` locally, real SMTP in prod via config only. Small `MailSender` behind an interface, ro/en templates. Adds `spring-boot-starter-mail`. Unverified users can log in but some actions are restricted (to be defined in the auth-flows section). |
| D6 | Coach signup | **Fully open (option B):** coach becomes `ACTIVE` once email is verified. No admin approval. |
| D7 | Implementation approach | **Approach A:** own `AuthController`/`AuthService` for business flows; tokens signed with `NimbusJwtEncoder`; requests validated by Spring's `oauth2ResourceServer().jwt()` (reusable later for the WebSocket handshake); coach–client authorization centralized in a reusable `ClientAccessPolicy` service (e.g. `requireCoachOf(clientId)`). Rejected: Spring Authorization Server (too heavy, poor fit for invite signup), hand-rolled JWT filter (new dep, reimplements library code). |

## 3. Assumptions not yet explicitly confirmed

- **A1.** A logged-in client **with no current coach** can enter a new coach's invite code to link (no second account needed). Proposed; user answered only the main question.
- **A2.** First ADMIN is **bootstrapped at application startup from env settings** (email + initial password), only if no ADMIN exists. Not via Flyway (keeps the password out of git). Proposed; not explicitly confirmed.
- **A3.** Slice also creates foundations: `docker-compose.yml` (PostgreSQL, Mailpit; MinIO can come with slice 2), first Flyway migrations, first `openapi.yaml`, a single standard error-response format. ADMIN features beyond login are out of scope.

## 4. Design section 1 – Data model (APPROVED 2026-10-10, incl. removal of `INVITED`)

This is also the proposed change to `docs/domain-model.md` (must be approved and the doc updated before implementation, per `CLAUDE.md`).

**`app_user`** (existing; clarified rules)
- `email` stored lowercase, unique index.
- `status`: `PENDING` = email not verified (can log in, some actions blocked); `ACTIVE` = verified; `SUSPENDED` = cannot log in, refresh tokens revoked.
- `locale` and `timezone` set at signup (app language, device timezone).

**`coach_profile`** – created automatically at coach signup (empty `bio`). No table change.

**`coach_client`** – **proposed change:** remove `INVITED` from the status CHECK (unused with invite codes). Partial unique index becomes `WHERE status IN ('ACTIVE','PAUSED')`.

**`coach_invite`** (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| code_hash | varchar, unique | SHA-256 of the code; plaintext never stored |
| label | varchar, null | e.g. "Maria P." |
| status | varchar | `PENDING`, `USED`, `REVOKED` |
| expires_at | timestamptz | created + 7 days |
| used_at | timestamptz, null | |
| used_by_client_id | uuid, null FK → app_user | `ON DELETE SET NULL` |

- Code ≈ 10 chars from an unambiguous alphabet (e.g. `K7Q2-M9XD`), shown to the coach **once** with a link; if lost, revoke and generate a new one.
- Expiry is derived from `expires_at` (no stored EXPIRED status, no job).

**`refresh_token`** (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK → app_user | `ON DELETE CASCADE` |
| token_hash | varchar, unique | |
| family_id | uuid | chain from one login |
| expires_at | timestamptz | 30 days |
| revoked_at | timestamptz, null | |
| replaced_by_id | uuid, null | token that replaced it on rotation |

Reuse of an already-replaced token revokes the entire `family_id`.

**`user_action_token`** (new)
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK → app_user | `ON DELETE CASCADE` |
| purpose | varchar | `EMAIL_VERIFICATION` (48 h), `PASSWORD_RESET` (1 h) |
| token_hash | varchar, unique | |
| expires_at, used_at | timestamptz | |

A new token for the same purpose invalidates previous ones.

**Migrations:** `V1__identity.sql` (`app_user`, `coach_profile`, `coach_client`), `V2__auth_tokens_and_invites.sql`.
**Account deletion (§8.2):** new tables cascade or set null with `app_user`.

## 4b. Design section 2 – Auth flows (APPROVED 2026-10-10)

1. **Coach signup** `POST /auth/register/coach` (email, password, names, locale, timezone) → COACH `PENDING` + `coach_profile` + verification email; tokens returned immediately.
2. **Client signup** `GET /invites/{code}` (preview: coach name, valid?) → `POST /auth/register/client` (code + same fields). One transaction: lock invite row, check `PENDING` and not expired, create CLIENT `PENDING`, `coach_client` `ACTIVE`, invite `USED`; then verification email + tokens. `client_profile` is NOT created here (slice 2 onboarding).
3. **Link existing client without coach (A1, confirmed)** `POST /me/coach-link {code}`; same transaction; unique index resolves races.
4. **PENDING restrictions:** coach cannot create invites until verified; client has no restrictions (banner only).
5. **Login** `POST /auth/login` → access + refresh, updates `last_login_at`. Wrong credentials → `401 INVALID_CREDENTIALS` (hash computed even if email unknown). `SUSPENDED` → `403 ACCOUNT_SUSPENDED`.
6. **Tokens:** access 15 min, claims `sub`, `role`, `jti`; **HS256** with 256-bit secret from env (RS256 only if other services ever verify). Status not in token; status checks hit the DB. Suspension takes effect within ≤15 min.
7. **Refresh** `POST /auth/refresh` rotates; reuse of a replaced token revokes the family. Flutter keeps a single refresh in flight.
8. **Logout** `POST /auth/logout` (current family), `POST /auth/logout-all` (all families).
9. **Email verification** link → app → `POST /auth/verify-email {token}` → `ACTIVE`, `email_verified_at`. `POST /auth/verify-email/resend` (rate-limited).
10. **Password reset** `POST /auth/password-reset/request` always `202`; `POST /auth/password-reset/confirm` sets password, revokes all refresh tokens, and verifies a `PENDING` email. **Change password** `POST /me/password` (current + new), revokes other families.
11. **Passwords:** 10–64 chars, no composition rules; BCrypt (Spring default; 72-byte limit drives the max).
12. **Rate limiting:** in-memory per IP + per email on login, signup, reset request, verification resend, invite lookup. No new dependency (single instance).
13. **First ADMIN (A2, confirmed):** startup runner creates it from `ADMIN_EMAIL` / `ADMIN_PASSWORD` if none exists; `ACTIVE`, verified.
14. **Emails:** sent after commit, async, in the user's locale; failures logged, never fail the request.
15. **Accepted trade-offs:** duplicate signup email → `409 EMAIL_TAKEN` (account enumeration accepted, mitigated by rate limit); HS256; no restrictions on PENDING clients.

## 4c. Design section 3 – API & authorization (APPROVED 2026-10-10)

**Conventions:** base path `/api/v1`. Hand-written `docs/api/openapi.yaml` is the contract (Flutter client generated from it); springdoc 3.x only serves Swagger UI for that file. Errors = RFC 9457 `ProblemDetail` + stable `code` + `errors[]` (`field`, `code`) for validation; `detail` localized (user `locale`, or `Accept-Language` before login); Flutter relies on `code`. **New dependency approved: `spring-boot-starter-validation`** (`@Valid` on request DTOs).

**Endpoints** (besides `/auth/*` from section 2):
| Endpoint | Who | Purpose |
|---|---|---|
| `GET /invites/{code}` | public | validate code before signup |
| `GET`, `PATCH /me` | authenticated | own account (names, locale, timezone) |
| `POST /me/password` | authenticated | change password |
| `POST /me/coach-link` | CLIENT | link to coach with code |
| `GET /me/coach` | CLIENT | current coach (name, bio) |
| `DELETE /me/coach` | CLIENT | leave coach → `ENDED` |
| `GET`, `PATCH /coach/profile` | COACH | bio, specializations |
| `POST /coach/invites` | COACH, verified | generate code (returned once) |
| `GET /coach/invites` | COACH | own invites (pending/used/revoked/expired) |
| `POST /coach/invites/{id}/revoke` | COACH | revoke pending invite |
| `GET /coach/clients` | COACH | current clients (`ACTIVE` + `PAUSED`), name + email |
| `PATCH /coach/clients/{clientId}/relationship` | COACH | `PAUSED` / `ACTIVE` / `ENDED` |

No ADMIN endpoints in this slice (A3); `SUSPENDED` set directly in DB until the admin slice.

**Authorization, two layers:**
1. URL rules in `SecurityFilterChain`: `/coach/**` COACH, `/me/**` authenticated, `/admin/**` ADMIN (reserved), public `/auth/*` and `GET /invites/{code}`.
2. Data rules in services via `ClientAccessPolicy`: passes for the client themselves or a coach with a current `coach_client`; **ADMIN never passes**; no access → **404** (not 403). Current user from a `CurrentUser` built from the JWT, never from request params. Needs read vs. write variants because of `PAUSED` (below).

**Decisions in this section:**
- **`PAUSED` semantics:** relationship stays and still counts as "the one current coach"; coach keeps **read-only** access to client data, cannot assign new things; chat stays open. → domain-model change to document.
- **Ending a relationship:** both sides can end it (coach from client list, client via "leave coach"); only the coach can pause/resume.

## 5. Open questions

1. ~~Approve data-model section 1~~ – approved 2026-10-10.
2. Assumptions A1 and A2 confirmed with section 2 (2026-10-10). A3 confirmed with section 3 (no ADMIN endpoints in this slice).
3. To be settled in later sections (I will propose defaults): what `PENDING` (unverified) users cannot do; password policy; login rate limiting / lockout; how a coach–client relationship ends (needed for A1); JWT signing key management (symmetric vs. asymmetric, rotation).
4. Pre-existing open questions in `domain-model.md` §10 that touch this slice: #2 coach account deletion, #3 exact ADMIN capabilities.

## 6. Where we left off / next steps

**Design complete** (section 4 approved 2026-10-10: plain-text emails, no Mailpit in tests). Full spec: `docs/superpowers/specs/2026-10-10-slice1-identity-auth-design.md`.

**Resume at:** user review of the written spec, then `writing-plans`.

Remaining design sections:
2. **Auth flows** – coach signup, client signup with invite code, login, refresh/rotation, logout, email verification, password reset, what PENDING users can't do, ADMIN bootstrap.
3. **API & authorization** – endpoint list for `openapi.yaml`, error format, `ClientAccessPolicy`, role rules (ADMIN sees no client data), invite management endpoints, ending a relationship.
4. **Infrastructure & testing** – `docker-compose.yml` (PostgreSQL, Mailpit), config/secrets, localization of emails/errors, Testcontainers integration tests, unit tests.

Then: write spec to `docs/superpowers/specs/YYYY-MM-DD-slice1-identity-auth-design.md` → self-review → user review → update `domain-model.md` and `CLAUDE.md` → `writing-plans`.
