import { ReceiptService } from '../../src/services/receipt.service';
import { createReceiptSchema } from '../../src/validators/receipt.validator';

describe('Unit Tests - Receipt Calculation & Validation', () => {
  let receiptService: ReceiptService;

  beforeEach(() => {
    receiptService = new ReceiptService();
  });

  describe('Item Amount Calculation', () => {
    it('should correctly calculate amount for item (100 * 80000 = 8000000)', () => {
      const amount = receiptService.calculateItemAmount(100, 80000);
      expect(amount).toBe(8000000);
    });

    it('should correctly calculate amount for item (195 * 20000 = 3900000)', () => {
      const amount = receiptService.calculateItemAmount(195, 20000);
      expect(amount).toBe(3900000);
    });

    it('should return 0 when quantityReceived is 0', () => {
      const amount = receiptService.calculateItemAmount(0, 80000);
      expect(amount).toBe(0);
    });

    it('should return 0 when unitPrice is 0', () => {
      const amount = receiptService.calculateItemAmount(100, 0);
      expect(amount).toBe(0);
    });

    it('should handle float numbers cleanly and round to 2 decimal places', () => {
      const amount = receiptService.calculateItemAmount(10.5, 100.34);
      expect(amount).toBe(1053.57);
    });
  });

  describe('Total Amount Calculation', () => {
    it('should correctly sum item amounts (8000000 + 3900000 = 11900000)', () => {
      const total = receiptService.calculateTotalAmount([8000000, 3900000]);
      expect(total).toBe(11900000);
    });

    it('should return 0 for empty item amounts array', () => {
      const total = receiptService.calculateTotalAmount([]);
      expect(total).toBe(0);
    });
  });

  describe('Zod Validation Schema', () => {
    const validPayload = {
      receiptNo: 'PNK001',
      receiptDate: '2026-08-17',
      items: [
        {
          itemOrder: 1,
          itemName: 'Xi măng',
          quantityDocument: 100,
          quantityReceived: 100,
          unitPrice: 80000,
        },
      ],
    };

    it('should pass validation with valid payload', () => {
      const result = createReceiptSchema.safeParse(validPayload);
      expect(result.success).toBe(true);
    });

    it('should fail validation when receiptNo is missing', () => {
      const payload = { ...validPayload, receiptNo: undefined };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when receiptNo is empty string', () => {
      const payload = { ...validPayload, receiptNo: '' };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when items array is empty', () => {
      const payload = { ...validPayload, items: [] };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when quantityDocument is negative', () => {
      const payload = {
        ...validPayload,
        items: [{ ...validPayload.items[0], quantityDocument: -5 }],
      };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when quantityReceived is negative', () => {
      const payload = {
        ...validPayload,
        items: [{ ...validPayload.items[0], quantityReceived: -10 }],
      };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when unitPrice is negative', () => {
      const payload = {
        ...validPayload,
        items: [{ ...validPayload.items[0], unitPrice: -1000 }],
      };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when itemOrder is <= 0', () => {
      const payload = {
        ...validPayload,
        items: [{ ...validPayload.items[0], itemOrder: 0 }],
      };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });

    it('should fail validation when itemName is missing or empty', () => {
      const payload = {
        ...validPayload,
        items: [{ ...validPayload.items[0], itemName: '' }],
      };
      const result = createReceiptSchema.safeParse(payload);
      expect(result.success).toBe(false);
    });
  });
});
