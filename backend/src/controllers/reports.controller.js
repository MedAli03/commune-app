import pool from '../db/pool.js';
import {
  buildCreateReportInsert,
  mapRowToReport,
  toDbUpdateValue,
} from '../mappers/report.mapper.js';

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
      return res.status(404).json({ message: 'Report not found.' });
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

    const { sql, values } = buildCreateReportInsert({
      id,
      title,
      description,
      photoPath,
      latitude,
      longitude,
      createdAt,
    });
    await pool.execute(sql, values);

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
      values.push(toDbUpdateValue(createdAt));
    }

    if (fields.length === 0) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    values.push(id);
    const [result] = await pool.execute(
      `UPDATE reports SET ${fields.join(', ')} WHERE id = ?`,
      values,
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Report not found.' });
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
      return res.status(404).json({ message: 'Report not found.' });
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
