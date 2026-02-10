# UPLOAD MAP (FileZilla)

## Variant A (preferred)
- Local: `laravel-backend/` (full Laravel app, including `vendor/`)
- Remote: any path outside web root if possible, e.g. `/home/CPANEL_USER/laravel_api/`
- cPanel Subdomain Document Root: `/home/CPANEL_USER/laravel_api/public`

## Variant B (workaround)
- Local: `laravel-backend/public/*` -> Remote: `/public_html/api/`
- Local: `laravel-backend/` except `public/` -> Remote: `/public_html/laravel_api/`
- Ensure `/public_html/api/index.php` points to `../laravel_api/...`

## Important
- Upload `vendor/` (do NOT skip it). Server has no composer access.
