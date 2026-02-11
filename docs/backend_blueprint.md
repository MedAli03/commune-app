# Backend Reverse-Engineering Blueprint (from Flutter frontend)

## One-page summary

This Flutter app is a municipal issue-reporting client with offline-first behavior via Hive local storage and best-effort API sync. The app starts at `HomeScreen`, allows users to create a report (title, description, optional photo path, optional geolocation), and browse/view saved reports. Data is persisted locally in a Hive box (`reports`) and synchronized with a backend over JSON HTTP. Network usage is intentionally thin and currently limited to `GET /reports`, `GET /reports/{id}` (defined, not currently used by UI), and `POST /reports`. There is no frontend auth token flow yet; API headers are `Content-Type: application/json` and `Accept: application/json` only.

From backend perspective, a Laravel API should expose a `reports` resource with predictable JSON field names matching the `Report` model (`id`, `title`, `description`, `photoPath`, `latitude`, `longitude`, `createdAt`) to avoid frontend breakage. Error payloads should include `message` and optionally `details[]` because the API client formats those specifically. Since frontend keeps generating UUID IDs client-side and may replace local IDs after create, backend should accept client IDs but may also return canonical IDs. The UI tolerates sync failures (they are logged, not blocking) and still keeps local data.

---

## 1) App Map

### Screens/pages and navigation routes

The app uses imperative `Navigator.push` / `pushReplacement` with `MaterialPageRoute` (not named route strings).

1. **App shell / entrypoint**
   - `main()` initializes Hive, registers `ReportAdapter`, opens `reports` box, then runs `App`.  
   - Files/functions: `lib/main.dart::main`, `lib/app.dart::_AppState.build`.

2. **Home screen** (`HomeScreen`)
   - Set as `MaterialApp.home`.
   - Actions:
     - Toggle locale EN/AR.
     - Navigate to create report form.
     - Navigate to reports list.
   - Files/functions: `lib/app.dart::_AppState.build`, `lib/screens/home_screen.dart::_HomeScreenState.build`.

3. **Create report screen** (`CreateReportScreen`)
   - Form with title/description validation, image pick (camera/gallery), location capture, confirm dialog, save action.
   - On successful save flow, does `pushReplacement` to reports list screen.
   - Files/functions: `lib/screens/create_report_screen.dart::_CreateReportScreenState.build`, `_confirmSaveReport`, `_saveReport`.

4. **Reports list screen** (`ReportsListScreen`)
   - On init, triggers `syncFromServer()`.
   - Renders live Hive box values via `ValueListenableBuilder`.
   - Tapping an item opens report details.
   - Files/functions: `lib/screens/reports_list_screen.dart::initState`, `build`.

5. **Report details screen** (`ReportDetailsScreen`)
   - Displays report fields and image preview if local path exists.
   - Files/functions: `lib/screens/report_details_screen.dart::build`.

### State management and where network calls happen

- **State management style**
  - Local widget `State` via `setState` in `App`, `CreateReportScreen`, `ReportsListScreen`.
  - Persistent local state via Hive box `reports`.
  - UI list reactivity via `ValueListenableBuilder(box.listenable())`.

- **Data flow**
  - UI -> `ReportsRepository` -> `ReportsApi` -> `ApiClient` -> HTTP.
  - `ReportsRepository` also writes/reads Hive for offline-first behavior.

- **Network calls occur in**
  - `ReportsApi.fetchReports()` => GET list.
  - `ReportsApi.fetchReportById(id)` => GET single (defined but not consumed by current screens).
  - `ReportsApi.createReport(report)` => POST create.

### Key folders and responsibilities

- `lib/screens`: UI screens and navigation.
- `lib/models`: Domain entities and JSON/Hive mapping (`Report`).
- `lib/repositories`: Data orchestration between API and local storage (`ReportsRepository`).
- `lib/api`: Base URL config, generic HTTP client/error handling, reports endpoints.
- `lib/storage`: Hive box names/constants.
- `lib/services`: Device integrations (location permissions + image picking).
- `lib/localization` + `lib/l10n`: localization glue and ARB strings.
- `lib/utils`: validators and platform-specific image helpers.

---

## 2) API Contract (observed + inferred)

### Global API behavior

- **Base URL selection**
  - Web default: `http://localhost:3000`
  - Mobile default: `http://10.0.2.2:3000`
  - `baseUrl` switches by `kIsWeb`.

- **Headers on all HTTP calls**
  - `Content-Type: application/json`
  - `Accept: application/json`
  - No auth header and no language header currently.

- **Error handling**
  - Any non-2xx throws exception in `ApiClient`.
  - Error message extraction priority:
    1. `{"message": "...", "details": [...]}` -> includes details.
    2. `{"message": "..."}` -> message only.
    3. raw body fallback.
  - Repository catches sync/create network errors and logs them; UI generally continues.

---

### Endpoint A: List reports

- **Purpose**: Fetch all reports for list synchronization.
- **Frontend function(s)**: `ReportsApi.fetchReports()` used by `ReportsRepository.syncFromServer()` and triggered by `ReportsListScreen.initState()`.
- **Method + URL**: `GET {baseUrl}/reports`.
- **Headers**: JSON headers only.
- **Request body**: none.
- **Response schema expected by frontend**: top-level JSON array of objects:
  - `id: string`
  - `title: string`
  - `description: string`
  - `photoPath: string|null`
  - `latitude: number|null`
  - `longitude: number|null`
  - `createdAt: string(datetime) | number(epoch ms) | DateTime-like`
- **Status/error paths**:
  - `2xx` with array -> parsed and mapped.
  - Non-2xx -> exception; repository logs `Sync failed` and continues.
  - `2xx` but non-array body -> exception `Unexpected response format.` then same repository catch path.

### Endpoint B: Get report by id

- **Purpose**: Fetch one report details (API path exists in code, not currently called by screens).
- **Frontend function(s)**: `ReportsApi.fetchReportById(String id)`.
- **Method + URL**: `GET {baseUrl}/reports/{id}`.
- **Headers**: JSON headers only.
- **Request body**: none.
- **Response schema expected**: top-level JSON object with same `Report` fields as above.
- **Status/error paths**:
  - `2xx` + object -> parsed to `Report`.
  - Non-2xx or non-object `2xx` -> exception from `ApiClient`.
- **Usage status**: defined but currently unused by repository/screens.

### Endpoint C: Create report

- **Purpose**: Persist a newly created report to server and reconcile local cache.
- **Frontend function(s)**: `ReportsApi.createReport(Report report)` called by `ReportsRepository.createReportAndSync()` from `CreateReportScreen._saveReport()`.
- **Method + URL**: `POST {baseUrl}/reports`.
- **Headers**: JSON headers only.
- **Request body schema** (`Report.toJson()`):
  - `id: string` (UUID generated on client)
  - `title: string`
  - `description: string`
  - `photoPath: string|null`
  - `latitude: number|null`
  - `longitude: number|null`
  - `createdAt: string` (ISO-8601 UTC)
- **Response schema expected**: top-level JSON object with same report fields.
  - If returned `id` differs from local id, repository deletes old local key and stores server object.
- **Status/error paths**:
  - `2xx` -> parsed and saved/merged into Hive.
  - Non-2xx -> exception; repository logs `Create report sync failed`; local optimistic record remains in Hive.

### INFERRED endpoints (not explicit, but recommended for full REST)

The frontend currently does not call update/delete endpoints. For production completeness, likely future REST endpoints:

- `PUT/PATCH /reports/{id}` *(INFERRED)*
- `DELETE /reports/{id}` *(INFERRED)*

These are inferred from resource naming and typical CRUD expansion.

---

## 3) Domain Model Extraction

### Entity: Report

Fields observed in model + serialization:
- `id: String` (required)
- `title: String` (required)
- `description: String` (required)
- `photoPath: String?` (optional; local file path URI/string)
- `latitude: double?` (optional)
- `longitude: double?` (optional)
- `createdAt: DateTime` (required)

Validation constraints implied by UI:
- `title`: required, min length 5.
- `description`: required, min length 10.
- location/photo optional.

Date parsing tolerance in frontend:
- Accepts `createdAt` as ISO string, numeric epoch milliseconds, or DateTime object (if same runtime).

### Relationships

- No explicit relational links in frontend model (single-entity app in current code).
- No user/account relation referenced by code.

---

## 4) Laravel Backend Blueprint

### A) `routes/api.php` proposal (grouped by resource)

```php
use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

Route::prefix('reports')->group(function () {
    Route::get('/', [ReportController::class, 'index']);
    Route::post('/', [ReportController::class, 'store']);
    Route::get('/{report}', [ReportController::class, 'show']);

    // Optional future expansion (INFERRED)
    Route::patch('/{report}', [ReportController::class, 'update']);
    Route::delete('/{report}', [ReportController::class, 'destroy']);
});
```

### B) DB schema proposal

#### `reports` table

- `id` UUID primary key (string-compatible with client-generated UUID).
- `title` varchar(255) not null.
- `description` text not null.
- `photo_path` text nullable.
- `latitude` decimal(10,7) nullable.
- `longitude` decimal(10,7) nullable.
- `created_at_client` timestamp nullable (to preserve client-sent createdAt if needed).
- Laravel `created_at` / `updated_at` timestamps.

Notes:
- Frontend expects camelCase JSON. Use API Resources or attribute casts/accessors to expose `photoPath` + `createdAt`.
- If backend canonicalizes IDs, still return final `id` in create response.

### C) Laravel app structure

- `app/Http/Controllers/Api/ReportController.php`
  - `index()`, `show()`, `store()`, optional `update()`, `destroy()`.
- `app/Http/Requests/StoreReportRequest.php`
  - Validate:
    - `id`: nullable|uuid (or required if honoring client ID strictly)
    - `title`: required|string|min:5|max:255
    - `description`: required|string|min:10
    - `photoPath`: nullable|string
    - `latitude`: nullable|numeric|between:-90,90
    - `longitude`: nullable|numeric|between:-180,180
    - `createdAt`: nullable|date
- `app/Http/Requests/UpdateReportRequest.php` (optional future)
- `app/Services/ReportService.php`
  - Encapsulate create/upsert + mapping between camelCase payload and snake_case columns.
- `app/Http/Resources/ReportResource.php`
  - Normalize output keys exactly for Flutter contract.

### D) Auth recommendation

Current frontend sends **no auth headers**. Best compatibility options:

1. **Phase 1 (match current app):** Keep reports endpoints public within trusted network/dev env.
2. **Phase 2 (recommended hardening):** Add Laravel Sanctum token auth.
   - Update Flutter `ApiClient._jsonHeaders()` to include `Authorization: Bearer <token>` once login exists.

Also consider CORS config to allow Flutter web origin.

### E) Error response contract to match frontend parser

For non-2xx responses, return:

```json
{
  "message": "Validation failed",
  "details": ["title is required", "description min length is 10"]
}
```

`details` array is optional but leveraged by frontend error formatter.

---

## 5) OpenAPI 3.0 YAML draft

```yaml
openapi: 3.0.3
info:
  title: Commune Reports API
  version: 0.1.0
servers:
  - url: http://localhost:3000
    description: Local development
paths:
  /reports:
    get:
      summary: List reports
      operationId: listReports
      responses:
        '200':
          description: Report list
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Report'
        '500':
          $ref: '#/components/responses/ErrorResponse'
    post:
      summary: Create report
      operationId: createReport
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReportCreateRequest'
      responses:
        '201':
          description: Created report
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Report'
        '200':
          description: Created report (legacy success code tolerated by client)
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Report'
        '422':
          $ref: '#/components/responses/ErrorResponse'
        '500':
          $ref: '#/components/responses/ErrorResponse'
  /reports/{id}:
    get:
      summary: Get report by id
      operationId: getReport
      parameters:
        - in: path
          name: id
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Report found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Report'
        '404':
          $ref: '#/components/responses/ErrorResponse'
        '500':
          $ref: '#/components/responses/ErrorResponse'
    patch:
      summary: Update report (INFERRED)
      operationId: updateReport
      parameters:
        - in: path
          name: id
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReportUpdateRequest'
      responses:
        '200':
          description: Updated report
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Report'
        '404':
          $ref: '#/components/responses/ErrorResponse'
        '422':
          $ref: '#/components/responses/ErrorResponse'
    delete:
      summary: Delete report (INFERRED)
      operationId: deleteReport
      parameters:
        - in: path
          name: id
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Deleted
        '404':
          $ref: '#/components/responses/ErrorResponse'
components:
  schemas:
    Report:
      type: object
      required:
        - id
        - title
        - description
        - createdAt
      properties:
        id:
          type: string
          example: 9d4698f1-2d11-45c8-89f4-b3f2a28f0d43
        title:
          type: string
          minLength: 5
        description:
          type: string
          minLength: 10
        photoPath:
          type: string
          nullable: true
          description: Client photo path or URL
        latitude:
          type: number
          format: double
          nullable: true
        longitude:
          type: number
          format: double
          nullable: true
        createdAt:
          type: string
          format: date-time
    ReportCreateRequest:
      type: object
      required:
        - title
        - description
      properties:
        id:
          type: string
          format: uuid
          description: Optional client-generated UUID
        title:
          type: string
          minLength: 5
        description:
          type: string
          minLength: 10
        photoPath:
          type: string
          nullable: true
        latitude:
          type: number
          format: double
          nullable: true
        longitude:
          type: number
          format: double
          nullable: true
        createdAt:
          type: string
          format: date-time
          nullable: true
    ReportUpdateRequest:
      type: object
      properties:
        title:
          type: string
          minLength: 5
        description:
          type: string
          minLength: 10
        photoPath:
          type: string
          nullable: true
        latitude:
          type: number
          format: double
          nullable: true
        longitude:
          type: number
          format: double
          nullable: true
    ErrorPayload:
      type: object
      properties:
        message:
          type: string
        details:
          type: array
          items:
            type: string
  responses:
    ErrorResponse:
      description: Error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorPayload'
```
