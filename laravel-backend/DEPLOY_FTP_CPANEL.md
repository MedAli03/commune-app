# Laravel API Deployment on cPanel (FTP/FileZilla, no SSH required)

## 1) Prerequisites
- PHP 8.2+ recommended.
- Extensions: `mbstring`, `openssl`, `pdo_mysql`, `tokenizer`, `xml`, `ctype`, `json`, `fileinfo`.
- MySQL database + user in cPanel.
- Apache `mod_rewrite` enabled.

## 2) API Contract kept for Flutter
- `GET /reports`
- `POST /reports`
- `GET /reports/{id}`
- `DELETE /reports/{id}`
- `GET /health`

## 3) Build locally before upload
1. In `laravel-backend/` run:
   - `composer install --no-dev --optimize-autoloader`
2. Ensure `vendor/` now exists locally.
3. Copy `.env.example` to `.env` and set DB credentials.
4. Generate key locally:
   - `php artisan key:generate`

> `vendor/` must be uploaded because target hosting may not allow SSH/composer.

## 4) Create DB + user in cPanel
1. cPanel → MySQL Databases.
2. Create database (example: `cpaneluser_commune`).
3. Create user + password.
4. Assign user to DB with ALL PRIVILEGES.

## 5) Upload using FileZilla (exact map)
See `deploy/laravel_api_upload/README_UPLOAD_MAP.md`.

### Variant A (preferred)
- Upload full `laravel-backend/` to `/home/CPANEL_USER/laravel_api/`
- Set subdomain document root to `/home/CPANEL_USER/laravel_api/public`

### Variant B (docroot fixed to `/public_html/api`)
- Upload `laravel-backend/public/*` to `/public_html/api/`
- Upload rest of app (excluding public assets duplicated above) to `/public_html/laravel_api/`
- Keep `/public_html/api/index.php` bootstrap paths referencing `../laravel_api`
- Keep deny rule in `/public_html/laravel_api/.htaccess`

## 6) Configure `.env`
Set at minimum:
- `APP_NAME=CommuneAPI`
- `APP_ENV=production`
- `APP_DEBUG=false`
- `APP_URL=https://YOUR_API_DOMAIN`
- `APP_KEY=base64:...` (from `php artisan key:generate` done locally)
- `DB_CONNECTION=mysql`
- `DB_HOST=localhost`
- `DB_PORT=3306`
- `DB_DATABASE=...`
- `DB_USERNAME=...`
- `DB_PASSWORD=...`
- `CORS_ALLOWED_ORIGINS=https://YOUR_ADMIN_DOMAIN,https://YOUR_FLUTTER_WEB_DOMAIN`

For local dev permissive mode, set:
- `CORS_ALLOWED_ORIGINS=*`

## 7) Database setup
### If SSH exists
- `php artisan migrate --force`

### If no SSH (common on shared hosting)
- Open phpMyAdmin and import:
  - `laravel-backend/database/schema/reports.sql`

## 8) Permissions
Set writable permissions for:
- `storage/`
- `bootstrap/cache/`

Recommended:
- directories `775` (or `755` if host requires)
- files `664` (or host default)

## 9) Common errors
### 500 error
- Missing/invalid `APP_KEY`
- Wrong folder permissions on `storage` or `bootstrap/cache`
- PHP version/extensions mismatch

### 404 on routes
- Missing `.htaccess` in public web folder
- Apache rewrite disabled
- Wrong document root (should point to Laravel `public` in Variant A)

### CORS errors
- Set `CORS_ALLOWED_ORIGINS` correctly
- Clear config cache if using artisan/cache workflow locally before upload

### DB connection errors
- Recheck DB host, name, user, password
- Confirm DB user has privileges on selected DB

## 10) Local verification
- `composer install`
- `php artisan serve`

Quick curl tests:
- `curl -i http://127.0.0.1:8000/api/health`
- `curl -i http://127.0.0.1:8000/api/reports`
- `curl -i -X POST http://127.0.0.1:8000/api/reports -H "Content-Type: application/json" -d '{"id":"11111111-1111-1111-1111-111111111111","title":"Broken streetlight","description":"Pole #14 is off","photoPath":null,"latitude":40.1,"longitude":-74.2,"createdAt":"2026-02-10T12:00:00Z"}'`
- `curl -i http://127.0.0.1:8000/api/reports/11111111-1111-1111-1111-111111111111`
- `curl -i -X DELETE http://127.0.0.1:8000/api/reports/11111111-1111-1111-1111-111111111111`
