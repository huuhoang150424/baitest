import { z } from 'zod';

const isoOrSimpleDateRegex = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?)?$/;

export const createReceiptItemSchema = z.object({
  itemOrder: z
    .number({
      required_error: 'itemOrder is required',
      invalid_type_error: 'itemOrder must be a number',
    })
    .int('itemOrder must be an integer')
    .gt(0, 'itemOrder must be greater than 0'),
  itemName: z
    .string({
      required_error: 'itemName is required',
      invalid_type_error: 'itemName must be a string',
    })
    .trim()
    .min(1, 'itemName cannot be empty'),
  itemCode: z.string().trim().max(100).nullable().optional(),
  unit: z.string().trim().max(50).nullable().optional(),
  quantityDocument: z
    .number({
      required_error: 'quantityDocument is required',
      invalid_type_error: 'quantityDocument must be a number',
    })
    .gte(0, 'quantityDocument must be greater than or equal to 0'),
  quantityReceived: z
    .number({
      required_error: 'quantityReceived is required',
      invalid_type_error: 'quantityReceived must be a number',
    })
    .gte(0, 'quantityReceived must be greater than or equal to 0'),
  unitPrice: z
    .number({
      required_error: 'unitPrice is required',
      invalid_type_error: 'unitPrice must be a number',
    })
    .gte(0, 'unitPrice must be greater than or equal to 0'),
});

export const createReceiptSchema = z.object({
  receiptNo: z
    .string({
      required_error: 'receiptNo is required',
      invalid_type_error: 'receiptNo must be a string',
    })
    .trim()
    .min(1, 'receiptNo cannot be empty')
    .max(50, 'receiptNo must not exceed 50 characters'),
  unitName: z.string().trim().max(255).nullable().optional(),
  departmentName: z.string().trim().max(255).nullable().optional(),
  receiptDate: z
    .string({
      required_error: 'receiptDate is required',
      invalid_type_error: 'receiptDate must be a string',
    })
    .trim()
    .refine((val) => !isNaN(Date.parse(val)) || isoOrSimpleDateRegex.test(val), {
      message: 'receiptDate must be a valid date string (e.g. YYYY-MM-DD)',
    }),
  debitAccount: z.string().trim().max(50).nullable().optional(),
  creditAccount: z.string().trim().max(50).nullable().optional(),
  supplierName: z.string().trim().max(255).nullable().optional(),
  documentNo: z.string().trim().max(100).nullable().optional(),
  documentDate: z
    .string()
    .trim()
    .nullable()
    .optional()
    .refine((val) => val === undefined || val === null || val === '' || !isNaN(Date.parse(val)), {
      message: 'documentDate must be a valid date string',
    }),
  description: z.string().trim().nullable().optional(),
  createdBy: z.string().trim().max(255).nullable().optional(),
  deliveredBy: z.string().trim().max(255).nullable().optional(),
  warehouseKeeper: z.string().trim().max(255).nullable().optional(),
  chiefAccountant: z.string().trim().max(255).nullable().optional(),
  items: z
    .array(createReceiptItemSchema, {
      required_error: 'items is required',
      invalid_type_error: 'items must be an array',
    })
    .min(1, 'items must contain at least 1 item'),
});

export const getReceiptByIdSchema = z.object({
  id: z
    .string()
    .regex(/^\d+$/, 'ID must be a positive integer')
    .transform((val) => parseInt(val, 10)),
});
