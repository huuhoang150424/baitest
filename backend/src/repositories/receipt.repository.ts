import { PoolClient } from 'pg';
import { pool } from '../config/database';
import {
  CreateReceiptInput,
  GoodsReceipt,
  GoodsReceiptItem,
  GoodsReceiptListItem,
} from '../models/receipt.model';

export class ReceiptRepository {
  /**
   * Find a receipt by receipt_no
   */
  async findByReceiptNo(receiptNo: string, client?: PoolClient): Promise<GoodsReceipt | null> {
    const query = `
      SELECT 
        id, 
        receipt_no AS "receiptNo", 
        receipt_date AS "receiptDate",
        total_amount AS "totalAmount"
      FROM goods_receipts 
      WHERE receipt_no = $1
    `;
    const executor = client || pool;
    const result = await executor.query(query, [receiptNo]);

    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      ...row,
      totalAmount: Number(row.totalAmount),
    };
  }

  /**
   * List all receipts ordered by receipt_date DESC
   */
  async findAll(): Promise<GoodsReceiptListItem[]> {
    const query = `
      SELECT 
        id, 
        receipt_no AS "receiptNo", 
        to_char(receipt_date, 'YYYY-MM-DD') AS "receiptDate", 
        supplier_name AS "supplierName", 
        total_amount AS "totalAmount", 
        created_at AS "createdAt"
      FROM goods_receipts 
      ORDER BY receipt_date DESC, id DESC
    `;
    const result = await pool.query(query);

    return result.rows.map((row) => ({
      id: row.id,
      receiptNo: row.receiptNo,
      receiptDate: row.receiptDate,
      supplierName: row.supplierName,
      totalAmount: Number(row.totalAmount),
      createdAt: row.createdAt ? new Date(row.createdAt).toISOString() : undefined,
    }));
  }

  /**
   * Find detailed receipt with items by ID
   */
  async findById(id: number): Promise<GoodsReceipt | null> {
    const receiptQuery = `
      SELECT 
        id, 
        receipt_no AS "receiptNo", 
        unit_name AS "unitName", 
        department_name AS "departmentName", 
        to_char(receipt_date, 'YYYY-MM-DD') AS "receiptDate", 
        debit_account AS "debitAccount", 
        credit_account AS "creditAccount", 
        supplier_name AS "supplierName", 
        document_no AS "documentNo", 
        to_char(document_date, 'YYYY-MM-DD') AS "documentDate", 
        description, 
        total_amount AS "totalAmount", 
        created_by AS "createdBy", 
        delivered_by AS "deliveredBy", 
        warehouse_keeper AS "warehouseKeeper", 
        chief_accountant AS "chiefAccountant", 
        created_at AS "createdAt", 
        updated_at AS "updatedAt"
      FROM goods_receipts 
      WHERE id = $1
    `;

    const receiptResult = await pool.query(receiptQuery, [id]);

    if (receiptResult.rows.length === 0) {
      return null;
    }

    const itemsQuery = `
      SELECT 
        id, 
        receipt_id AS "receiptId", 
        item_order AS "itemOrder", 
        item_name AS "itemName", 
        item_code AS "itemCode", 
        unit, 
        quantity_document AS "quantityDocument", 
        quantity_received AS "quantityReceived", 
        unit_price AS "unitPrice", 
        amount, 
        created_at AS "createdAt"
      FROM goods_receipt_items 
      WHERE receipt_id = $1 
      ORDER BY item_order ASC
    `;

    const itemsResult = await pool.query(itemsQuery, [id]);

    const receiptRow = receiptResult.rows[0];
    const items: GoodsReceiptItem[] = itemsResult.rows.map((row) => ({
      id: row.id,
      receiptId: row.receiptId,
      itemOrder: row.itemOrder,
      itemName: row.itemName,
      itemCode: row.itemCode,
      unit: row.unit,
      quantityDocument: Number(row.quantityDocument),
      quantityReceived: Number(row.quantityReceived),
      unitPrice: Number(row.unitPrice),
      amount: Number(row.amount),
      createdAt: row.createdAt ? new Date(row.createdAt).toISOString() : undefined,
    }));

    return {
      ...receiptRow,
      totalAmount: Number(receiptRow.totalAmount),
      createdAt: receiptRow.createdAt ? new Date(receiptRow.createdAt).toISOString() : undefined,
      updatedAt: receiptRow.updatedAt ? new Date(receiptRow.updatedAt).toISOString() : undefined,
      items,
    };
  }

  /**
   * Create receipt and items in transaction using transaction PoolClient
   */
  async createReceiptInTransaction(
    client: PoolClient,
    receiptData: CreateReceiptInput,
    calculatedItems: Array<{
      itemOrder: number;
      itemName: string;
      itemCode?: string | null;
      unit?: string | null;
      quantityDocument: number;
      quantityReceived: number;
      unitPrice: number;
      amount: number;
    }>,
    totalAmount: number
  ): Promise<{ id: number; receiptNo: string; receiptDate: string; totalAmount: number }> {
    const insertReceiptQuery = `
      INSERT INTO goods_receipts (
        receipt_no, unit_name, department_name, receipt_date, 
        debit_account, credit_account, supplier_name, document_no, 
        document_date, description, total_amount, created_by, 
        delivered_by, warehouse_keeper, chief_accountant
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      RETURNING id, receipt_no AS "receiptNo", to_char(receipt_date, 'YYYY-MM-DD') AS "receiptDate", total_amount AS "totalAmount"
    `;

    const receiptValues = [
      receiptData.receiptNo,
      receiptData.unitName || null,
      receiptData.departmentName || null,
      receiptData.receiptDate,
      receiptData.debitAccount || null,
      receiptData.creditAccount || null,
      receiptData.supplierName || null,
      receiptData.documentNo || null,
      receiptData.documentDate || null,
      receiptData.description || null,
      totalAmount,
      receiptData.createdBy || null,
      receiptData.deliveredBy || null,
      receiptData.warehouseKeeper || null,
      receiptData.chiefAccountant || null,
    ];

    const receiptResult = await client.query(insertReceiptQuery, receiptValues);
    const createdReceipt = receiptResult.rows[0];

    const insertItemQuery = `
      INSERT INTO goods_receipt_items (
        receipt_id, item_order, item_name, item_code, unit,
        quantity_document, quantity_received, unit_price, amount
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    `;

    for (const item of calculatedItems) {
      await client.query(insertItemQuery, [
        createdReceipt.id,
        item.itemOrder,
        item.itemName,
        item.itemCode || null,
        item.unit || null,
        item.quantityDocument,
        item.quantityReceived,
        item.unitPrice,
        item.amount,
      ]);
    }

    return {
      id: createdReceipt.id,
      receiptNo: createdReceipt.receiptNo,
      receiptDate: createdReceipt.receiptDate,
      totalAmount: Number(createdReceipt.totalAmount),
    };
  }

  /**
   * Delete a receipt by ID
   */
  async deleteById(id: number): Promise<boolean> {
    const query = 'DELETE FROM goods_receipts WHERE id = $1';
    const result = await pool.query(query, [id]);
    return (result.rowCount ?? 0) > 0;
  }
}

export const receiptRepository = new ReceiptRepository();
