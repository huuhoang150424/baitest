import { Router } from 'express';
import { receiptController } from '../controllers/receipt.controller';
import { validateParams, validateRequest } from '../middlewares/validate.middleware';
import { createReceiptSchema, getReceiptByIdSchema } from '../validators/receipt.validator';

const router = Router();

/**
 * @openapi
 * /api/receipts:
 *   post:
 *     summary: Tạo phiếu nhập kho mới
 *     tags:
 *       - Receipts
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateReceiptRequest'
 *           example:
 *             receiptNo: "PNK001"
 *             unitName: "Công ty ABC"
 *             departmentName: "Kho vật tư"
 *             receiptDate: "2026-08-17"
 *             debitAccount: "152"
 *             creditAccount: "331"
 *             supplierName: "Nhà cung cấp XYZ"
 *             documentNo: "CT001"
 *             documentDate: "2026-08-17"
 *             description: "Nhập vật tư tháng 08"
 *             createdBy: "Nguyễn Văn A"
 *             deliveredBy: "Trần Văn B"
 *             warehouseKeeper: "Lê Văn C"
 *             chiefAccountant: "Phạm Văn D"
 *             items:
 *               - itemOrder: 1
 *                 itemName: "Xi măng"
 *                 itemCode: "XM001"
 *                 unit: "Bao"
 *                 quantityDocument: 100
 *                 quantityReceived: 100
 *                 unitPrice: 80000
 *               - itemOrder: 2
 *                 itemName: "Sắt"
 *                 itemCode: "SAT001"
 *                 unit: "Kg"
 *                 quantityDocument: 200
 *                 quantityReceived: 195
 *                 unitPrice: 20000
 *     responses:
 *       201:
 *         description: Phiếu nhập kho được tạo thành công
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CreateReceiptResponse'
 *             example:
 *               message: "Receipt created successfully"
 *               data:
 *                 id: 1
 *                 receiptNo: "PNK001"
 *                 receiptDate: "2026-08-17"
 *                 totalAmount: 11900000
 *       400:
 *         description: Dữ liệu gửi lên không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationErrorResponse'
 *             example:
 *               message: "Validation failed"
 *               errors:
 *                 - field: "receiptNo"
 *                   message: "receiptNo is required"
 *       409:
 *         description: Số phiếu nhập kho đã tồn tại (Duplicate receiptNo)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             example:
 *               message: "Receipt number already exists"
 *       500:
 *         description: Lỗi máy chủ nội bộ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             example:
 *               message: "Internal server error"
 *   get:
 *     summary: Lấy danh sách phiếu nhập kho
 *     tags:
 *       - Receipts
 *     responses:
 *       200:
 *         description: Danh sách phiếu nhập kho được sắp xếp theo receiptDate giảm dần
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       receiptNo:
 *                         type: string
 *                         example: "PNK001"
 *                       receiptDate:
 *                         type: string
 *                         example: "2026-08-17"
 *                       supplierName:
 *                         type: string
 *                         nullable: true
 *                         example: "Nhà cung cấp XYZ"
 *                       totalAmount:
 *                         type: number
 *                         example: 11900000
 *                       createdAt:
 *                         type: string
 *                         example: "2026-08-17T10:00:00.000Z"
 *             example:
 *               data:
 *                 - id: 1
 *                   receiptNo: "PNK001"
 *                   receiptDate: "2026-08-17"
 *                   supplierName: "Nhà cung cấp XYZ"
 *                   totalAmount: 11900000
 *                   createdAt: "2026-08-17T10:00:00.000Z"
 *       500:
 *         description: Lỗi máy chủ nội bộ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/', validateRequest(createReceiptSchema), receiptController.createReceipt);
router.get('/', receiptController.getAllReceipts);

/**
 * @openapi
 * /api/receipts/{id}:
 *   get:
 *     summary: Lấy thông tin chi tiết phiếu nhập kho theo ID
 *     tags:
 *       - Receipts
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của phiếu nhập kho
 *         example: 1
 *     responses:
 *       200:
 *         description: Chi tiết phiếu nhập kho cùng danh sách vật tư đính kèm
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   $ref: '#/components/schemas/Receipt'
 *             example:
 *               data:
 *                 id: 1
 *                 receiptNo: "PNK001"
 *                 unitName: "Công ty ABC"
 *                 departmentName: "Kho vật tư"
 *                 receiptDate: "2026-08-17"
 *                 debitAccount: "152"
 *                 creditAccount: "331"
 *                 supplierName: "Nhà cung cấp XYZ"
 *                 documentNo: "CT001"
 *                 documentDate: "2026-08-17"
 *                 description: "Nhập vật tư"
 *                 totalAmount: 11900000
 *                 createdBy: "Nguyễn Văn A"
 *                 deliveredBy: "Trần Văn B"
 *                 warehouseKeeper: "Lê Văn C"
 *                 chiefAccountant: "Phạm Văn D"
 *                 items:
 *                   - id: 1
 *                     itemOrder: 1
 *                     itemName: "Xi măng"
 *                     itemCode: "XM001"
 *                     unit: "Bao"
 *                     quantityDocument: 100
 *                     quantityReceived: 100
 *                     unitPrice: 80000
 *                     amount: 8000000
 *       404:
 *         description: Phiếu nhập kho không tồn tại
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             example:
 *               message: "Receipt not found"
 *       500:
 *         description: Lỗi máy chủ nội bộ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/:id', validateParams(getReceiptByIdSchema), receiptController.getReceiptById);

/**
 * @openapi
 * /api/receipts/{id}:
 *   delete:
 *     summary: Xóa phiếu nhập kho theo ID
 *     tags:
 *       - Receipts
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID của phiếu nhập kho cần xóa
 *         example: 1
 *     responses:
 *       200:
 *         description: Xóa phiếu nhập kho thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Receipt deleted successfully"
 *       404:
 *         description: Phiếu nhập kho không tồn tại
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             example:
 *               message: "Receipt not found"
 *       500:
 *         description: Lỗi máy chủ nội bộ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id', validateParams(getReceiptByIdSchema), receiptController.deleteReceipt);

export default router;
