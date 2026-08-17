import { NextFunction, Request, Response } from 'express';
import { AppError, ValidationError } from '../errors/app-error';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  next: NextFunction
): Response => {
  // Check if error is custom ValidationError
  if (err instanceof ValidationError) {
    return res.status(err.statusCode).json({
      message: err.message,
      errors: err.errors,
    });
  }

  // Check if error is any other custom AppError
  if (err instanceof AppError) {
    const responseBody: any = { message: err.message };
    if (err.details) {
      responseBody.details = err.details;
    }
    return res.status(err.statusCode).json(responseBody);
  }

  // Handle PostgreSQL unique violation (code 23505)
  const pgErr = err as any;
  if (pgErr.code === '23505') {
    if (pgErr.constraint?.includes('receipt_no') || pgErr.detail?.includes('receipt_no')) {
      return res.status(409).json({
        message: 'Receipt number already exists',
      });
    }
    return res.status(409).json({
      message: 'Duplicate record exists',
    });
  }

  // Log unknown or internal server errors
  console.error('Unhandled Server Error:', err);

  // Return clean internal server error response without exposing stack traces or DB credentials
  return res.status(500).json({
    message: 'Internal server error',
  });
};
