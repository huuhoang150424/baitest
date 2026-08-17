import { Request, Response } from 'express';
import { checkDbConnection } from '../config/database';

export const getHealthStatus = async (req: Request, res: Response): Promise<Response> => {
  const isDbConnected = await checkDbConnection();

  if (isDbConnected) {
    return res.status(200).json({
      status: 'ok',
      database: 'connected',
    });
  }

  return res.status(503).json({
    status: 'error',
    database: 'disconnected',
  });
};
