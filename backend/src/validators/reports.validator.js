const isNonEmptyString = (value) =>
  typeof value === 'string' && value.trim().length > 0;

const isOptionalString = (value) =>
  value === null || value === undefined || typeof value === 'string';

const isOptionalNumber = (value) =>
  value === null || value === undefined || Number.isFinite(Number(value));

const parseOptionalNumber = (value) => {
  if (value === null || value === undefined) {
    return null;
  }
  const numeric = Number(value);
  return Number.isFinite(numeric) ? numeric : null;
};

const isValidDateString = (value) =>
  typeof value === 'string' && !Number.isNaN(Date.parse(value));

const isOptionalDateString = (value) =>
  value === undefined || isValidDateString(value);

const hasField = (body, field) =>
  Object.prototype.hasOwnProperty.call(body ?? {}, field);

export const validateCreateReport = (body) => {
  const errors = [];

  if (!isNonEmptyString(body?.id)) {
    errors.push('id is required and must be a non-empty string.');
  }
  if (!isNonEmptyString(body?.title)) {
    errors.push('title is required and must be a non-empty string.');
  }
  if (!isNonEmptyString(body?.description)) {
    errors.push('description is required and must be a non-empty string.');
  }
  if (!isOptionalString(body?.photoPath)) {
    errors.push('photoPath must be a string or null when provided.');
  }
  if (!isOptionalNumber(body?.latitude)) {
    errors.push('latitude must be a number if provided.');
  }
  if (!isOptionalNumber(body?.longitude)) {
    errors.push('longitude must be a number if provided.');
  }
  if (!isOptionalDateString(body?.createdAt)) {
    errors.push('createdAt must be a valid ISO-8601 string if provided.');
  }

  return {
    ok: errors.length === 0,
    errors,
    values: {
      id: body?.id?.trim(),
      title: body?.title?.trim(),
      description: body?.description?.trim(),
      photoPath: body?.photoPath ?? null,
      latitude: parseOptionalNumber(body?.latitude),
      longitude: parseOptionalNumber(body?.longitude),
      createdAt: body?.createdAt ?? null,
    },
  };
};

export const validateUpdateReport = (body) => {
  const errors = [];

  if (body?.title !== undefined && !isNonEmptyString(body?.title)) {
    errors.push('title must be a non-empty string when provided.');
  }
  if (body?.description !== undefined && !isNonEmptyString(body?.description)) {
    errors.push('description must be a non-empty string when provided.');
  }
  if (hasField(body, 'photoPath') && !isOptionalString(body?.photoPath)) {
    errors.push('photoPath must be a string or null when provided.');
  }
  if (hasField(body, 'latitude') && !isOptionalNumber(body?.latitude)) {
    errors.push('latitude must be a number if provided.');
  }
  if (hasField(body, 'longitude') && !isOptionalNumber(body?.longitude)) {
    errors.push('longitude must be a number if provided.');
  }
  if (hasField(body, 'createdAt') && !isValidDateString(body?.createdAt)) {
    errors.push('createdAt must be a valid ISO-8601 string if provided.');
  }

  return {
    ok: errors.length === 0,
    errors,
    values: {
      title: hasField(body, 'title') ? body?.title?.trim() : undefined,
      description: hasField(body, 'description')
        ? body?.description?.trim()
        : undefined,
      photoPath: hasField(body, 'photoPath') ? body?.photoPath ?? null : undefined,
      latitude: hasField(body, 'latitude')
        ? parseOptionalNumber(body?.latitude)
        : undefined,
      longitude: hasField(body, 'longitude')
        ? parseOptionalNumber(body?.longitude)
        : undefined,
      createdAt: hasField(body, 'createdAt') ? body?.createdAt : undefined,
    },
  };
};
