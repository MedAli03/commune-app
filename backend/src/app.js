import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

import reportsRoutes from './routes/reports.routes.js';
import {
  errorHandler,
  notFoundHandler,
} from './middleware/error.middleware.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.use('/', reportsRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
