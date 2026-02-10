# MIGRATION PLAN

## 1) Endpoint contract table

| Method | Path | Request | Response | Status codes |
|---|---|---|---|---|
| GET | `/health` | none | `{ "ok": true, "db": true }` | 200, 500 |
| GET | `/reports` | none | `[{ id, title, description, photoPath, latitude, longitude, createdAt }]` | 200, 500 |
| GET | `/reports/{id}` | none | `{ id, title, description, photoPath, latitude, longitude, createdAt }` | 200, 404, 500 |
| POST | `/reports` | `{ id, title, description, photoPath?, latitude?, longitude?, createdAt? }` | created report object | 201, 400, 500 |
| DELETE | `/reports/{id}` | none | empty body | 204, 404, 500 |

## 2) Report fields mapping (Flutter ↔ backend)
- `id` (String, required)
- `title` (String, required)
- `description` (String, required)
- `photoPath` (String?, optional)
- `latitude` (double?, optional)
- `longitude` (double?, optional)
- `createdAt` (ISO-8601 String, optional)

## 3) DB schema plan
- `reports` table
  - `id VARCHAR(36) PRIMARY KEY`
  - `title VARCHAR(255) NOT NULL`
  - `description TEXT NOT NULL`
  - `photo_path TEXT NULL`
  - `latitude DOUBLE NULL`
  - `longitude DOUBLE NULL`
  - `created_at DATETIME DEFAULT CURRENT_TIMESTAMP`
  - `updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP`

## 4) cPanel + FTP deployment strategy
### Variant A (preferred)
- Point subdomain document root to Laravel `public/`.

### Variant B (workaround)
- Public endpoint in `public_html/api`.
- App files in `public_html/laravel_api`.
- `public_html/api/index.php` bootstraps `../laravel_api`.
- Keep deny rule in `public_html/laravel_api/.htaccess`.
