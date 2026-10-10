# Slice 1 – Identity, Auth and Coach–Client Linking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Working signup (coach, client-by-invite), login, sessions, email verification, password reset, coach–client relationship management and a reusable client-data access check, all covered by Testcontainers tests.

**Architecture:** Package-by-feature Spring Boot 4 app (`auth`, `client`, `common` under `com.anafitlab.backend`). Own auth endpoints issue HS256 access JWTs via `NimbusJwtEncoder`; Spring's `oauth2ResourceServer().jwt()` validates them. Opaque refresh and action tokens are stored only as SHA-256 hashes. Controllers → services → repositories, DTOs at the controller boundary, RFC 9457 errors with a stable `code`.

**Tech Stack:** Java 21, Spring Boot 4.1.1 (Spring Security 7, Jackson 3 `tools.jackson.*`, Hibernate 7), PostgreSQL 17, Flyway, Testcontainers 2, MockMvc, Mailpit (local only).

**Spec:** `docs/superpowers/specs/2026-10-10-slice1-identity-auth-design.md` (section numbers below like "§5.6" refer to it). Project rules: `CLAUDE.md`. Domain model: `docs/domain-model.md`.

## Global Constraints

- Spring Boot **4.1.1**, Java **21**. No downgrade.
- Only new dependencies allowed: `spring-boot-starter-validation`, `spring-boot-starter-mail`, `springdoc-openapi-starter-webmvc-ui` **3.x** (pin the exact latest 3.x version compatible with Boot 4.1 from Maven Central). Anything else: stop and ask.
- All API paths are prefixed `/api/v1` (added centrally in Task 1; controllers map relative paths like `/auth/login`).
- `docs/api/openapi.yaml` is updated **before** each endpoint is implemented (first step of every endpoint task).
- Schema only via Flyway `V<n>__description.sql`; `spring.jpa.hibernate.ddl-auto=validate`; never edit an applied migration.
- IDs `uuid`; times `timestamptz` UTC; enums `varchar` + `CHECK`; table `app_user`.
- Entities reference other aggregates by `UUID` fields (no `@ManyToOne` across packages). `created_at`/`updated_at` via Hibernate `@CreationTimestamp`/`@UpdateTimestamp`; every business time (expiry, used, started, ended, verified, last login) comes from the injected `java.time.Clock`.
- Controllers use DTOs (Java records) only, never entities. No business logic in controllers.
- Fixed values: access token **15 min**; refresh token **30 days**, fresh 30 days on each rotation; invite expiry **7 days**; `EMAIL_VERIFICATION` **48 h**; `PASSWORD_RESET` **1 h**; password **10–64 characters** and ≤72 UTF-8 bytes; invite code **10 Crockford base32 chars**, displayed `XXXXX-XXXXX`; random tokens **32 bytes** `SecureRandom`, base64url without padding; hashes SHA-256 lowercase hex.
- Rate limits (§5.11, configurable under `app.rate-limit.*`): login failures 5/email/15 min and 20/IP/15 min; signup 10/IP/h; reset request 3/email/h and 10/IP/h; verification resend 3/user/h; invite lookup + coach-link 20/IP/15 min.
- Validation field codes are carried in the constraint's `message` attribute (e.g. `@NotBlank(message = "REQUIRED")`) and returned verbatim in `errors[].code`.
- Error `detail` texts and emails exist in both `messages.properties` (en) and `messages_ro.properties` (ro); every new error `code` gets a key `error.<CODE>` in both files.
- Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Prerequisite:** Docker must be reachable from WSL (Testcontainers). At planning time `docker` was not found in this WSL distro – enable Docker Desktop WSL integration before Task 1.

## Review Focus

1. **Passwords with multi-byte characters** (e.g. 40 emoji = 40 "characters" but 160 UTF-8 bytes) must get `400` with field code `PASSWORD_POLICY`, not a 500 from BCrypt's 72-byte limit. → test in Task 7.
2. **Email with different case or surrounding spaces** (`" Ana@Example.RO "`) must sign up as `ana@example.ro`, be found at login when typed `ANA@example.ro`, and collide with an existing `ana@example.ro` as `409 EMAIL_TAKEN`. → test in Task 7.
3. **Invite code typed loosely** – lowercase, spaces, missing or extra dashes, `O`/`o` for `0`, `I`/`i`/`L`/`l` for `1` – must resolve to the same invite. → unit test in Task 4, integration test in Task 11.
4. **Invalid locale or timezone** (`"fr"`, `"Mars/Olympus"`) must be a `400` field error (`INVALID_LOCALE` / `INVALID_TIMEZONE`), not a 500 from the DB `CHECK` or `ZoneId`. → test in Task 7.
5. **Missing, malformed, expired, or foreign-signed JWT, and wrong role** must return a `ProblemDetail` body (`UNAUTHORIZED` 401 / `FORBIDDEN` 403), not Spring's empty-body default. → test in Task 5.

---

## File Structure

```
backend/
  pom.xml                                         (modify: 3 deps)
  src/main/resources/
    application.properties                        (modify)
    application-local.properties                  (create)
    messages.properties, messages_ro.properties   (create)
    static/openapi.yaml                           (served copy – see Task 1)
    db/migration/V1__identity.sql                 (create)
    db/migration/V2__auth_tokens_and_invites.sql  (create)
  src/main/java/com/anafitlab/backend/
    common/
      AppProperties.java            app.base-url, app.cors-allowed-origins
      ClockConfig.java              Clock bean
      ApiPathConfig.java            /api/v1 prefix
      error/ApiException.java, RateLimitedException.java, GlobalExceptionHandler.java,
            ProblemDetails.java (factory used by handler + security handlers)
      security/SecurityConfig.java, JwtProperties.java, JwtConfig.java,
               CurrentUser.java, CurrentUserArgumentResolver.java,
               ProblemAuthenticationEntryPoint.java, ProblemAccessDeniedHandler.java,
               ClientIp.java
      mail/EmailSender.java, SmtpEmailSender.java, OutgoingEmail.java,
           EmailDeliveryListener.java, MailConfig.java
      ratelimit/RateLimiter.java, Limit.java, RateLimitProperties.java
      validation/ValidPassword.java (+ validator), ValidLocale.java (+ validator),
                 ValidTimezone.java (+ validator)
    auth/
      Role.java, UserStatus.java, AppUser.java, AppUserRepository.java
      RefreshToken.java, RefreshTokenRepository.java, RefreshTokenService.java
      ActionTokenPurpose.java, UserActionToken.java, UserActionTokenRepository.java, ActionTokenService.java
      SecureTokens.java, TokenHasher.java, EmailNormalizer.java
      AccessTokenIssuer.java, SessionFactory.java
      UserRegistrar.java, NewUser.java
      AccountEmails.java
      AuthService.java, AccountService.java
      AuthController.java, MeController.java
      AdminBootstrap.java
      dto/…                          request/response records
    client/
      RelationshipStatus.java, CoachClient.java, CoachClientRepository.java, RelationshipTransitions.java
      CoachProfile.java, CoachProfileRepository.java, CoachProfileService.java
      InviteStatus.java, CoachInvite.java, CoachInviteRepository.java, InviteCodes.java, InviteService.java
      CoachLinkService.java, ClientRegistrationService.java, RelationshipService.java
      ClientAccessPolicy.java
      InviteController.java, CoachInviteController.java, CoachClientController.java,
      CoachProfileController.java, MyCoachController.java
      dto/…
  src/test/java/com/anafitlab/backend/
    TestcontainersConfiguration.java  (modify: postgres:17)
    support/IntegrationTestBase.java, TestFixtures.java, MutableClock.java,
            RecordingEmailSender.java, TestSupportConfig.java
    …Test classes named per task
docker-compose.yml                                  (create, repo root)
docs/api/openapi.yaml                               (create)
docs/domain-model.md, CLAUDE.md                     (modify)
```

---

### Task 1: Foundations – docs, local infra, config, contract skeleton

**Files:**
- Modify: `docs/domain-model.md`, `CLAUDE.md`, `backend/pom.xml`, `backend/src/main/resources/application.properties`, `backend/src/test/java/com/anafitlab/backend/TestcontainersConfiguration.java`
- Create: `docker-compose.yml`, `backend/src/main/resources/application-local.properties`, `docs/api/openapi.yaml`, `common/AppProperties.java`, `common/ClockConfig.java`, `common/ApiPathConfig.java`
- Test: `backend/src/test/java/com/anafitlab/backend/BackendApplicationTests.java`, `common/OpenApiContractServedTest.java`

**Interfaces:**
- Produces: `Clock` bean (`Clock.systemUTC()`); `AppProperties(String baseUrl, List<String> corsAllowedOrigins)` bound to `app.*`; every `@RestController` under `com.anafitlab.backend` served under `/api/v1`; contract served at `GET /openapi.yaml`, Swagger UI at `/swagger-ui.html`.

- [ ] **Step 1: Update `docs/domain-model.md` to v0.5.** The document is Romanian prose with English identifiers – keep that. Apply spec §4 exactly: `app_user` rules (§4.1); `coach_client.status` without `INVITED` and the new partial index (§4.3) plus transitions; new tables `coach_invite`, `refresh_token`, `user_action_token` (§4.4–4.6); `PAUSED` semantics (D10) and ending rules (D11) in §2; add decisions 26–31 to §9 (invite codes, Boot 4, sessions, email verification/reset, open coach signup, PAUSED/ending); in §10 #3 note that slice 1 has no ADMIN endpoints. Bump header to v0.5.
- [ ] **Step 2: Update `CLAUDE.md`:** Spring Boot 3 → 4 (4.1.1); local infra lists PostgreSQL + Mailpit (MinIO from slice 2); run command `cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local`; add a "Dependencies" line naming validation (DTO validation), mail (verification/reset emails), springdoc (Swagger UI for the hand-written contract).
- [ ] **Step 3: Create `docker-compose.yml`:** `postgres:17` (db `anafitlab`, user/password `anafitlab`, port 5432, named volume) and `axllent/mailpit` pinned to an exact current tag (SMTP 1025, UI 8025).
- [ ] **Step 4: Add the three dependencies to `pom.xml`** (springdoc with pinned version).
- [ ] **Step 5: Configure properties.** `application.properties`: `spring.jpa.hibernate.ddl-auto=validate`, `spring.jpa.open-in-view=false`, `spring.messages.basename=messages`, `spring.messages.fallback-to-system-locale=false`, datasource/mail/`app.*`/`app.jwt.secret`/admin from env vars named in spec §7 with **no defaults**, `springdoc.swagger-ui.url=/openapi.yaml`, `springdoc.api-docs.enabled=false`. `application-local.properties`: localhost DB from compose, Mailpit on 1025, `app.base-url=http://localhost:5173`, `app.cors-allowed-origins=http://localhost:5173`, a 64-char dev JWT secret, dev ADMIN `admin@local.test` / `admin-dev-password`.
- [ ] **Step 6: Implement `ClockConfig`, `AppProperties` (`@ConfigurationProperties("app")`), `ApiPathConfig`** (`WebMvcConfigurer.configurePathMatch` → `addPathPrefix("/api/v1", HandlerTypePredicate.forAnnotation(RestController.class))`).
- [ ] **Step 7: Create `docs/api/openapi.yaml`** (OpenAPI 3.1): info, server `/api/v1`, `bearerAuth` (HTTP bearer JWT), components `Problem` (`type`, `title`, `status`, `detail`, `instance`, `code`, `errors[{field, code}]`) and `TokenResponse`/`UserResponse` per spec §5.1. No paths yet. Make it served as `/openapi.yaml`: add a Maven `maven-resources-plugin` execution copying `../docs/api/openapi.yaml` into `target/classes/static/` at `generate-resources` (single source of truth; do not commit a second copy).
- [ ] **Step 8: Pin `postgres:17` in `TestcontainersConfiguration`.** Test properties: add `src/test/resources/application.properties` overriding the env-only values (dummy mail host, 64-char test JWT secret, `app.base-url=http://app.test`, `app.cors-allowed-origins=http://app.test`, no admin).
- [ ] **Step 9: Write `OpenApiContractServedTest.servesHandWrittenContract`:** `GET /openapi.yaml` → 200 and body contains `openapi: 3.1`.
- [ ] **Step 10: Run** `cd backend && ./mvnw test` – Expected: `contextLoads` and the new test PASS (Flyway has no migrations yet; that is fine).
- [ ] **Step 11: Verify local run:** `docker compose up -d && cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local` starts; `http://localhost:8080/swagger-ui.html` shows the contract; Mailpit UI on 8025. Stop the app.
- [ ] **Step 12: Commit** `chore: foundations for slice 1 (docs v0.5, compose, config, contract skeleton)`.

---

### Task 2: Error format and localization

**Files:**
- Create: `common/error/ApiException.java`, `common/error/RateLimitedException.java`, `common/error/ProblemDetails.java`, `common/error/GlobalExceptionHandler.java`, `src/main/resources/messages.properties`, `messages_ro.properties`
- Test: `common/error/ErrorFormatTest.java` + test-only `common/error/ErrorTestController.java` in `src/test`

**Interfaces:**
- Produces:
  - `ApiException(HttpStatus status, String code, Object... args)` with `status()`, `code()`, `args()`; `detail` = message `error.<code>` with args, in the request locale.
  - `RateLimitedException(Duration retryAfter)` extends `ApiException` (429, `RATE_LIMITED`); handler sets `Retry-After` in whole seconds (rounded up).
  - `ProblemDetails.of(HttpStatus, String code, Locale) -> ProblemDetail` (used by security handlers in Task 5).
  - Bean-validation failures → 400 `VALIDATION_FAILED` with `errors: [{field, code}]`, `code` = constraint `message`. Malformed JSON → 400 `MALFORMED_REQUEST`. Unknown route → 404 `NOT_FOUND`. Anything unhandled → 500 `INTERNAL_ERROR` (logged, no stack trace in body).
  - Locale for `detail`: request `Accept-Language` (`ro` or `en`, default `en`) for now; Task 5 switches authenticated requests to the user's `locale`.

- [ ] **Step 1: Write failing tests in `ErrorFormatTest`** against a test controller exposing `/api/v1/test/api-error` (throws `ApiException(CONFLICT, "EMAIL_TAKEN")`), `/api/v1/test/validate` (POST record with `@NotBlank(message="REQUIRED") String name`), `/api/v1/test/rate-limited` (throws `RateLimitedException(Duration.ofSeconds(90))`):
  - `apiExceptionBecomesProblemDetail`: 409, `$.code == "EMAIL_TAKEN"`, `$.status == 409`, content type `application/problem+json`.
  - `detailIsLocalizedRomanian`: with `Accept-Language: ro`, `$.detail` equals the `ro` text of `error.EMAIL_TAKEN`; with `en`, the English text.
  - `validationErrorsListFieldCodes`: `{}` → 400, `$.code == "VALIDATION_FAILED"`, `$.errors[0].field == "name"`, `$.errors[0].code == "REQUIRED"`.
  - `malformedJsonIs400`: body `{` → 400 `MALFORMED_REQUEST`.
  - `rateLimitedSetsRetryAfter`: 429, header `Retry-After: 90`, `$.code == "RATE_LIMITED"`.
  - `unknownRouteIs404Problem`: `GET /api/v1/nope` → 404 `NOT_FOUND`.
- [ ] **Step 2: Run** `./mvnw test -Dtest=ErrorFormatTest` – Expected: FAIL.
- [ ] **Step 3: Implement** the classes above. `GlobalExceptionHandler` extends `ResponseEntityExceptionHandler` and uses `MessageSource`. Seed both message files with keys for every code in this plan's error list: `VALIDATION_FAILED, MALFORMED_REQUEST, NOT_FOUND, INTERNAL_ERROR, UNAUTHORIZED, FORBIDDEN, RATE_LIMITED, EMAIL_TAKEN, INVALID_CREDENTIALS, ACCOUNT_SUSPENDED, INVALID_REFRESH_TOKEN, REFRESH_TOKEN_REUSED, INVALID_TOKEN, INVALID_CURRENT_PASSWORD, EMAIL_NOT_VERIFIED, INVITE_NOT_FOUND, INVITE_EXPIRED, INVITE_USED, INVITE_REVOKED, INVITE_NOT_REVOCABLE, ALREADY_HAS_COACH, NO_COACH, INVALID_RELATIONSHIP_TRANSITION, CLIENT_NOT_FOUND` (Romanian text with diacritics, UTF-8).
- [ ] **Step 4: Run** the test – Expected: PASS.
- [ ] **Step 5: Commit** `feat: RFC 9457 error format with localized details`.

---

### Task 3: Schema, entities and repositories

**Files:**
- Create: `db/migration/V1__identity.sql`, `db/migration/V2__auth_tokens_and_invites.sql`, entities/enums/repositories listed under `auth/` and `client/` in File Structure (no services).
- Create (also): `common/security/PasswordConfig.java`
- Test: `SchemaConstraintsTest.java` (in `com.anafitlab.backend`), `support/IntegrationTestBase.java`, `support/TestFixtures.java` (repository-level helpers only for now)

**Interfaces:**
- Produces:
  - `Role {COACH, CLIENT, ADMIN}`, `UserStatus {PENDING, ACTIVE, SUSPENDED}`, `RelationshipStatus {ACTIVE, PAUSED, ENDED}`, `InviteStatus {PENDING, USED, REVOKED}`, `ActionTokenPurpose {EMAIL_VERIFICATION, PASSWORD_RESET}` – all `@Enumerated(STRING)`.
  - `AppUser` (id, email, passwordHash, role, firstName, lastName, locale, timezone, status, emailVerifiedAt, lastLoginAt, timestamps). `AppUserRepository`: `Optional<AppUser> findByEmail(String normalizedEmail)`, `boolean existsByEmail(String)`, `boolean existsByRole(Role)`.
  - `CoachProfile` (`@Id UUID userId`, bio, `@JdbcTypeCode(SqlTypes.ARRAY) List<String> specializations`). `CoachProfileRepository`.
  - `CoachClient` (id, coachId, clientId, status, invitedAt, startedAt, endedAt). `CoachClientRepository`: `Optional<CoachClient> findCurrentByClientId(UUID)` and `List<CoachClient> findCurrentByCoachId(UUID)` (current = `ACTIVE` or `PAUSED`, via `@Query`), `Optional<CoachClient> findCurrentByCoachIdAndClientId(UUID, UUID)`.
  - `CoachInvite` (id, coachId, codeHash, label, status, expiresAt, usedAt, usedByClientId). `CoachInviteRepository`: `Optional<CoachInvite> findByCodeHash(String)`, `@Lock(PESSIMISTIC_WRITE) Optional<CoachInvite> findByCodeHashForUpdate(String)` (explicit `@Query`), `List<CoachInvite> findByCoachIdOrderByCreatedAtDesc(UUID)`, `Optional<CoachInvite> findByIdAndCoachId(UUID, UUID)`.
  - `RefreshToken` (id, userId, tokenHash, familyId, expiresAt, revokedAt, replacedById). `RefreshTokenRepository`: `Optional<RefreshToken> findByTokenHash(String)`, `@Modifying` `int revokeFamily(UUID familyId, Instant now)`, `int revokeAllForUser(UUID userId, Instant now)`, `int revokeAllForUserExceptFamily(UUID userId, UUID familyId, Instant now)` (only rows with `revoked_at IS NULL`).
  - `UserActionToken` (id, userId, purpose, tokenHash, expiresAt, usedAt). `UserActionTokenRepository`: `Optional<UserActionToken> findByTokenHashAndPurpose(String, ActionTokenPurpose)`, `@Modifying int invalidateUnused(UUID userId, ActionTokenPurpose purpose, Instant now)`.
  - `PasswordConfig`: `PasswordEncoder` bean = `PasswordEncoderFactories.createDelegatingPasswordEncoder()` (BCrypt).
  - Test support: `abstract class IntegrationTestBase` annotated `@SpringBootTest`, `@AutoConfigureMockMvc` (Boot 4 package `org.springframework.boot.webmvc.test.autoconfigure`), `@Import({TestcontainersConfiguration.class, TestSupportConfig.class})`, with a `@BeforeEach` that truncates all app tables (`TRUNCATE … CASCADE`); later tasks extend this reset (email recorder, rate limiter, clock). All integration tests extend it. `TestFixtures.user(Role, UserStatus, String email) -> AppUser` (password `"correct-horse-1"`, BCrypt-hashed), `TestFixtures.link(AppUser coach, AppUser client, RelationshipStatus) -> CoachClient`.

- [ ] **Step 1: Write `V1__identity.sql`:** `app_user` (all §4.1 columns, `CHECK (email = lower(email))`, `UNIQUE (email)`, CHECKs for role/status/locale, `created_at`/`updated_at timestamptz NOT NULL DEFAULT now()`, `id uuid DEFAULT gen_random_uuid()`); `coach_profile` (`user_id` PK/FK `ON DELETE CASCADE`, `bio text`, `specializations text[] NOT NULL DEFAULT '{}'`); `coach_client` (§4.3, FKs to `app_user` with `ON DELETE CASCADE`, status CHECK without `INVITED`, `CREATE UNIQUE INDEX ux_coach_client_current ON coach_client (client_id) WHERE status IN ('ACTIVE','PAUSED')`, index on `coach_id`).
- [ ] **Step 2: Write `V2__auth_tokens_and_invites.sql`** per §4.4–4.6 (FK rules as in the spec; `coach_invite.coach_id` FK `ON DELETE CASCADE`; indexes on `refresh_token(family_id)`, `refresh_token(user_id)`, `user_action_token(user_id, purpose)`, `coach_invite(coach_id)`).
- [ ] **Step 3: Write failing `SchemaConstraintsTest`** (uses `JdbcTemplate` / repositories directly):
  - `rejectsUppercaseEmail`: inserting `Ana@x.ro` → `DataIntegrityViolationException`.
  - `rejectsDuplicateEmail`.
  - `allowsOnlyOneCurrentCoachPerClient`: second `ACTIVE` link for same client → violation; `ENDED` + `ACTIVE` → allowed.
  - `rejectsInvitedStatus`: `coach_client.status = 'INVITED'` → violation.
  - `rejectsDuplicateInviteCodeHash`.
  - `deletingUserCascadesTokensAndNullsInviteUsage`: delete a client → their `refresh_token`/`user_action_token` rows gone, `coach_invite.used_by_client_id` is null.
- [ ] **Step 4: Run** `./mvnw test -Dtest=SchemaConstraintsTest` – Expected: FAIL (no entities/migrations).
- [ ] **Step 5: Implement entities, enums, repositories** with the signatures above. `contextLoads` passing proves `ddl-auto=validate` matches the migrations.
- [ ] **Step 6: Run** `./mvnw test` – Expected: all PASS.
- [ ] **Step 7: Commit** `feat: identity schema (app_user, coach_client, invites, tokens)`.

---

### Task 4: Pure building blocks (unit tested)

**Files:**
- Create: `auth/SecureTokens.java`, `auth/TokenHasher.java`, `auth/EmailNormalizer.java`, `client/InviteCodes.java`, `client/RelationshipTransitions.java`, `common/ratelimit/RateLimiter.java`, `common/ratelimit/Limit.java`, `common/validation/ValidPassword.java` (+ `PasswordValidator`), `ValidLocale.java` (+ validator), `ValidTimezone.java` (+ validator)
- Test: `SecureTokensTest`, `TokenHasherTest`, `EmailNormalizerTest`, `InviteCodesTest`, `RelationshipTransitionsTest`, `RateLimiterTest`, `ValidatorsTest` (plain JUnit, no Spring)

**Interfaces:**
- Produces:
  - `SecureTokens.generate() -> String` (32 random bytes, base64url no padding, 43 chars).
  - `TokenHasher.sha256(String) -> String` (64 lowercase hex chars).
  - `EmailNormalizer.normalize(String) -> String` (trim + `toLowerCase(Locale.ROOT)`).
  - `InviteCodes.generate() -> String` (10 chars from `0123456789ABCDEFGHJKMNPQRSTVWXYZ`), `InviteCodes.normalize(String) -> String` (uppercase; remove spaces/dashes; `O→0`, `I→1`, `L→1`), `InviteCodes.display(String) -> String` (`XXXXX-XXXXX`). Hash = `TokenHasher.sha256(InviteCodes.normalize(code))`.
  - `RelationshipTransitions.require(RelationshipStatus from, RelationshipStatus to)` → throws `ApiException(CONFLICT, "INVALID_RELATIONSHIP_TRANSITION")` unless `ACTIVE→PAUSED`, `PAUSED→ACTIVE`, `ACTIVE→ENDED`, `PAUSED→ENDED`.
  - `Limit(int max, Duration window)`. `RateLimiter(Clock)` (Spring `@Component`): `void hit(String bucket, String key, Limit limit)` – increments, throws `RateLimitedException(remaining window)` once count exceeds `max`; `void ensureUnder(String bucket, String key, Limit limit)` – throws if count ≥ `max`, no increment; `void record(String bucket, String key, Limit limit)` – increments only; `void reset()` – clears (tests). Fixed windows keyed by `bucket + ":" + key`, `ConcurrentHashMap`; expired windows evicted lazily.
  - `@ValidPassword` (message `PASSWORD_POLICY`): null-safe; 10–64 code points **and** ≤72 UTF-8 bytes. `@ValidLocale` (message `INVALID_LOCALE`): `ro` or `en`. `@ValidTimezone` (message `INVALID_TIMEZONE`): `ZoneId.of` succeeds and id is region-based (reject `"+02:00"` style offsets).

- [ ] **Step 1: Write failing unit tests** with these assertions:
  - `SecureTokensTest.generatesDistinct43CharTokens` (1 000 tokens, all unique, all match `^[A-Za-z0-9_-]{43}$`).
  - `TokenHasherTest.knownVector`: `sha256("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"`.
  - `EmailNormalizerTest`: `" Ana@Example.RO " → "ana@example.ro"`.
  - `InviteCodesTest`: generated codes match `^[0-9ABCDEFGHJKMNPQRSTVWXYZ]{10}$`; `normalize("k7q2m-9xdoi") == normalize("K7Q2M9XD01")`; `normalize(" k7q2-m9xd-l0 ") == "K7Q2M9XD10"`; `display("K7Q2M9XD10") == "K7Q2M-9XD10"`.
  - `RelationshipTransitionsTest`: the 4 allowed transitions pass; `ENDED→ACTIVE`, `ENDED→PAUSED`, `ACTIVE→ACTIVE`, `PAUSED→PAUSED` throw with code `INVALID_RELATIONSHIP_TRANSITION`.
  - `RateLimiterTest` (with a `MutableClock`): `hit` allows `max` then throws with `retryAfter` = remaining window; after advancing past the window allows again; `ensureUnder` does not count; different keys independent.
  - `ValidatorsTest`: password `"123456789"` (9) invalid, `"1234567890"` valid, 64 ASCII valid, 65 invalid, 19 × `"😀"` (19 code points, 76 bytes) invalid; locales `ro`/`en` valid, `fr`/`RO`/`""` invalid; timezone `Europe/Bucharest` valid, `Mars/Olympus` and `+02:00` invalid.
- [ ] **Step 2: Run** `./mvnw test -Dtest='*Test' -Dsurefire.failIfNoSpecifiedTests=false` for these classes – Expected: FAIL.
- [ ] **Step 3: Implement** the classes with the signatures above (move `MutableClock` to `src/test/.../support` – `Clock` subclass with `advance(Duration)` and `set(Instant)`, zone UTC).
- [ ] **Step 4: Run** – Expected: PASS.
- [ ] **Step 5: Commit** `feat: token, invite-code, rate-limit and validation building blocks`.

---

### Task 5: JWT security, current user, `GET /me`

**Files:**
- Create: `common/security/JwtProperties.java`, `JwtConfig.java`, `SecurityConfig.java`, `CurrentUser.java`, `CurrentUserArgumentResolver.java`, `ProblemAuthenticationEntryPoint.java`, `ProblemAccessDeniedHandler.java`, `ClientIp.java`, `auth/AccessTokenIssuer.java`, `auth/AccountService.java` (only `me`), `auth/MeController.java` (only `GET /me`), `auth/dto/UserResponse.java`
- Modify: `docs/api/openapi.yaml` (`GET /me`), `common/error/GlobalExceptionHandler.java` (locale from user), `support/TestFixtures.java` (`bearer`)
- Test: `security/JwtSecurityTest.java`, `security/JwtSecretValidationTest.java`

**Interfaces:**
- Consumes: `AppUserRepository`, `ProblemDetails.of`, `Clock`.
- Produces:
  - `JwtProperties(String secret, Duration accessTokenTtl = PT15M)` bound to `app.jwt`; startup fails (`IllegalStateException` from `JwtConfig`) if `secret` is null or its UTF-8 bytes < 32.
  - `JwtEncoder`/`JwtDecoder` beans: HS256 (`NimbusJwtEncoder` with `ImmutableSecret`, `NimbusJwtDecoder.withSecretKey(...).macAlgorithm(HS256)`), decoder validates `exp` with the injected `Clock`.
  - `AccessTokenIssuer.issue(AppUser) -> IssuedAccessToken(String token, Instant expiresAt)`; claims `sub` = user id, `role`, `jti` (random UUID), `iat`, `exp`.
  - Authorities: `JwtAuthenticationConverter` mapping claim `role` → `ROLE_<role>`.
  - `CurrentUser(UUID id, Role role)`; controllers declare a `CurrentUser` parameter, resolved from the authenticated `Jwt`.
  - `ClientIp.of(HttpServletRequest) -> String` = `request.getRemoteAddr()` (no forwarded headers in this slice).
  - `SecurityConfig`: stateless, CSRF disabled, CORS from `AppProperties.corsAllowedOrigins`; public: `POST /api/v1/auth/register/**`, `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/verify-email`, `/auth/password-reset/**`, `GET /api/v1/invites/*`, `/openapi.yaml`, `/swagger-ui/**`, `/swagger-ui.html`, `/actuator/health`; `/api/v1/coach/**` → `hasRole('COACH')`; `/api/v1/admin/**` → `hasRole('ADMIN')`; everything else authenticated. Entry point → 401 `UNAUTHORIZED` ProblemDetail; access denied → 403 `FORBIDDEN` ProblemDetail.
  - `AccountService.me(CurrentUser) -> UserResponse`; `GET /me` → 200 `UserResponse` (spec §5.1 user object).
  - For authenticated requests, `detail` uses the user's `locale` (look up by `CurrentUser.id`), else `Accept-Language`.
  - `TestFixtures.bearer(AppUser) -> String` (`"Bearer " + issuer.issue(user).token()`).

- [ ] **Step 1: Add `GET /me` to `openapi.yaml`** (200 `UserResponse`, 401 `Problem`).
- [ ] **Step 2: Write failing `JwtSecurityTest`:**
  - `meReturnsCurrentUser`: coach with token → 200, `$.id`, `$.role == "COACH"`, `$.email`.
  - `missingTokenIs401Problem`: no header → 401, `$.code == "UNAUTHORIZED"`, `application/problem+json`.
  - `garbageTokenIs401Problem`: `Bearer abc.def.ghi` → 401 `UNAUTHORIZED`.
  - `tokenSignedWithOtherSecretIs401`: token built with a different 32-byte secret → 401.
  - `expiredTokenIs401`: issue, advance `MutableClock` 16 min → 401.
  - `clientOnCoachRouteIs403Problem`: client token on `GET /api/v1/coach/profile` (route not implemented yet – security runs first) → 403 `FORBIDDEN`.
  - `detailUsesUserLocale`: a `ro` user hitting a 403 route gets the Romanian `detail` even with `Accept-Language: en`.
  - `corsAllowsConfiguredOrigin`: preflight `OPTIONS /api/v1/me` from `http://app.test` → `Access-Control-Allow-Origin: http://app.test`; from `http://evil.test` → no allow header.
- [ ] **Step 3: Write failing `JwtSecretValidationTest.shortSecretFailsStartup`** using `ApplicationContextRunner` (or `SpringApplicationBuilder`) with `app.jwt.secret=too-short` → context fails with message mentioning `app.jwt.secret`.
- [ ] **Step 4: Run** both tests – Expected: FAIL.
- [ ] **Step 5: Implement** the interfaces above. `TestSupportConfig` registers `MutableClock` as the primary `Clock`.
- [ ] **Step 6: Run** `./mvnw test` – Expected: PASS.
- [ ] **Step 7: Commit** `feat: JWT resource-server security with problem responses and GET /me`.

---

### Task 6: Email delivery infrastructure

**Files:**
- Create: `common/mail/EmailSender.java`, `OutgoingEmail.java`, `SmtpEmailSender.java`, `EmailDeliveryListener.java`, `MailConfig.java`, `auth/AccountEmails.java`
- Modify: `messages.properties`, `messages_ro.properties` (email subjects/bodies)
- Test: `support/RecordingEmailSender.java`, `common/mail/EmailDeliveryTest.java`

**Interfaces:**
- Produces:
  - `OutgoingEmail(String to, String subject, String body)` (plain text). `EmailSender { void send(OutgoingEmail) }` (named `EmailSender` to avoid clashing with Spring's `MailSender`; this is the spec's "MailSender"). `SmtpEmailSender` uses `JavaMailSender`, from address `app.mail.from`.
  - `EmailDeliveryListener`: `@TransactionalEventListener(phase = AFTER_COMMIT)` on `OutgoingEmail`, hands off to `TaskExecutor emailExecutor` (from `MailConfig`: `SyncTaskExecutor` when `app.mail.synchronous=true`, else a small `ThreadPoolTaskExecutor`); exceptions logged at WARN with recipient, never rethrown.
  - `AccountEmails.sendVerification(AppUser user, String rawToken)` and `sendPasswordReset(AppUser user, String rawToken)`: compose subject/body from `email.verification.subject|body` and `email.reset.subject|body` in `user.locale`, links `{app.base-url}/verify-email?token=<raw>` and `{app.base-url}/reset-password?token=<raw>`, then `ApplicationEventPublisher.publishEvent(outgoingEmail)`. Must be called inside a transaction.
  - Test: `RecordingEmailSender` (`@Primary` in `TestSupportConfig`) with `List<OutgoingEmail> sent()`, `OutgoingEmail lastTo(String email)`, `String extractToken(OutgoingEmail)` (regex `token=([A-Za-z0-9_-]+)`), `clear()` (add to `IntegrationTestBase`'s `@BeforeEach`, together with `RateLimiter.reset()` and resetting `MutableClock` to a fixed instant `2026-01-15T10:00:00Z`). Test properties set `app.mail.synchronous=true`.

- [ ] **Step 1: Write failing `EmailDeliveryTest`** (calls `AccountEmails` through a `TransactionTemplate`):
  - `sendsAfterCommit`: verification email for a `ro` user → one email, to the user, Romanian subject, body contains `http://app.test/verify-email?token=`.
  - `doesNotSendOnRollback`: same inside a transaction marked rollback-only → no email.
  - `senderFailureDoesNotPropagate`: `RecordingEmailSender` configured to throw → `TransactionTemplate.execute` completes normally.
- [ ] **Step 2: Run** – Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** – Expected: PASS.
- [ ] **Step 5: Commit** `feat: transactional, localized email delivery`.

---

### Task 7: Coach signup and login

**Files:**
- Create: `auth/NewUser.java`, `auth/UserRegistrar.java`, `auth/RefreshTokenService.java` (`startFamily` only), `auth/ActionTokenService.java` (`issue` only), `auth/SessionFactory.java`, `auth/AuthService.java`, `auth/AuthController.java`, DTOs `RegisterCoachRequest`, `LoginRequest`, `TokenResponse`
- Modify: `openapi.yaml`; `common/security/SecurityConfig.java` if needed
- Test: `auth/CoachSignupAndLoginTest.java`

**Interfaces:**
- Consumes: Task 3 repositories, Task 4 `EmailNormalizer`, `SecureTokens`, `TokenHasher`, validators, `RateLimiter`; Task 5 `AccessTokenIssuer`, `ClientIp`; Task 6 `AccountEmails`.
- Produces:
  - `NewUser(String email, String password, String firstName, String lastName, String locale, String timezone)`.
  - `UserRegistrar.register(Role role, NewUser fields) -> AppUser`: normalizes email; `existsByEmail` → `ApiException(CONFLICT, "EMAIL_TAKEN")` (also map a unique-violation on flush to the same); status `PENDING`; BCrypt hash via the `PasswordEncoder` bean from Task 3 (`PasswordConfig`).
  - `RefreshTokenService.startFamily(AppUser) -> IssuedRefreshToken(String raw, Instant expiresAt)` (new `familyId`, 30 days).
  - `ActionTokenService.issue(AppUser, ActionTokenPurpose) -> String raw` (invalidates earlier unused tokens of that purpose; TTL 48 h / 1 h).
  - `SessionFactory.create(AppUser) -> TokenResponse` (access + new family + `UserResponse`).
  - `TokenResponse(String accessToken, Instant accessTokenExpiresAt, String refreshToken, Instant refreshTokenExpiresAt, UserResponse user)`.
  - `RegisterCoachRequest` fields as `NewUser` with constraints: `@NotBlank(message="REQUIRED") @Email(message="INVALID_EMAIL") @Size(max=254, message="TOO_LONG") email`, `@ValidPassword password`, `@NotBlank @Size(max=100)` names, `@ValidLocale locale`, `@ValidTimezone timezone`.
  - `AuthService.registerCoach(RegisterCoachRequest, String ip) -> TokenResponse` (`@Transactional`): `rateLimiter.hit("signup-ip", ip, 10/1h)`, register COACH, create empty `CoachProfile`, issue verification token, `AccountEmails.sendVerification`, return session.
  - `AuthService.login(LoginRequest, String ip) -> TokenResponse`: `ensureUnder("login-email", email, 5/15m)` and `ensureUnder("login-ip", ip, 20/15m)`; unknown email → run `passwordEncoder.matches` against a fixed dummy BCrypt hash, then `record` both and throw `401 INVALID_CREDENTIALS`; wrong password → same; `SUSPENDED` (after a correct password) → `403 ACCOUNT_SUSPENDED`; success → `lastLoginAt = now(clock)`, session.
  - `POST /auth/register/coach` → 201 `TokenResponse`; `POST /auth/login` → 200 `TokenResponse`.

- [ ] **Step 1: Add both endpoints to `openapi.yaml`** with request schemas, responses and error codes (400/409/429 for signup; 400/401/403/429 for login).
- [ ] **Step 2: Write failing `CoachSignupAndLoginTest`:**
  - `coachSignupCreatesPendingCoachWithProfileAndSession`: 201; `$.user.role == "COACH"`, `$.user.status == "PENDING"`; `$.accessToken` works on `GET /me`; `coach_profile` row exists; one email to the coach containing `verify-email?token=`.
  - `emailIsNormalized` (Review Focus 2): sign up with `" Ana@Example.RO "` → `$.user.email == "ana@example.ro"`; login with `"ANA@example.ro"` → 200; second signup with `"ana@example.ro"` → 409 `EMAIL_TAKEN`.
  - `multiByteLongPasswordRejected` (Review Focus 1): password of 19 × `"😀"` → 400, `$.errors[?(@.field=='password')].code == "PASSWORD_POLICY"`.
  - `invalidLocaleAndTimezoneRejected` (Review Focus 4): `locale "fr"`, `timezone "Mars/Olympus"` → 400 with `INVALID_LOCALE` and `INVALID_TIMEZONE`.
  - `loginWrongPasswordAndUnknownEmailLookTheSame`: both → 401 `INVALID_CREDENTIALS`, same body except `instance`.
  - `loginSuspendedIs403`: fixture user `SUSPENDED` with correct password → 403 `ACCOUNT_SUSPENDED`.
  - `loginUpdatesLastLoginAt`: equals `MutableClock` instant.
  - `loginLockedAfterFiveFailures`: 5 wrong passwords → 401 each; 6th attempt (even correct password) → 429 with `Retry-After`; after advancing 15 min → correct password 200.
  - `signupRateLimitedPerIp`: 11th signup from same IP within an hour → 429.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** `./mvnw test` – Expected: PASS.
- [ ] **Step 6: Commit** `feat: coach signup and login`.

---

### Task 8: Refresh, logout, logout-all

**Files:**
- Modify: `auth/RefreshTokenService.java`, `auth/AuthService.java`, `auth/AuthController.java`, `openapi.yaml`
- Create: DTOs `RefreshRequest`, `LogoutRequest`
- Test: `auth/RefreshAndLogoutTest.java`

**Interfaces:**
- Produces:
  - `RefreshTokenService.rotate(String raw) -> RotationResult(AppUser user, IssuedRefreshToken next)` (`@Transactional(noRollbackFor = ApiException.class)` so revocations commit before the error is returned; add `@Lock(PESSIMISTIC_WRITE) Optional<RefreshToken> findByTokenHashForUpdate(String)` to the repository): unknown/expired → `401 INVALID_REFRESH_TOKEN`; revoked with `replacedById != null` → `revokeFamily` then `401 REFRESH_TOKEN_REUSED`; revoked without replacement → `401 INVALID_REFRESH_TOKEN`; user `SUSPENDED` → revoke family, `403 ACCOUNT_SUSPENDED`; else revoke current, insert new in same family with fresh 30 days, set `replacedById`.
  - `RefreshTokenService.revokeFamilyOf(String raw)` (no-op if unknown), `revokeAllForUser(UUID)`, `revokeAllExceptFamilyOf(UUID userId, String raw)` (used by Task 10).
  - `POST /auth/refresh {refreshToken}` → 200 `TokenResponse`. `POST /auth/logout {refreshToken}` → 204 (also for unknown). `POST /auth/logout-all` (authenticated) → 204.

- [ ] **Step 1: Add the three endpoints to `openapi.yaml`.**
- [ ] **Step 2: Write failing `RefreshAndLogoutTest`:**
  - `refreshRotates`: login → refresh with R1 → 200 with R2 ≠ R1; R2 refreshes again.
  - `reusingRotatedTokenRevokesFamily`: R1 → R2; reuse R1 → 401 `REFRESH_TOKEN_REUSED`; now R2 → 401 `INVALID_REFRESH_TOKEN`.
  - `otherFamiliesSurviveReuse`: two logins (families A, B); reuse in A; B still refreshes.
  - `expiredRefreshRejected`: advance 30 days + 1 s → 401 `INVALID_REFRESH_TOKEN`.
  - `rotationExtendsExpiry`: refresh at day 29 → new `refreshTokenExpiresAt` = now + 30 days.
  - `suspendedUserCannotRefresh`: set status `SUSPENDED` in DB → 403 `ACCOUNT_SUSPENDED`; family revoked.
  - `logoutRevokesFamilyOnly`: logout with A's token → A refresh 401, B refresh 200; unknown token → 204.
  - `logoutAllRevokesEverything`: → 204; A and B refresh 401.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: refresh-token rotation with reuse detection, logout`.

---

### Task 9: Email verification and resend

**Files:**
- Modify: `auth/ActionTokenService.java` (`consume`), `auth/AccountService.java`, `auth/AuthController.java`, `openapi.yaml`
- Create: DTO `VerifyEmailRequest`
- Test: `auth/EmailVerificationTest.java`

**Interfaces:**
- Produces:
  - `ActionTokenService.consume(String raw, ActionTokenPurpose) -> AppUser`: unknown, wrong purpose, used or expired → `400 INVALID_TOKEN`; marks `usedAt`.
  - `AccountService.verifyEmail(String token)`: sets `emailVerifiedAt`; `PENDING → ACTIVE`; `SUSPENDED` stays `SUSPENDED`.
  - `AccountService.resendVerification(CurrentUser)`: `rateLimiter.hit("verify-resend", userId, 3/1h)`; only for `PENDING` (else 204 no-op); new token + email.
  - `POST /auth/verify-email {token}` → 204; `POST /auth/verify-email/resend` → 204.

- [ ] **Step 1: Add both endpoints to `openapi.yaml`.**
- [ ] **Step 2: Write failing `EmailVerificationTest`:**
  - `verifyActivatesUser`: signup → token from email → 204; `GET /me` `$.status == "ACTIVE"`; `email_verified_at` = clock.
  - `tokenIsSingleUse`: second use → 400 `INVALID_TOKEN`.
  - `tokenExpiresAfter48h`: advance 48 h + 1 s → 400 `INVALID_TOKEN`.
  - `resendInvalidatesOlderToken`: resend → old token 400, new token 204.
  - `resendRateLimited`: 4th resend within an hour → 429.
  - `suspendedStaysSuspended`: verify token of a user set to `SUSPENDED` → 204, status still `SUSPENDED`, `email_verified_at` set.
  - `resetTokenCannotVerify`: a `PASSWORD_RESET` token on verify-email → 400 `INVALID_TOKEN` (issue via `ActionTokenService` directly).
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: email verification`.

---

### Task 10: Password reset and change password

**Files:**
- Modify: `auth/AccountService.java`, `auth/AuthController.java`, `auth/MeController.java`, `openapi.yaml`
- Create: DTOs `PasswordResetRequest`, `PasswordResetConfirmRequest`, `ChangePasswordRequest`
- Test: `auth/PasswordResetTest.java`

**Interfaces:**
- Produces:
  - `AccountService.requestPasswordReset(String email, String ip)`: `hit("reset-email", email, 3/1h)` and `hit("reset-ip", ip, 10/1h)`; if user exists and not `SUSPENDED` → issue token + `AccountEmails.sendPasswordReset`; always returns normally.
  - `AccountService.confirmPasswordReset(String token, String newPassword) -> TokenResponse`: consume token, set hash, `revokeAllForUser`, `PENDING → ACTIVE` with `emailVerifiedAt`, return new session.
  - `AccountService.changePassword(CurrentUser, ChangePasswordRequest)`: `ChangePasswordRequest(String currentPassword, @ValidPassword String newPassword, @NotBlank String refreshToken)`; wrong current → `400 INVALID_CURRENT_PASSWORD`; set hash; `revokeAllExceptFamilyOf(userId, refreshToken)`.
  - `POST /auth/password-reset/request {email}` → 202; `POST /auth/password-reset/confirm {token, newPassword}` → 200 `TokenResponse`; `POST /me/password` → 204.

- [ ] **Step 1: Add the three endpoints to `openapi.yaml`.**
- [ ] **Step 2: Write failing `PasswordResetTest`:**
  - `requestAlways202`: existing and unknown email → 202; email sent only for the existing one.
  - `noEmailForSuspended`: suspended user → 202, no email.
  - `confirmSetsPasswordAndRevokesSessions`: existing family R → confirm → 200; login with new password 200, old password 401; R refresh → 401.
  - `confirmVerifiesPendingUser`: `PENDING` user → after confirm `$.user.status == "ACTIVE"`.
  - `resetTokenExpiresAfterOneHour`: advance 1 h + 1 s → 400 `INVALID_TOKEN`.
  - `confirmEnforcesPasswordPolicy`: `newPassword "short"` → 400 `PASSWORD_POLICY`.
  - `resetRequestRateLimitedPerEmail`: 4th request for same email within an hour → 429.
  - `changePasswordKeepsCurrentSessionOnly`: families A (current) and B; change with A's refresh token → 204; A refresh 200, B refresh 401.
  - `changePasswordWrongCurrent`: → 400 `INVALID_CURRENT_PASSWORD`.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: password reset and change password`.

---

### Task 11: Coach invites and public invite lookup

**Files:**
- Create: `client/InviteService.java`, `client/InviteController.java`, `client/CoachInviteController.java`, DTOs `CreateInviteRequest`, `CreatedInviteResponse`, `InviteResponse`, `InvitePreviewResponse`
- Modify: `openapi.yaml`
- Test: `client/CoachInvitesTest.java`

**Interfaces:**
- Consumes: `CoachInviteRepository`, `AppUserRepository`, `InviteCodes`, `TokenHasher`, `RateLimiter`, `Clock`, `AppProperties`.
- Produces:
  - `InviteService.create(CurrentUser coach, String label) -> CreatedInviteResponse(UUID id, String code /*display form*/, String link /*{baseUrl}/join/{display code}*/, String label, Instant expiresAt)`: coach not `ACTIVE` (i.e. `PENDING`) → `403 EMAIL_NOT_VERIFIED`; on the rare hash collision retry generation (max 3).
  - `InviteService.list(CurrentUser) -> List<InviteResponse(UUID id, String label, String status /*PENDING|USED|REVOKED|EXPIRED*/, Instant createdAt, Instant expiresAt, Instant usedAt)>` newest first; no code in this response.
  - `InviteService.revoke(CurrentUser, UUID inviteId)`: not found or other coach's → `404 INVITE_NOT_FOUND`; derived status not `PENDING` → `409 INVITE_NOT_REVOCABLE`.
  - `InviteService.preview(String code, String ip) -> InvitePreviewResponse(String coachFirstName, String coachLastName, boolean valid /*always true; invalid codes are errors*/)`: `hit("invite-ip", ip, 20/15m)`; checks via `requireUsable`.
  - `InviteService.claim(String code) -> CoachInvite` (MANDATORY transaction, uses `findByCodeHashForUpdate`) and package-private `requireUsable(CoachInvite)`: missing → `404 INVITE_NOT_FOUND`; `USED` → `410 INVITE_USED`; `REVOKED` → `410 INVITE_REVOKED`; expired → `410 INVITE_EXPIRED`.
  - `InviteService.markUsed(CoachInvite, UUID clientId)`.
  - `GET /invites/{code}` → 200 preview; `POST /coach/invites` → 201; `GET /coach/invites` → 200; `POST /coach/invites/{id}/revoke` → 204.

- [ ] **Step 1: Add the four endpoints to `openapi.yaml`.**
- [ ] **Step 2: Write failing `CoachInvitesTest`:**
  - `activeCoachCreatesInvite`: 201; `$.code` matches `^[0-9A-HJKMNP-TV-Z]{5}-[0-9A-HJKMNP-TV-Z]{5}$`; `$.link == "http://app.test/join/" + code`; `$.expiresAt` = clock + 7 days; DB `code_hash` ≠ code.
  - `pendingCoachCannotCreateInvite`: 403 `EMAIL_NOT_VERIFIED`.
  - `clientCannotCreateInvite`: 403 `FORBIDDEN`.
  - `listShowsDerivedStatusWithoutCode`: invites pending, revoked, expired (advance clock 7 days + 1 s for one) → statuses `PENDING`, `REVOKED`, `EXPIRED`; no `code` field.
  - `revokePendingOnly`: revoke pending → 204; revoke again → 409 `INVITE_NOT_REVOCABLE`; other coach's invite → 404 `INVITE_NOT_FOUND`.
  - `previewReturnsCoachName`: 200 with coach names.
  - `previewAcceptsLooselyTypedCode` (Review Focus 3): lowercase, no dash, with spaces, and `O`→`0`/`1`→`l` substitutions of the issued code → all 200.
  - `previewErrors`: unknown → 404 `INVITE_NOT_FOUND`; revoked → 410 `INVITE_REVOKED`; expired → 410 `INVITE_EXPIRED`.
  - `previewRateLimited`: 21st lookup from same IP in 15 min → 429.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: coach invites and invite preview`.

---

### Task 12: Client signup with code and `/me/coach-link`

**Files:**
- Create: `client/CoachLinkService.java`, `client/ClientRegistrationService.java`, `client/MyCoachController.java` (only `POST /me/coach-link`), DTOs `RegisterClientRequest`, `CoachLinkRequest`; add `POST /auth/register/client` handling (controller method may live in `client/ClientSignupController.java` mapped to `/auth/register/client` to keep `auth` free of `client` dependencies)
- Modify: `openapi.yaml`, `SecurityConfig` (`/api/v1/me/coach-link` and `/api/v1/me/coach/**` → `hasRole('CLIENT')`)
- Test: `client/ClientSignupTest.java`

**Interfaces:**
- Consumes: `UserRegistrar`, `SessionFactory`, `ActionTokenService`, `AccountEmails` (Task 7/9), `InviteService.claim/markUsed` (Task 11), `RateLimiter`.
- Produces:
  - `CoachLinkService.link(CoachInvite invite, UUID clientId) -> CoachClient`: existing current relationship → `409 ALREADY_HAS_COACH`; insert `ACTIVE` with `invitedAt = invite.createdAt`, `startedAt = now(clock)` using `saveAndFlush`, mapping a unique-index violation to `409 ALREADY_HAS_COACH`; then `markUsed`.
  - `ClientRegistrationService.register(RegisterClientRequest, String ip) -> TokenResponse` (`@Transactional`): `hit("signup-ip", ip, 10/1h)`; `claim(code)` **before** creating the user; `UserRegistrar.register(CLIENT, …)`; `link`; verification token + email; session. `RegisterClientRequest` = `RegisterCoachRequest` fields + `@NotBlank(message="REQUIRED") String code`.
  - `POST /auth/register/client` → 201 `TokenResponse`; `POST /me/coach-link {code}` → 201 `{coachId, coachFirstName, coachLastName, status, startedAt}` with `hit("invite-ip", ip, 20/15m)`.

- [ ] **Step 1: Add both endpoints to `openapi.yaml`.**
- [ ] **Step 2: Write failing `ClientSignupTest`:**
  - `clientSignupLinksToCoach`: 201; `$.user.role == "CLIENT"`, `PENDING`; `coach_client` row `ACTIVE`, `started_at` = clock; invite `USED`, `used_by_client_id` = new user; verification email sent.
  - `usedExpiredRevokedCodesRejected`: → 410 with matching codes; **no** `app_user` row created.
  - `duplicateEmailDoesNotConsumeInvite`: email taken → 409 `EMAIL_TAKEN`; invite still `PENDING`.
  - `concurrentSignupsWithSameCode`: two threads, different emails, same code, started together (`CountDownLatch`) → exactly one 201, the other 410 `INVITE_USED`; exactly one new client.
  - `clientWithoutCoachLinksWithCode`: client with only an `ENDED` relationship → `POST /me/coach-link` 201; now `ACTIVE` with the new coach.
  - `clientWithCoachCannotLink`: → 409 `ALREADY_HAS_COACH`; invite stays `PENDING`.
  - `pausedCountsAsCurrentCoach`: client with `PAUSED` relationship → 409 `ALREADY_HAS_COACH`.
  - `coachCannotUseCoachLink`: coach token → 403 `FORBIDDEN`.
  - `pendingClientIsNotRestricted`: `PENDING` client can call `POST /me/coach-link` (after ending its relationship) → 201.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: client signup with invite code and coach linking`.

---

### Task 13: Relationships, coach profile, `PATCH /me`

**Files:**
- Create: `client/RelationshipService.java`, `client/CoachProfileService.java`, `client/CoachClientController.java`, `client/CoachProfileController.java`; extend `client/MyCoachController.java`; DTOs `CoachClientResponse`, `ChangeRelationshipRequest`, `MyCoachResponse`, `CoachProfileResponse`, `UpdateCoachProfileRequest`, `UpdateMeRequest`
- Modify: `auth/AccountService.java`, `auth/MeController.java`, `openapi.yaml`
- Test: `client/RelationshipsTest.java`, `client/CoachProfileTest.java`, `auth/UpdateMeTest.java`

**Interfaces:**
- Consumes: `CoachClientRepository`, `RelationshipTransitions`, `CoachProfileRepository`, `AppUserRepository`.
- Produces:
  - `RelationshipService.listClients(CurrentUser coach) -> List<CoachClientResponse(UUID clientId, String firstName, String lastName, String email, RelationshipStatus status, Instant startedAt)>` ordered by last name, first name.
  - `RelationshipService.changeStatus(CurrentUser coach, UUID clientId, RelationshipStatus target) -> CoachClientResponse`: no current relationship between them → `404 CLIENT_NOT_FOUND`; `RelationshipTransitions.require`; `ENDED` sets `endedAt = now(clock)`.
  - `RelationshipService.myCoach(CurrentUser client) -> MyCoachResponse(UUID coachId, String firstName, String lastName, String bio, List<String> specializations, RelationshipStatus status, Instant startedAt)` or `404 NO_COACH`; `leave(CurrentUser client)` → current → `ENDED` or `404 NO_COACH`.
  - `CoachProfileService.get(CurrentUser) / update(CurrentUser, UpdateCoachProfileRequest(@Size(max=2000, message="TOO_LONG") String bio, @Size(max=20, message="TOO_MANY") List<@NotBlank @Size(max=50) String> specializations))` → `CoachProfileResponse(String bio, List<String> specializations)`.
  - `AccountService.updateMe(CurrentUser, UpdateMeRequest(String firstName, String lastName, @ValidLocale String locale, @ValidTimezone String timezone))` – all fields optional (null = unchanged), non-null names `@NotBlank @Size(max=100)` → `UserResponse`.
  - Routes: `GET /coach/clients`, `PATCH /coach/clients/{clientId}/relationship`, `GET /me/coach`, `DELETE /me/coach` (204), `GET|PATCH /coach/profile`, `PATCH /me`.

- [ ] **Step 1: Add the six operations to `openapi.yaml`.**
- [ ] **Step 2: Write failing tests:**
  - `RelationshipsTest.listsOnlyCurrentClients`: `ACTIVE` + `PAUSED` listed, `ENDED` and other coach's clients not.
  - `RelationshipsTest.pauseResumeEnd`: `ACTIVE→PAUSED` 200, `PAUSED→ACTIVE` 200, `→ENDED` 200 with `ended_at` set; afterwards `PATCH` → 404 `CLIENT_NOT_FOUND`.
  - `RelationshipsTest.invalidTransition`: `ACTIVE→ACTIVE` → 409 `INVALID_RELATIONSHIP_TRANSITION`.
  - `RelationshipsTest.otherCoachsClientIs404`.
  - `RelationshipsTest.clientSeesAndLeavesCoach`: `GET /me/coach` 200 with coach bio; `DELETE /me/coach` 204; `GET /me/coach` → 404 `NO_COACH`; coach's list no longer contains them.
  - `RelationshipsTest.clientCannotPause`: client token on `PATCH /coach/clients/...` → 403.
  - `CoachProfileTest.getAndUpdate`: PATCH bio + specializations → GET returns them; 21 specializations → 400 `TOO_MANY`.
  - `UpdateMeTest.partialUpdate`: change only `locale` to `ro` → names unchanged; subsequent error `detail` is Romanian; invalid timezone → 400 `INVALID_TIMEZONE`.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: coach–client relationship management, coach profile, PATCH /me`.

---

### Task 14: `ClientAccessPolicy`

**Files:**
- Create: `client/ClientAccessPolicy.java`
- Test: `client/ClientAccessPolicyTest.java` (unit, mocked repository), `client/ClientAccessPolicyIntegrationTest.java`

**Interfaces:**
- Consumes: `CoachClientRepository.findCurrentByCoachIdAndClientId`.
- Produces (for all later slices):
  - `ClientAccessPolicy.requireReadAccess(CurrentUser user, UUID clientId)`: passes if `user.role == CLIENT && user.id == clientId`, or `user.role == COACH` with a relationship `ACTIVE` or `PAUSED`; otherwise `ApiException(NOT_FOUND, "CLIENT_NOT_FOUND")`.
  - `ClientAccessPolicy.requireWriteAccess(CurrentUser user, UUID clientId)`: same, but a coach needs `ACTIVE`.
  - ADMIN always fails both.

- [ ] **Step 1: Write failing `ClientAccessPolicyTest`** – table of cases, each asserting pass or `CLIENT_NOT_FOUND`: client self read/write pass; client other read fail; coach ACTIVE read+write pass; coach PAUSED read pass, write fail; coach ENDED read fail; coach unrelated fail; admin read+write fail (even for an existing client).
- [ ] **Step 2: Write failing `ClientAccessPolicyIntegrationTest.matchesDatabaseState`:** real rows for ACTIVE / PAUSED / ENDED and two coaches, same matrix through the Spring bean.
- [ ] **Step 3: Run** – Expected: FAIL.
- [ ] **Step 4: Implement.**
- [ ] **Step 5: Run** – Expected: PASS.
- [ ] **Step 6: Commit** `feat: ClientAccessPolicy for client-data authorization`.

---

### Task 15: First ADMIN bootstrap

**Files:**
- Create: `auth/AdminBootstrap.java`
- Test: `auth/AdminBootstrapTest.java`

**Interfaces:**
- Consumes: `AppUserRepository`, `PasswordEncoder`, `EmailNormalizer`, `Clock`.
- Produces: `AdminBootstrap implements ApplicationRunner`, properties `app.admin.email`, `app.admin.password`. If `!existsByRole(ADMIN)`: both set → create ADMIN (`ACTIVE`, `emailVerifiedAt = now`, names `Admin`/`Admin`, locale `en`, timezone `UTC`), log INFO with the email only; not set → log WARN. Password must satisfy the password policy, else fail startup with a clear message.

- [ ] **Step 1: Write failing `AdminBootstrapTest`** (call `run(...)` on the bean with test properties, after table cleanup):
  - `createsAdminWhenNoneExists`: ADMIN row, `ACTIVE`, can log in via `POST /auth/login`.
  - `doesNothingWhenAdminExists`: second run with a different email → still exactly one ADMIN.
  - `skipsWhenNotConfigured`: properties empty → no ADMIN, no exception.
  - `rejectsWeakPassword`: `app.admin.password=short` → `IllegalStateException`.
- [ ] **Step 2: Run** – Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** – Expected: PASS.
- [ ] **Step 5: Commit** `feat: bootstrap first ADMIN from configuration`.

---

### Task 16: Contract check and final verification

**Files:**
- Test: `common/OpenApiContractCoverageTest.java`
- Modify: `docs/plans/brainstorm-wip.md` (status line only)

- [ ] **Step 1: Write `OpenApiContractCoverageTest.everyEndpointIsInContract`:** collect `(method, path)` pairs from `RequestMappingHandlerMapping` for `com.anafitlab.backend` controllers (prefix `/api/v1` stripped, path variables normalized to `{}`), parse `docs/api/openapi.yaml` (served file at `GET /openapi.yaml`; parse with SnakeYAML, which Spring Boot already ships; no new dependency), assert both sets are equal. Expected: PASS if every earlier task kept the contract in step.
- [ ] **Step 2: Run the full suite** `cd backend && ./mvnw test` – Expected: BUILD SUCCESS, 0 failures.
- [ ] **Step 3: Manual smoke run** with `docker compose up -d` and the `local` profile: sign up a coach via Swagger UI, open the verification email in Mailpit (`localhost:8025`), verify, create an invite, sign up a client with it, call `GET /me/coach` as the client.
- [ ] **Step 4: Update `docs/plans/brainstorm-wip.md`** status to "implemented – see plan".
- [ ] **Step 5: Commit** `test: contract coverage check for slice 1`.
