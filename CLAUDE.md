# Ana Fit Lab

Platform where coaches manage clients: workout plans, meal plans, food diary, progress tracking, calendar, real-time chat.
Web first (Flutter web), then iOS and Android from the same Flutter codebase.

## Source of truth
- Domain model: `docs/domain-model.md` (read it before touching any entity). Do not change entities or relations without proposing the change to me first and updating that document.
- API contract: `docs/api/openapi.yaml`. Define or update the endpoint here BEFORE implementing it.

## Stack
- Backend (`backend/`): Java 21, Spring Boot 4 (4.1.1), Spring Security (JWT), Spring Data JPA, PostgreSQL, Flyway, Spring WebSocket (STOMP), springdoc-openapi
- Frontend (`app/`): Flutter (web first), Riverpod, go_router, API client generated from `openapi.yaml`
- Tests: JUnit 5 + Testcontainers (backend), flutter_test (frontend)
- Local infra: `docker-compose.yml` (PostgreSQL, Mailpit; MinIO for progress photos is added from slice 2)
- Dependencies beyond the Initializr set: `spring-boot-starter-validation` (DTO validation), `spring-boot-starter-mail` (verification/reset emails), springdoc-openapi 3.x (Swagger UI for the hand-written contract)

## Repo layout
```
backend/   Spring Boot app (package by feature: auth, client, workout, nutrition, calendar, messaging, admin)
app/       Flutter app (organized by feature, not by layer)
docs/      domain-model.md, api/openapi.yaml
```

## Rules
- Schema changes ONLY through Flyway migrations (`backend/src/main/resources/db/migration`, `V<n>__description.sql`). `spring.jpa.hibernate.ddl-auto=validate`. Never edit an already-applied migration; add a new one.
- Layers: Controller -> Service -> Repository. No business logic in controllers. Controllers use DTOs, never JPA entities.
- IDs are UUIDs. Timestamps are `timestamptz` in UTC. Units in the DB are metric (kg, cm, g, kcal).
- The `user` table is named `app_user` (reserved word in PostgreSQL).
- Enums are `varchar` + CHECK constraints, not native Postgres enums.
- Every new endpoint ships with integration tests (Testcontainers). Formula/calculation code also needs unit tests.
- Commit after each working feature, with a clear message. Keep changes small and focused.

## Business rules (do not break)
- Roles: `COACH`, `CLIENT`, `ADMIN`. One role per user.
- A client has exactly ONE current coach (partial unique index on `coach_client`).
- Authorization: a coach can access only the data of clients linked to them through an active `coach_client`. A client can access only their own data. ADMIN does NOT see client data (photos, measurements, messages).
- Plans: a template (`is_template = true`) is deep-copied per client and then edited. Editing the copy never changes the template.
- Immutability: a `workout` with status `COMPLETED` (and its exercises and sets) can never be modified. Plan edits affect only PLANNED/future workouts. Enforce in the service layer and test it.
- Recipes in meal plans: when a recipe is placed in a meal, its ingredients are COPIED into `meal_recipe_ingredient`. The client may remove, change grams, or add ingredients. The original recipe stays unchanged. The coach can see the changes (no approval needed) and gets a `RECIPE_CUSTOMIZED` notification.
- Nutrition: macros only (kcal, protein, carbs, fat). Food diary entries store a nutrient SNAPSHOT at logging time.
- BMR formulas: all supported, chosen per client (`client_profile.bmr_formula`). Katch-McArdle and Cunningham require body fat %; return a clear validation error if it is missing.
- Barcode flow: local lookup -> external source (Open Food Facts) -> manual entry. Imported items get `source = IMPORT`.
- Feedback: only the client rates a COMPLETED workout, 1-5 stars, one per workout.
- Chat: WebSocket (STOMP). Verify JWT at handshake and verify `coach_client` membership on every subscribe/send. Persist the message before delivering it.
- Languages: Romanian and English. UI strings go through localization files. Global foods/exercises use translation tables (`*_translation`).
- Account deletion: when a client deletes their account, ALL their data is permanently deleted (see section 8.2 of the domain model), including progress photos in storage. No soft delete for client data.
- Progress photos: private storage, served only through short-lived signed URLs.

## Commands
- Start DB/storage: `docker compose up -d`
- Run backend: `cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local`
- Backend tests: `cd backend && ./mvnw test`
- Run Flutter web: `cd app && flutter run -d chrome`
- Flutter tests: `cd app && flutter test`

## How I want you to work
- For any non-trivial task, propose a short plan first and wait for my approval before writing code.
- If something in the domain model is ambiguous or conflicts with the task, ask me instead of guessing.
- Do not add dependencies without telling me why.
