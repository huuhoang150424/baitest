import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Warehouse Receipt API',
      version: '1.0.0',
      description: 'REST API quản lý phiếu nhập kho.',
    },
    tags: [
      {
        name: 'Health',
        description: 'Kiểm tra trạng thái dịch vụ và kết nối database Neon PostgreSQL',
      },
      {
        name: 'Receipts',
        description: 'Quản lý thông tin và chi tiết phiếu nhập kho',
      },
    ],
    components: {
      schemas: {
        CreateReceiptItemRequest: {
          type: 'object',
          required: ['itemOrder', 'itemName', 'quantityDocument', 'quantityReceived', 'unitPrice'],
          properties: {
            itemOrder: {
              type: 'integer',
              minimum: 1,
              example: 1,
              description: 'Thứ tự vật tư trong phiếu',
            },
            itemName: {
              type: 'string',
              example: 'Xi măng',
              description: 'Tên vật tư',
            },
            itemCode: {
              type: 'string',
              nullable: true,
              example: 'XM001',
              description: 'Mã số vật tư',
            },
            unit: {
              type: 'string',
              nullable: true,
              example: 'Bao',
              description: 'Đơn vị tính',
            },
            quantityDocument: {
              type: 'number',
              minimum: 0,
              example: 100,
              description: 'Số lượng theo chứng từ',
            },
            quantityReceived: {
              type: 'number',
              minimum: 0,
              example: 100,
              description: 'Số lượng thực nhập',
            },
            unitPrice: {
              type: 'number',
              minimum: 0,
              example: 80000,
              description: 'Đơn giá vật tư (VND)',
            },
          },
        },
        CreateReceiptRequest: {
          type: 'object',
          required: ['receiptNo', 'receiptDate', 'items'],
          properties: {
            receiptNo: {
              type: 'string',
              maxLength: 50,
              example: 'PNK001',
              description: 'Số phiếu nhập kho (Duy nhất)',
            },
            unitName: {
              type: 'string',
              nullable: true,
              example: 'Công ty ABC',
              description: 'Tên đơn vị',
            },
            departmentName: {
              type: 'string',
              nullable: true,
              example: 'Kho vật tư',
              description: 'Tên bộ phận',
            },
            receiptDate: {
              type: 'string',
              format: 'date',
              example: '2026-08-17',
              description: 'Ngày lập phiếu nhập (YYYY-MM-DD)',
            },
            debitAccount: {
              type: 'string',
              nullable: true,
              example: '152',
              description: 'Tài khoản Nợ',
            },
            creditAccount: {
              type: 'string',
              nullable: true,
              example: '331',
              description: 'Tài khoản Có',
            },
            supplierName: {
              type: 'string',
              nullable: true,
              example: 'Nhà cung cấp XYZ',
              description: 'Họ tên người giao / Nhà cung cấp',
            },
            documentNo: {
              type: 'string',
              nullable: true,
              example: 'CT001',
              description: 'Theo chứng từ số',
            },
            documentDate: {
              type: 'string',
              format: 'date',
              nullable: true,
              example: '2026-08-17',
              description: 'Ngày chứng từ',
            },
            description: {
              type: 'string',
              nullable: true,
              example: 'Nhập vật tư tháng 08',
              description: 'Diễn giải / Lý do nhập kho',
            },
            createdBy: {
              type: 'string',
              nullable: true,
              example: 'Nguyễn Văn A',
              description: 'Người lập phiếu',
            },
            deliveredBy: {
              type: 'string',
              nullable: true,
              example: 'Trần Văn B',
              description: 'Người giao hàng',
            },
            warehouseKeeper: {
              type: 'string',
              nullable: true,
              example: 'Lê Văn C',
              description: 'Thủ kho',
            },
            chiefAccountant: {
              type: 'string',
              nullable: true,
              example: 'Phạm Văn D',
              description: 'Kế toán trưởng',
            },
            items: {
              type: 'array',
              minItems: 1,
              items: {
                $ref: '#/components/schemas/CreateReceiptItemRequest',
              },
            },
          },
        },
        CreateReceiptResponse: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              example: 'Receipt created successfully',
            },
            data: {
              type: 'object',
              properties: {
                id: { type: 'integer', example: 1 },
                receiptNo: { type: 'string', example: 'PNK001' },
                receiptDate: { type: 'string', example: '2026-08-17' },
                totalAmount: { type: 'number', example: 11900000 },
              },
            },
          },
        },
        ReceiptItem: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            itemOrder: { type: 'integer', example: 1 },
            itemName: { type: 'string', example: 'Xi măng' },
            itemCode: { type: 'string', nullable: true, example: 'XM001' },
            unit: { type: 'string', nullable: true, example: 'Bao' },
            quantityDocument: { type: 'number', example: 100 },
            quantityReceived: { type: 'number', example: 100 },
            unitPrice: { type: 'number', example: 80000 },
            amount: { type: 'number', example: 8000000 },
          },
        },
        Receipt: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            receiptNo: { type: 'string', example: 'PNK001' },
            unitName: { type: 'string', nullable: true, example: 'Công ty ABC' },
            departmentName: { type: 'string', nullable: true, example: 'Kho vật tư' },
            receiptDate: { type: 'string', example: '2026-08-17' },
            debitAccount: { type: 'string', nullable: true, example: '152' },
            creditAccount: { type: 'string', nullable: true, example: '331' },
            supplierName: { type: 'string', nullable: true, example: 'Nhà cung cấp XYZ' },
            documentNo: { type: 'string', nullable: true, example: 'CT001' },
            documentDate: { type: 'string', nullable: true, example: '2026-08-17' },
            description: { type: 'string', nullable: true, example: 'Nhập vật tư' },
            totalAmount: { type: 'number', example: 11900000 },
            createdBy: { type: 'string', nullable: true, example: 'Nguyễn Văn A' },
            deliveredBy: { type: 'string', nullable: true, example: 'Trần Văn B' },
            warehouseKeeper: { type: 'string', nullable: true, example: 'Lê Văn C' },
            chiefAccountant: { type: 'string', nullable: true, example: 'Phạm Văn D' },
            items: {
              type: 'array',
              items: {
                $ref: '#/components/schemas/ReceiptItem',
              },
            },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              example: 'Receipt not found',
            },
          },
        },
        ValidationErrorResponse: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              example: 'Validation failed',
            },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: { type: 'string', example: 'receiptNo' },
                  message: { type: 'string', example: 'receiptNo is required' },
                },
              },
            },
          },
        },
      },
    },
  },
  apis: ['./src/routes/*.ts', './dist/routes/*.js'],
};

export const swaggerSpec = swaggerJsdoc(options);
