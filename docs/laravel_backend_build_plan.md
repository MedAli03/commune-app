# Laravel Backend Build Plan (Discovery Only)

## Scope + discovery summary

- Source of truth reviewed: `docs/backend_blueprint.md`.
- Supporting docs reviewed: `docs/integration_notes.md`.
- Frontend API usage reviewed in `lib/api/*`, `lib/models/report.dart`, and `lib/repositories/reports_repository.dart`.
- This is a **design/discovery artifact only** (no backend implementation in this step).

## 1) Repo structure (root folders)

- `.git`
- `android`
- `docs`
- `ios`
- `lib`
- `linux`
- `macos`
- `test`
- `web`
- `windows`

## 2) Frontend API usage cross-check (actual usage)

### Network stack and base URL

- HTTP client: Dart `package:http/http.dart`.
- Base URL logic:
  - Web: `http://localhost:3000`
  - Mobile: `http://10.0.2.2:3000`
- Endpoints built in frontend:
  - `GET /reports`
  - `GET /reports/{id}`
  - `POST /reports`

### Headers/auth

- Sent on all requests:
  - `Content-Type: application/json`
  - `Accept: application/json`
- No auth headers/tokens currently.

### Payload/field names frontend actually uses

- Entity fields (camelCase):
  - `id`
  - `title`
  - `description`
  - `photoPath`
  - `latitude`
  - `longitude`
  - `createdAt`
- Error payload parsing expectations:
  - `message` (string)
  - optional `details` (array of strings)

---

## A) API Contract Table

| Endpoint | Method | Auth | Request | Success Response | Error Response |
|---|---|---|---|---|---|
| `/reports` | GET | None (current frontend) | None | `200` + JSON array of Report objects | Non-2xx with `{ "message": string, "details"?: string[] }` |
| `/reports/{id}` | GET | None | Path param `id` (string/uuid) | `200` + single Report object | `404` / other non-2xx with same error shape |
| `/reports` | POST | None | ReportCreate JSON (frontend currently sends full Report incl `id`, `createdAt`) | `201` preferred (or `200` tolerated by frontend) + Report | `422` validation or other non-2xx with same error shape |
| `/reports/{id}` *(inferred for completeness)* | PATCH | None (phase 1), token later | Partial Report fields | `200` + updated Report | `404`, `422`, others with same error shape |
| `/reports/{id}` *(inferred for completeness)* | DELETE | None (phase 1), token later | None | `204` no content | `404` or other non-2xx with same error shape |

### Example JSON (top 5 endpoints)

1) `GET /reports` response (`200`)

```json
[
  {
    "id": "9d4698f1-2d11-45c8-89f4-b3f2a28f0d43",
    "title": "Broken streetlight",
    "description": "Streetlight has been off for three nights.",
    "photoPath": null,
    "latitude": 24.7136,
    "longitude": 46.6753,
    "createdAt": "2026-02-13T08:10:00Z"
  }
]
```

2) `GET /reports/{id}` response (`200`)

```json
{
  "id": "9d4698f1-2d11-45c8-89f4-b3f2a28f0d43",
  "title": "Broken streetlight",
  "description": "Streetlight has been off for three nights.",
  "photoPath": "https://cdn.example.com/reports/9d4698f1/photo.jpg",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "createdAt": "2026-02-13T08:10:00Z"
}
```

3) `POST /reports` request

```json
{
  "id": "client-generated-uuid",
  "title": "Pothole near school",
  "description": "Large pothole causing traffic issues.",
  "photoPath": "/storage/emulated/0/Pictures/pothole.jpg",
  "latitude": 24.7200,
  "longitude": 46.6800,
  "createdAt": "2026-02-13T09:00:00Z"
}
```

`POST /reports` response (`201`)

```json
{
  "id": "server-canonical-or-client-uuid",
  "title": "Pothole near school",
  "description": "Large pothole causing traffic issues.",
  "photoPath": "https://cdn.example.com/reports/server-canonical-or-client-uuid/pothole.jpg",
  "latitude": 24.7200,
  "longitude": 46.6800,
  "createdAt": "2026-02-13T09:00:00Z"
}
```

4) `PATCH /reports/{id}` request/response (inferred)

```json
{
  "status": "in_progress",
  "description": "Crew assigned and site inspected."
}
```

```json
{
  "id": "9d4698f1-2d11-45c8-89f4-b3f2a28f0d43",
  "title": "Broken streetlight",
  "description": "Crew assigned and site inspected.",
  "photoPath": null,
  "latitude": 24.7136,
  "longitude": 46.6753,
  "createdAt": "2026-02-13T08:10:00Z"
}
```

> Note: `status` is not currently used by frontend and should be deferred unless explicitly added to frontend contract.

5) `DELETE /reports/{id}` response (`204`)

```json
{}
```

### Standard error payload example

```json
{
  "message": "Validation failed",
  "details": [
    "title field is required",
    "description must be at least 10 characters"
  ]
}
```

---

## B) DB Model summary

## Core table

### `reports`

- `id` UUID primary key (supports frontend client-generated UUID).
- `title` string(255), not null.
- `description` text, not null.
- `photo_path` text, nullable.
- `latitude` decimal(10,7), nullable, constrained to -90..90.
- `longitude` decimal(10,7), nullable, constrained to -180..180.
- `created_at` timestamp (Laravel managed, also used to map API `createdAt`).
- `updated_at` timestamp.
- Optional if preserving client timestamp separately: `created_at_client` timestamp nullable.

## Relationships

- None required for phase 1 (frontend has only standalone Report entity).
- Future-safe extension: `reports.user_id -> users.id` can be added when auth is introduced.

## Constraints/indexes

- PK: `reports.id` (UUID).
- Optional index: `(created_at)` for sorting recent reports.
- Optional geospatial optimization later if map queries are added.

## MySQL runtime assumptions (phase 2)

- `DB_CONNECTION=mysql` in `.env`.
- MySQL connection should keep Laravel defaults: `charset=utf8mb4`, `collation=utf8mb4_unicode_ci`, `strict=true`.
- These defaults are required for predictable validation and Unicode-safe text storage.

---

## C) Auth / Roles

## Guards and middleware

- **Phase 1 (frontend compatibility first):**
  - Guard: default `api` without token requirement for `/reports` read/create.
  - Middleware: `api` + throttling.
- **Phase 2 (hardening):**
  - Laravel Sanctum for token auth.
  - Apply `auth:sanctum` on write endpoints first (`POST/PATCH/DELETE`).

## Roles matrix (future-safe)

| Capability | Guest (phase 1) | Reporter | Admin |
|---|---:|---:|---:|
| List reports | ✅ | ✅ | ✅ |
| View report | ✅ | ✅ | ✅ |
| Create report | ✅ (phase 1) | ✅ | ✅ |
| Update report | ❌ (phase 1) | Own only | ✅ |
| Delete report | ❌ (phase 1) | Own only (optional) | ✅ |

Safest default for now: keep currently used endpoints unauthenticated to avoid breaking existing frontend.

---

## D) File uploads

Current frontend sends `photoPath` as a string in JSON and does **not** upload multipart binaries yet.

### Phase 1 (non-breaking)

- Accept `photoPath` as nullable string.
- Persist as-is in DB/API (`photoPath` <-> `photo_path`).

### Phase 2 (recommended)

- Add dedicated upload endpoint (e.g., `POST /reports/{id}/attachments`) only when frontend adds multipart support.
- Laravel disk: `public` or S3-compatible disk via `FILESYSTEM_DISK`.
- Suggested storage path: `reports/{report_id}/{uuid}.{ext}`.
- MIME allowlist: `image/jpeg`, `image/png`, `image/webp`.
- Size limit: 5 MB per image.

---

## E) Laravel implementation mapping

## `routes/api.php` groups

- `Route::prefix('reports')->group(...)`:
  - `GET /` -> `ReportController@index`
  - `POST /` -> `ReportController@store`
  - `GET /{report}` -> `ReportController@show`
  - (optional later) `PATCH /{report}`, `DELETE /{report}`

## Form Requests

- `StoreReportRequest`
  - `id`: `nullable|uuid`
  - `title`: `required|string|min:5|max:255`
  - `description`: `required|string|min:10`
  - `photoPath`: `nullable|string`
  - `latitude`: `nullable|numeric|between:-90,90`
  - `longitude`: `nullable|numeric|between:-180,180`
  - `createdAt`: `nullable|date`
- `UpdateReportRequest` (for future PATCH)

## Controllers

- `App\Http\Controllers\Api\ReportController`
  - `index`, `show`, `store` (plus optional `update`, `destroy`)

## Services

- `ReportService`
  - payload mapping camelCase <-> snake_case
  - create/upsert rules for client-generated UUID

## Repositories

- Optional `ReportRepository` if team prefers repository pattern.
- If used, keep Eloquent queries out of controller/service.

## Policies / Gates

- Not required in phase 1 (public endpoints).
- Add `ReportPolicy` in phase 2 once user ownership/roles are introduced.

## API Resources (transformers)

- `ReportResource` to enforce exact JSON keys expected by Flutter:
  - `photoPath`
  - `createdAt` (ISO-8601)

## Migration + Seeder plan

- Create `reports` migration with UUID PK and columns above.
- Optional seeder with 5-10 realistic reports for integration testing.

---

## 3) Tasked execution plan (no implementation yet)

## Task 1 — Initialize Laravel API skeleton

**Acceptance criteria**
- Fresh Laravel project created in backend folder.
- API route file is reachable.

**Commands**

```bash
composer create-project laravel/laravel backend
cd backend
php artisan --version
php artisan route:list
```

## Task 2 — Configure environment and DB

**Acceptance criteria**
- `.env` has database + app URL + CORS settings aligned with Flutter targets.
- DB connection validates.

**Commands**

```bash
cp .env.example .env
php artisan key:generate
php artisan migrate:status
```

## Task 3 — Create Report persistence layer

**Acceptance criteria**
- `reports` migration exists with UUID PK and required columns.
- Model configured for UUID primary keys.

**Commands**

```bash
php artisan make:model Report -m
php artisan migrate
```

## Task 4 — Build request validation + resource transform

**Acceptance criteria**
- `StoreReportRequest` validates frontend payload contract.
- `ReportResource` returns camelCase fields exactly.

**Commands**

```bash
php artisan make:request StoreReportRequest
php artisan make:resource ReportResource
```

## Task 5 — Implement API controller and routes

**Acceptance criteria**
- `GET /reports`, `GET /reports/{id}`, `POST /reports` functional.
- Non-2xx errors return `{message, details?}` format.

**Commands**

```bash
php artisan make:controller Api/ReportController
php artisan route:list --path=api
```

## Task 6 — Add service layer (+ optional repository)

**Acceptance criteria**
- Business logic not duplicated in controller.
- ID reconciliation behavior defined (accept client ID, return canonical ID).

**Commands**

```bash
php artisan make:class Services/ReportService
# Optional pattern:
php artisan make:class Repositories/ReportRepository
```

## Task 7 — Seed/test contract compatibility

**Acceptance criteria**
- Feature tests cover index/show/store and error payload format.
- Responses are parseable by current Flutter model.

**Commands**

```bash
php artisan make:seeder ReportSeeder
php artisan make:test ReportApiTest
php artisan db:seed --class=ReportSeeder
php artisan test
```

## Task 8 — Optional auth hardening (phase 2)

**Acceptance criteria**
- Sanctum installed and configured.
- Protected write endpoints without breaking read compatibility plan.

**Commands**

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

---

## 4) Top risks + mitigations

1. **Contract drift (camelCase vs snake_case).**
   - Mitigation: enforce `ReportResource` and contract tests.
2. **ID mismatch (client UUID vs backend-generated).**
   - Mitigation: allow nullable client ID; always return final ID in create response.
3. **createdAt parsing inconsistencies.**
   - Mitigation: always return ISO-8601 UTC string in API resource.
4. **Auth introduced too early breaks frontend.**
   - Mitigation: keep phase-1 endpoints public; gate auth behind explicit frontend update.
5. **Photo handling ambiguity (path string vs file upload).**
   - Mitigation: treat `photoPath` as string now; add multipart endpoint later.

---

## READY FOR IMPLEMENTATION

**READY FOR IMPLEMENTATION: yes**

No blocking missing information for phase-1 report endpoints.

Optional clarifications before phase 2:
- canonical policy for report ownership,
- whether backend should store client `createdAt` separately,
- final choice for image storage (local/public vs object storage).
