import { Router } from 'express';
import { getHealthStatus } from '../controllers/health.controller';

const router = Router();

/**
 * @openapi
 * /health:
 *   get:
 *     summary: Kiểm tra trạng thái ứng dụng và kết nối PostgreSQL Neon
 *     tags:
 *       - Health
 *     responses:
 *       200:
 *         description: Ứng dụng và database đang hoạt động bình thường
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: ok
 *                 database:
 *                   type: string
 *                   example: connected
 *       503:
 *         description: Mất kết nối database
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: error
 *                 database:
 *                   type: string
 *                   example: disconnected
 */
router.get('/', getHealthStatus);

export default router;
