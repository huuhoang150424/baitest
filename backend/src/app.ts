import cors from 'cors';
import express, { Application, Request, Response } from 'express';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';
import { errorHandler } from './middlewares/error.middleware';
import healthRouter from './routes/health.routes';
import receiptRouter from './routes/receipt.routes';

const app: Application = express();

// Global Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger UI Documentation Endpoint
app.use('/swagger', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Application Routes
app.use('/health', healthRouter);
app.use('/api/receipts', receiptRouter);

// 404 Handler for undefined routes
app.use((req: Request, res: Response) => {
  res.status(404).json({
    message: `Cannot ${req.method} ${req.originalUrl}`,
  });
});

// Centralized Error Handling Middleware
app.use(errorHandler);

export default app;
