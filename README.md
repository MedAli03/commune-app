# Commune App

Flutter + Node/Express + MySQL app for creating and syncing municipal issue
reports.

## Repository layout

- `lib/`: Flutter client
- `backend/`: Node/Express API
- `backend/sql/`: MySQL schema and seed files

## Backend setup (MySQL + API)

1) Create the database + tables:

```bash
mysql -u root < backend/sql/001_create_tables.sql
mysql -u root < backend/sql/002_reports_contract_alignment.sql
```

Optional seed data:

```bash
mysql -u root < backend/sql/003_seed_reports.sql
```

2) Start the API server:

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

The API defaults to `http://localhost:3000`.

## Flutter setup

The client uses a single base URL in `lib/api/api_config.dart`.

- Android emulator: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Physical device: use your machine's LAN IP, e.g. `http://192.168.1.20:3000`

Update the `baseUrl` constant accordingly.
