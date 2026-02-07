# Commune App Backend

Node.js + Express + MySQL REST API for syncing reports with the Flutter app.

## Prerequisites

- Node.js 18+
- MySQL running locally

## Environment

Copy `.env.example` to `.env` and adjust if needed:

```bash
cp .env.example .env
```

## Database setup

Run the SQL schema to create the database and tables:

```bash
mysql -u root < sql/001_create_tables.sql
mysql -u root < sql/002_reports_contract_alignment.sql
```

If your MySQL instance needs a host/port:

```bash
mysql -h localhost -P 3306 -u root < sql/001_create_tables.sql
mysql -h localhost -P 3306 -u root < sql/002_reports_contract_alignment.sql
```

Optional seed data:

```bash
mysql -u root < sql/003_seed_reports.sql
```

## Install and run

```bash
npm install
npm run dev
```

The server defaults to `http://localhost:3000`.

## API examples

Health check:

```bash
curl http://localhost:3000/health
```

Create a report:

```bash
curl -X POST http://localhost:3000/reports \
  -H "Content-Type: application/json" \
  -d '{
    "id": "b6f5d9b3-0b5a-4aef-b2fd-3e13b8dc0a1a",
    "title": "Broken streetlight",
    "description": "The streetlight on 3rd Ave is out.",
    "photoPath": null,
    "latitude": 40.7128,
    "longitude": -74.006,
    "createdAt": "2024-01-20T10:30:00.000Z"
  }'
```

List reports:

```bash
curl http://localhost:3000/reports
```

Fetch a report by id:

```bash
curl http://localhost:3000/reports/b6f5d9b3-0b5a-4aef-b2fd-3e13b8dc0a1a
```

Update a report:

```bash
curl -X PUT http://localhost:3000/reports/b6f5d9b3-0b5a-4aef-b2fd-3e13b8dc0a1a \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Streetlight still broken"
  }'
```

Delete a report:

```bash
curl -X DELETE http://localhost:3000/reports/b6f5d9b3-0b5a-4aef-b2fd-3e13b8dc0a1a
```

## Notes

- Photo upload is not implemented; `photoPath` is stored as a string.
- The API uses camelCase JSON while the database uses snake_case columns.
- Errors use `{ "message": "...", "details": [...] }`.
