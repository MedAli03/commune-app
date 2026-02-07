import { Router } from 'express';

import pool from '../db/pool.js';
import {
  createReport,
  deleteReport,
  getReportById,
  getReports,
  updateReport,
} from '../controllers/reports.controller.js';
import {
  validateCreateReport,
  validateUpdateReport,
} from '../validators/reports.validator.js';

const router = Router();

router.get('/health', async (req, res, next) => {
  try {
    await pool.execute('SELECT 1');
    res.json({ ok: true, db: true });
  } catch (error) {
    next(error);
  }
});

router.get('/reports', getReports);
router.get('/reports/:id', getReportById);

router.post('/reports', (req, res, next) => {
  const result = validateCreateReport(req.body);
  if (!result.ok) {
    return res.status(400).json({ error: result.errors.join(' ') });
  }
  req.validated = result.values;
  return createReport(req, res, next);
});

router.put('/reports/:id', (req, res, next) => {
  const result = validateUpdateReport(req.body);
  if (!result.ok) {
    return res.status(400).json({ error: result.errors.join(' ') });
  }
  req.validated = result.values;
  return updateReport(req, res, next);
});

router.delete('/reports/:id', deleteReport);

export default router;
