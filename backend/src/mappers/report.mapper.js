export const mapRowToReport = (row) => ({
  id: row.id,
  title: row.title,
  description: row.description,
  photoPath: row.photo_path ?? null,
  latitude: row.latitude !== null ? Number(row.latitude) : null,
  longitude: row.longitude !== null ? Number(row.longitude) : null,
  createdAt: row.created_at instanceof Date
    ? row.created_at.toISOString()
    : new Date(row.created_at).toISOString(),
});

const toDbDate = (value) => (value ? new Date(value) : null);

export const buildCreateReportInsert = ({
  id,
  title,
  description,
  photoPath,
  latitude,
  longitude,
  createdAt,
}) => {
  if (createdAt) {
    return {
      sql: `INSERT INTO reports (id, title, description, photo_path, latitude, longitude, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
      values: [
        id,
        title,
        description,
        photoPath,
        latitude,
        longitude,
        toDbDate(createdAt),
      ],
    };
  }
  return {
    sql: `INSERT INTO reports (id, title, description, photo_path, latitude, longitude)
         VALUES (?, ?, ?, ?, ?, ?)`,
    values: [id, title, description, photoPath, latitude, longitude],
  };
};

export const toDbUpdateValue = (value) =>
  value === undefined ? undefined : toDbDate(value);
