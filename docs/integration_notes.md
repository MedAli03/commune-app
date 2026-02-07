# Integration Notes

## Report API contract

The app and backend share a single Report contract:

```json
{
  "id": "string (uuid)",
  "title": "string",
  "description": "string",
  "photoPath": "string | null",
  "latitude": "number | null",
  "longitude": "number | null",
  "createdAt": "ISO-8601 string"
}
```

## Mapping notes

- JSON fields are camelCase in the API.
- Database columns are snake_case in MySQL.
- `createdAt` is stored in `reports.created_at` and returned as ISO-8601.
