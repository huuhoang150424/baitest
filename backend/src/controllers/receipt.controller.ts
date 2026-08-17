import { NextFunction, Request, Response } from 'express';
import { receiptService } from '../services/receipt.service';

export class ReceiptController {
  async createReceipt(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await receiptService.createReceipt(req.body);
      res.status(201).json({
        message: 'Receipt created successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async getAllReceipts(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const receipts = await receiptService.getAllReceipts();
      res.status(200).json({
        data: receipts,
      });
    } catch (error) {
      next(error);
    }
  }

  async getReceiptById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      const receipt = await receiptService.getReceiptById(id);
      res.status(200).json({
        data: receipt,
      });
    } catch (error) {
      next(error);
    }
  }

  async deleteReceipt(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      await receiptService.deleteReceipt(id);
      res.status(200).json({
        message: 'Receipt deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export const receiptController = new ReceiptController();
