export const notFoundHandler = (req, res) => {
  res.status(404).json({ message: 'Not Found' });
};

export const errorHandler = (err, req, res, next) => {
  if (res.headersSent) {
    return next(err);
  }

  const status = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  res.status(status).json({
    message,
    details: err.details ?? null,
  });
};
