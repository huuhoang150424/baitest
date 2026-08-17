# API Documentation - Warehouse Goods Receipt Management

Tài liệu chi tiết REST API Quản lý Phiếu nhập kho (Form 01-VT).

---

## 1. Tổng quan Endpoints

| HTTP Method | Endpoint | Mô tả | Authorization |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Kiểm tra trạng thái ứng dụng và DB PostgreSQL Neon | Public |
| `GET` | `/api/receipts` | Lấy danh sách tất cả phiếu nhập kho | Public |
| `GET` | `/api/receipts/:id` | Lấy chi tiết một phiếu nhập kho theo ID | Public |
| `POST` | `/api/receipts` | Tạo phiếu nhập kho mới (kèm transaction) | Public |
| `DELETE` | `/api/receipts/:id` | Xóa một phiếu nhập kho theo ID | Public |
| `GET` | `/swagger` | Giao diện Swagger UI tương tác trực tiếp API | Public |

---

## 2. Chi tiết API Endpoints

### 2.1 GET /health

Kiểm tra ứng dụng đang chạy và cơ sở dữ liệu PostgreSQL Neon có kết nối thành công hay không.

#### Response 200 OK (Thành công):
```json
{
  "status": "ok",
  "database": "connected"
}
```

#### Response 503 Service Unavailable (Lỗi kết nối DB):
```json
{
  "status": "error",
  "database": "disconnected"
}
```

---

### 2.2 GET /api/receipts

Lấy danh sách các phiếu nhập kho, được sắp xếp theo `receiptDate` giảm dần.

#### Response 200 OK:
```json
{
  "data": [
    {
      "id": 1,
      "receiptNo": "PNK001",
      "receiptDate": "2026-08-17",
      "supplierName": "Nhà cung cấp XYZ",
      "totalAmount": 11900000,
      "createdAt": "2026-08-17T10:00:00.000Z"
    }
  ]
}
```

---

### 2.3 GET /api/receipts/:id

Lấy chi tiết một phiếu nhập kho cùng danh sách các mặt hàng / vật tư đính kèm.

#### Path Parameters:
- `id` (integer, required): ID phiếu nhập kho (ví dụ: `1`).

#### Response 200 OK (Thành công):
```json
{
  "data": {
    "id": 1,
    "receiptNo": "PNK001",
    "unitName": "Công ty ABC",
    "departmentName": "Kho vật tư",
    "receiptDate": "2026-08-17",
    "debitAccount": "152",
    "creditAccount": "331",
    "supplierName": "Nhà cung cấp XYZ",
    "documentNo": "CT001",
    "documentDate": "2026-08-17",
    "description": "Nhập vật tư tháng 08",
    "totalAmount": 11900000,
    "createdBy": "Nguyễn Văn A",
    "deliveredBy": "Trần Văn B",
    "warehouseKeeper": "Lê Văn C",
    "chiefAccountant": "Phạm Văn D",
    "items": [
      {
        "id": 1,
        "itemOrder": 1,
        "itemName": "Xi măng",
        "itemCode": "XM001",
        "unit": "Bao",
        "quantityDocument": 100,
        "quantityReceived": 100,
        "unitPrice": 80000,
        "amount": 8000000
      },
      {
        "id": 2,
        "itemOrder": 2,
        "itemName": "Sắt",
        "itemCode": "SAT001",
        "unit": "Kg",
        "quantityDocument": 200,
        "quantityReceived": 195,
        "unitPrice": 20000,
        "amount": 3900000
      }
    ]
  }
}
```

#### Response 404 Not Found (Không tìm thấy ID):
```json
{
  "message": "Receipt not found"
}
```

---

### 2.4 POST /api/receipts

Tạo phiếu nhập kho mới. Backend sẽ tự động tính:
- `amount = quantityReceived * unitPrice` cho từng vật tư.
- `totalAmount = SUM(amount)` cho toàn bộ phiếu.

Mọi giá trị `amount` hoặc `totalAmount` do client gửi lên sẽ bị bỏ qua.
Thao tác được thực hiện trong **PostgreSQL Transaction** (`BEGIN`, `INSERT`, `COMMIT` / `ROLLBACK`).

#### Request Body Sample:
```json
{
  "receiptNo": "PNK001",
  "unitName": "Công ty ABC",
  "departmentName": "Kho vật tư",
  "receiptDate": "2026-08-17",
  "debitAccount": "152",
  "creditAccount": "331",
  "supplierName": "Nhà cung cấp XYZ",
  "documentNo": "CT001",
  "documentDate": "2026-08-17",
  "description": "Nhập vật tư tháng 08",
  "createdBy": "Nguyễn Văn A",
  "deliveredBy": "Trần Văn B",
  "warehouseKeeper": "Lê Văn C",
  "chiefAccountant": "Phạm Văn D",
  "items": [
    {
      "itemOrder": 1,
      "itemName": "Xi măng",
      "itemCode": "XM001",
      "unit": "Bao",
      "quantityDocument": 100,
      "quantityReceived": 100,
      "unitPrice": 80000
    },
    {
      "itemOrder": 2,
      "itemName": "Sắt",
      "itemCode": "SAT001",
      "unit": "Kg",
      "quantityDocument": 200,
      "quantityReceived": 195,
      "unitPrice": 20000
    }
  ]
}
```

#### Response 201 Created (Thành công):
```json
{
  "message": "Receipt created successfully",
  "data": {
    "id": 1,
    "receiptNo": "PNK001",
    "receiptDate": "2026-08-17",
    "totalAmount": 11900000
  }
}
```

#### Response 400 Bad Request (Lỗi validation Zod):
```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "receiptNo",
      "message": "receiptNo is required"
    }
  ]
}
```

#### Response 409 Conflict (Trùng số phiếu nhập kho):
```json
{
  "message": "Receipt number already exists"
}
```

---

### 2.5 DELETE /api/receipts/:id

Xóa một phiếu nhập kho và toàn bộ các mặt hàng/vật tư đính kèm (`ON DELETE CASCADE`).

#### Path Parameters:
- `id` (integer, required): ID phiếu nhập kho cần xóa (ví dụ: `1`).

#### Response 200 OK (Xóa thành công):
```json
{
  "message": "Receipt deleted successfully"
}
```

#### Response 404 Not Found (Không tìm thấy ID):
```json
{
  "message": "Receipt not found"
}
```

---

## 3. Swagger UI Interactive Documentation

Truy cập địa chỉ sau để tương tác và test trực tiếp các API:
```
http://localhost:3000/swagger
```
