import pool from '../db/pool.js';

const mapRowToReport = (row) => ({
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

export const getReports = async (req, res, next) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, title, description, photo_path, latitude, longitude, created_at FROM reports ORDER BY created_at DESC',
    );
    res.json(rows.map(mapRowToReport));
  } catch (error) {
    next(error);
  }
};

export const getReportById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      'SELECT id, title, description, photo_path, latitude, longitude, created_at FROM reports WHERE id = ? LIMIT 1',
      [id],
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }
    res.json(mapRowToReport(rows[0]));
  } catch (error) {
    next(error);
  }
};

export const createReport = async (req, res, next) => {
  try {
    const {
      id,
      title,
      description,
      photoPath,
      latitude,
      longitude,
      createdAt,
    } = req.validated;

    if (createdAt) {
      await pool.execute(
        `INSERT INTO reports (id, title, description, photo_path, latitude, longitude, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          id,
          title,
          description,
          photoPath,
          latitude,
          longitude,
          new Date(createdAt),
        ],
      );
    } else {
      await pool.execute(
        `INSERT INTO reports (id, title, description, photo_path, latitude, longitude)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [id, title, description, photoPath, latitude, longitude],
      );
    }

    const [rows] = await pool.execute(
      'SELECT id, title, description, photo_path, latitude, longitude, created_at FROM reports WHERE id = ? LIMIT 1',
      [id],
    );
    res.status(201).json(rows.length ? mapRowToReport(rows[0]) : { id });
  } catch (error) {
    next(error);
  }
};

export const updateReport = async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      title,
      description,
      photoPath,
      latitude,
      longitude,
      createdAt,
    } = req.validated;

    const fields = [];
    const values = [];

    if (title !== undefined) {
      fields.push('title = ?');
      values.push(title);
    }
    if (description !== undefined) {
      fields.push('description = ?');
      values.push(description);
    }
    if (photoPath !== undefined) {
      fields.push('photo_path = ?');
      values.push(photoPath);
    }
    if (latitude !== undefined) {
      fields.push('latitude = ?');
      values.push(latitude);
    }
    if (longitude !== undefined) {
      fields.push('longitude = ?');
      values.push(longitude);
    }
    if (createdAt !== undefined) {
      fields.push('created_at = ?');
      values.push(createdAt ? new Date(createdAt) : null);
    }

    if (fields.length === 0) {
      return res.status(400).json({ error: 'No fields to update.' });
    }

    values.push(id);
    const [result] = await pool.execute(
      `UPDATE reports SET ${fields.join(', ')} WHERE id = ?`,
      values,
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }

    const [rows] = await pool.execute(
      'SELECT id, title, description, photo_path, latitude, longitude, created_at FROM reports WHERE id = ? LIMIT 1',
      [id],
    );
    res.json(rows.length ? mapRowToReport(rows[0]) : { id });
  } catch (error) {
    next(error);
  }
};

export const deleteReport = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [result] = await pool.execute(
      'DELETE FROM reports WHERE id = ?',
      [id],
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
