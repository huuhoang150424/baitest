import request from 'supertest';
import app from '../../src/app';
import { pool } from f≈'../../src/config/database';

describe('Integration Tests - Receipt REST API', () => {
  const uniqueReceiptNo = `TEST-PNK-${Date.now()}`;
  let createdReceiptId: number;

  afterAll(async () => {
    // Clean up test receipts created during test execution
    try {
      await pool.query("DELETE FROM goods_receipts WHERE receipt_no LIKE 'TEST-PNK-%'");
    } catch (error) {
      console.error('Test cleanup failed:', error);
    } finally {
      await pool.end();
    }
  });

  describe('GET /health', () => {
    it('should return health status status 200 or 503', async () => {
      const response = await request(app).get('/health');
      expect([200, 503]).toContain(response.status);
      expect(response.body).toHaveProperty('status');
      expect(response.body).toHaveProperty('database');
    });
  });

  describe('POST /api/receipts', () => {
    it('should create a new goods receipt successfully (201 Created)', async () => {
      const payload = {
        receiptNo: uniqueReceiptNo,
        unitName: 'Công ty ABC Test',
        departmentName: 'Kho vật tư',
        receiptDate: '2026-08-17',
        debitAccount: '152',
        creditAccount: '331',
        supplierName: 'Nhà cung cấp XYZ',
        documentNo: 'CT001',
        documentDate: '2026-08-17',
        description: 'Nhập vật tư kiểm thử',
        createdBy: 'Nguyễn Văn A',
        deliveredBy: 'Trần Văn B',
        warehouseKeeper: 'Lê Văn C',
        chiefAccountant: 'Phạm Văn D',
        items: [
          {
            itemOrder: 1,
            itemName: 'Xi măng',
            itemCode: 'XM001',
            unit: 'Bao',
            quantityDocument: 100,
            quantityReceived: 100,
            unitPrice: 80000,
          },
          {
            itemOrder: 2,
            itemName: 'Sắt',
            itemCode: 'SAT001',
            unit: 'Kg',
            quantityDocument: 200,
            quantityReceived: 195,
            unitPrice: 20000,
          },
        ],
      };

      const response = await request(app).post('/api/receipts').send(payload);

      expect(response.status).toBe(201);
      expect(response.body.message).toBe('Receipt created successfully');
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.receiptNo).toBe(uniqueReceiptNo);
      expect(response.body.data.receiptDate).toBe('2026-08-17');
      expect(response.body.data.totalAmount).toBe(11900000); // 100*80000 + 195*20000 = 8000000 + 3900000

      createdReceiptId = response.body.data.id;
    });

    it('should return 400 Bad Request when validation fails', async () => {
      const invalidPayload = {
        receiptNo: '',
        receiptDate: '2026-08-17',
        items: [],
      };

      const response = await request(app).post('/api/receipts').send(invalidPayload);

      expect(response.status).toBe(400);
      expect(response.body.message).toBe('Validation failed');
      expect(Array.isArray(response.body.errors)).toBe(true);
    });

    it('should return 409 Conflict when receiptNo already exists', async () => {
      const duplicatePayload = {
        receiptNo: uniqueReceiptNo,
        receiptDate: '2026-08-17',
        items: [
          {
            itemOrder: 1,
            itemName: 'Gạch',
            quantityDocument: 10,
            quantityReceived: 10,
            unitPrice: 5000,
          },
        ],
      };

      const response = await request(app).post('/api/receipts').send(duplicatePayload);

      expect(response.status).toBe(409);
      expect(response.body.message).toBe('Receipt number already exists');
    });
  });

  describe('GET /api/receipts', () => {
    it('should return list of receipts (200 OK)', async () => {
      const response = await request(app).get('/api/receipts');

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe('GET /api/receipts/:id', () => {
    it('should return receipt details by ID (200 OK)', async () => {
      expect(createdReceiptId).toBeDefined();

      const response = await request(app).get(`/api/receipts/${createdReceiptId}`);

      expect(response.status).toBe(200);
      expect(response.body.data).toHaveProperty('id', createdReceiptId);
      expect(response.body.data.receiptNo).toBe(uniqueReceiptNo);
      expect(response.body.data.totalAmount).toBe(11900000);
      expect(Array.isArray(response.body.data.items)).toBe(true);
      expect(response.body.data.items.length).toBe(2);
      expect(response.body.data.items[0].amount).toBe(8000000);
      expect(response.body.data.items[1].amount).toBe(3900000);
    });

    it('should return 404 Not Found when ID does not exist', async () => {
      const response = await request(app).get('/api/receipts/99999999');

      expect(response.status).toBe(404);
      expect(response.body.message).toBe('Receipt not found');
    });
  });

  describe('DELETE /api/receipts/:id', () => {
    it('should delete a receipt by ID successfully (200 OK)', async () => {
      expect(createdReceiptId).toBeDefined();

      const deleteResponse = await request(app).delete(`/api/receipts/${createdReceiptId}`);
      expect(deleteResponse.status).toBe(200);
      expect(deleteResponse.body.message).toBe('Receipt deleted successfully');

      // Verify it is deleted
      const getResponse = await request(app).get(`/api/receipts/${createdReceiptId}`);
      expect(getResponse.status).toBe(404);
    });

    it('should return 404 Not Found when deleting non-existent ID', async () => {
      const response = await request(app).delete('/api/receipts/99999999');
      expect(response.status).toBe(404);
      expect(response.body.message).toBe('Receipt not found');
    });
  });
});
