import { pool } from '../config/database';
import { ConflictError, NotFoundError } from '../errors/app-error';
import {
  CreateReceiptInput,
  CreateReceiptResult,
  GoodsReceipt,
  GoodsReceiptListItem,
} from '../models/receipt.model';
import { receiptRepository } from '../repositories/receipt.repository';

export class ReceiptService {
  /**
   * Helper utility to calculate item amount
   * amount = quantityReceived * unitPrice
   */
  public calculateItemAmount(quantityReceived: number, unitPrice: number): number {
    const amount = quantityReceived * unitPrice;
    // Fix floating point precision to 2 decimal places
    return Math.round(amount * 100) / 100;
  }

  /**
   * Helper utility to calculate total amount of receipt
   * totalAmount = SUM(items.amount)
   */
  public calculateTotalAmount(itemsAmount: number[]): number {
    const total = itemsAmount.reduce((sum, current) => sum + current, 0);
    return Math.round(total * 100) / 100;
  }

  /**
   * Create receipt with database transaction orchestration
   */
  async createReceipt(input: CreateReceiptInput): Promise<CreateReceiptResult> {
    // 1. Check if receiptNo already exists
    const existing = await receiptRepository.findByReceiptNo(input.receiptNo);
    if (existing) {
      throw new ConflictError('Receipt number already exists');
    }

    // 2. Perform Backend Calculations (Ignore client amount/totalAmount)
    const calculatedItems = input.items.map((item) => {
      const itemAmount = this.calculateItemAmount(item.quantityReceived, item.unitPrice);
      return {
        itemOrder: item.itemOrder,
        itemName: item.itemName,
        itemCode: item.itemCode,
        unit: item.unit,
        quantityDocument: item.quantityDocument,
        quantityReceived: item.quantityReceived,
        unitPrice: item.unitPrice,
        amount: itemAmount,
      };
    });

    const itemAmounts = calculatedItems.map((item) => item.amount);
    const totalAmount = this.calculateTotalAmount(itemAmounts);

    // 3. Transaction orchestration with PostgreSQL pool client
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const result = await receiptRepository.createReceiptInTransaction(
        client,
        input,
        calculatedItems,
        totalAmount
      );

      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get all receipts list
   */
  async getAllReceipts(): Promise<GoodsReceiptListItem[]> {
    return await receiptRepository.findAll();
  }

  /**
   * Get receipt detail by ID
   */
  async getReceiptById(id: number): Promise<GoodsReceipt> {
    const receipt = await receiptRepository.findById(id);
    if (!receipt) {
      throw new NotFoundError('Receipt not found');
    }
    return receipt;
  }

  /**
   * Delete receipt by ID
   */
  async deleteReceipt(id: number): Promise<void> {
    const existing = await receiptRepository.findById(id);
    if (!existing) {
      throw new NotFoundError('Receipt not found');
    }
    await receiptRepository.deleteById(id);
  }
}

export const receiptService = new ReceiptService();
