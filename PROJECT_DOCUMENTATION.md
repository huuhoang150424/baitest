# BÁO CÁO CẤU TRÚC DỰ ÁN VÀ THIẾT KẾ CƠ SỞ DỮ LIỆU
## QUẢN LÝ PHIẾU NHẬP KHO (FORM 01-VT)

---

## I. TỔNG QUAN DỰ ÁN

Dự án **Quản lý Phiếu nhập kho (Form 01-VT)** được thiết kế theo mô hình chuẩn doanh nghiệp với sự phân tách hoàn toàn giữa **Backend RESTful API** và **Frontend Mobile Application**:

- **Backend**: Node.js + TypeScript + Express.js + Neon PostgreSQL + Zod Validation + Swagger/OpenAPI 3.0 + Jest.
- **Frontend**: Flutter + Dart + Material 3 + Riverpod State Management + Dio Network Client + GoRouter + Flutter Test.

---

## II. GIẢI THÍCH CHI TIẾT CẤU TRÚC THƯ MỤC

Dự án được chia thành 2 thư mục độc lập nằm tại thư mục gốc:

```
/Volumes/SSD/baitest/
├── backend/                  # Mã nguồn Backend REST API (Node.js/TypeScript)
└── mobile/                   # Mã nguồn Frontend App (Flutter/Dart)
```

---

### 1. Cấu trúc thư mục Backend (`backend/`)

Thư mục `backend/` áp dụng kiến trúc phân tầng chuẩn (**Clean Architecture 4 Tầng**), tách biệt hoàn toàn giữa Route, Validation, Controller, Service và Repository:

```
backend/
├── database/
│   └── schema.sql              # Định nghĩa bảng CSDL, Ràng buộc (Constraints) & Indexes
├── docs/
│   ├── API.md                  # Tài liệu chi tiết REST API (khớp 100% Swagger)
│   └── DATABASE.md             # Tài liệu chi tiết CSDL PostgreSQL Neon
├── src/
│   ├── config/
│   │   ├── database.ts         # Khởi tạo Pool kết nối Neon PostgreSQL & Health check
│   │   └── swagger.ts          # Cấu hình OpenAPI 3.0 Swagger JSDoc specs
│   ├── controllers/
│   │   ├── health.controller.ts # Tiếp nhận request GET /health
│   │   └── receipt.controller.ts# Tiếp nhận HTTP requests, gọi Service & trả JSON response
│   ├── database/
│   │   └── migrate.ts          # Script chạy Migration tự động lên CSDL Neon
│   ├── errors/
│   │   └── app-error.ts        # Định nghĩa các lớp Lỗi tùy chỉnh (AppError, BadRequest, NotFound, Conflict)
│   ├── middlewares/
│   │   ├── error.middleware.ts  # Centralized Error Handler xử lý lỗi toàn hệ thống
│   │   └── validate.middleware.ts# Validation Middleware kiểm tra dữ liệu bằng Zod Schema
│   ├── models/
│   │   └── receipt.model.ts    # DTOs & TypeScript Interfaces đại diện cho Dữ liệu
│   ├── repositories/
│   │   └── receipt.repository.ts# Tầng Repository thực thi SQL Parameterized Queries (Chống SQL Injection)
│   ├── routes/
│   │   ├── health.routes.ts    # Định nghĩa Route kiểm tra sức khỏe hệ thống
│   │   └── receipt.routes.ts   # Định nghĩa Routes cho API phiếu nhập kho kèm Swagger Docs
│   ├── services/
│   │   └── receipt.service.ts  # Tầng Business Logic: Tự động tính tiền & Quản lý PostgreSQL Transaction
│   ├── app.ts                  # Cấu hình ứng dụng Express (Middlewares, Routes, Swagger UI)
│   └── server.ts               # Entry point lắng nghe Cổng PORT
├── tests/
│   ├── unit/
│   │   └── calculation.test.ts # Unit tests cho logic tính tiền & Zod validation
│   └── integration/
│       └── receipt.api.test.ts # Integration API tests kiểm tra toàn bộ REST API bằng Supertest
├── .env                        # Biến môi trường CSDL Neon & Port (Không commit git)
├── .env.example                # Mẫu biến môi trường
├── jest.config.js              # Cấu hình Jest Test runner
├── package.json                # Quản lý dependencies & npm scripts
└── tsconfig.json               # Cấu hình TypeScript Compiler
```

#### Vai trò các tầng trong Backend:
1. **Route (`src/routes/`)**: Định nghĩa URL endpoints và gán validation middleware + controller tương ứng.
2. **Validation Middleware (`src/middlewares/validate.middleware.ts`)**: Validate request body/params bằng Zod trước khi tới controller. Nếu lỗi trả HTTP 400.
3. **Controller (`src/controllers/`)**: Nhận HTTP Request, trích xuất dữ liệu, chuyển tới Service và trả HTTP Response JSON (không chứa business logic).
4. **Service (`src/services/`)**: Nơi chứa toàn bộ Business Logic (tự động tính `amount`, `totalAmount`, quản lý PostgreSQL Transaction `BEGIN`, `COMMIT`, `ROLLBACK`).
5. **Repository (`src/repositories/`)**: Nơi duy nhất tương tác với CSDL PostgreSQL bằng parameterized SQL queries (`$1, $2`).

---

### 2. Cấu trúc thư mục Frontend Mobile (`mobile/`)

Thư mục `mobile/` áp dụng mô hình **Feature-First + Clean Architecture** giúp mã nguồn dễ bảo trì và mở rộng:

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── env_config.dart         # Cấu hình Base URL (.env) & Timeout
│   │   ├── network/
│   │   │   ├── api_client.dart         # Client Dio thực hiện HTTP GET, POST, DELETE
│   │   │   └── api_exception.dart      # Chuyển đổi mã lỗi HTTP thành thông báo tiếng Việt
│   │   ├── router/
│   │   │   └── app_router.dart         # Cấu hình điều hướng bằng GoRouter (/receipts, /create, /:id)
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Giao diện chuẩn Material 3 Enterprise
│   │   └── utils/
│   │       ├── currency_formatter.dart # Định dạng tiền đồng Việt Nam (11.900.000 ₫)
│   │       └── date_formatter.dart     # Chuyển đổi định dạng ngày (YYYY-MM-DD <-> DD/MM/YYYY)
│   ├── data/
│   │   ├── models/
│   │   │   ├── receipt_model.dart      # Model Phiếu nhập kho (Receipt)
│   │   │   ├── receipt_item_model.dart # Model Chi tiết Vật tư (ReceiptItem)
│   │   │   └── create_receipt_request.dart # DTO tạo phiếu (Không gửi amount/totalAmount)
│   │   └── repositories/
│   │       └── receipt_repository.dart # Tầng Repository gọi ApiClient
│   ├── features/
│   │   └── receipts/
│   │       └── presentation/
│   │           ├── providers/
│   │           │   ├── health_provider.dart            # Riverpod check kết nối CSDL
│   │           │   ├── receipt_list_provider.dart      # Riverpod danh sách phiếu
│   │           │   ├── receipt_detail_provider.dart    # Riverpod chi tiết phiếu
│   │           │   └── create_receipt_provider.dart    # Riverpod StateNotifier tạo phiếu
│   │           └── screens/
│   │               ├── receipt_list_screen.dart        # Màn hình Danh sách + Tìm kiếm + Xóa
│   │               ├── receipt_detail_screen.dart      # Màn hình Chi tiết Form 01-VT + Xóa
│   │               └── create_receipt_screen.dart      # Màn hình Tạo phiếu Form 01-VT + Thêm/Xóa vật tư
│   └── main.dart                       # Entry point ứng dụng Flutter (ProviderScope & DotEnv)
├── test/
│   ├── unit/
│   │   ├── calculation_test.dart       # Unit test logic tính toán preview
│   │   ├── currency_formatter_test.dart# Unit test format tiền đồng ₫
│   │   └── receipt_model_test.dart     # Unit test parse JSON DTOs
│   └── widget/
│       └── receipt_screens_widget_test.dart # Widget test giao diện màn hình
├── ios/                                # Cấu hình Native iOS (Xcode)
├── android/                            # Cấu hình Native Android (Gradle)
├── pubspec.yaml                        # Quản lý dependencies Flutter
└── .env                                # Biến môi trường API_BASE_URL
```

---

## III. GIẢI THÍCH CHI TIẾT CƠ SỞ DỮ LIỆU (NEON POSTGRESQL)

Cơ sở dữ liệu chính của hệ thống là **PostgreSQL** lưu trữ trên nền tảng đám mây **Neon Database**.

### 1. Sơ đồ thực thể ERD & Mối quan hệ

```
┌──────────────────────────────────────┐       1 : N       ┌──────────────────────────────────────────┐
│            goods_receipts            │ ───────────────── │           goods_receipt_items            │
├──────────────────────────────────────┤                   ├──────────────────────────────────────────┤
│ PK  id                               │                   │ PK  id                                   │
│ UK  receipt_no                       │                   │ FK  receipt_id  ──► goods_receipts(id)    │
│     unit_name                        │                   │ UK  (receipt_id, item_order)             │
│     department_name                  │                   │     item_order                           │
│     receipt_date                     │                   │     item_name                            │
│     debit_account                    │                   │     item_code                            │
│     credit_account                   │                   │     unit                                 │
│     supplier_name                    │                   │     quantity_document                    │
│     document_no                      │                   │     quantity_received                    │
│     document_date                    │                   │     unit_price                           │
│     description                      │                   │     amount                               │
│     total_amount                     │                   │     created_at                           │
│     created_by                       │                   └──────────────────────────────────────────┘
│     delivered_by                     │
│     warehouse_keeper                 │
│     chief_accountant                 │
│     created_at                       │
│     updated_at                       │
└──────────────────────────────────────┘
```

**Mối quan hệ 1 : N (One-to-Many)**:
- Một **Phiếu nhập kho** (`goods_receipts`) chứa nhiều **Chi tiết vật tư** (`goods_receipt_items`).
- Cột `goods_receipt_items.receipt_id` đóng vai trò là Khóa ngoại (Foreign Key) tham chiếu trực tiếp đến `goods_receipts.id`.
- Tùy chọn `ON DELETE CASCADE`: Khi xóa một phiếu nhập kho, toàn bộ chi tiết vật tư liên quan thuộc phiếu đó sẽ tự động bị xóa sạch khỏi CSDL.

---

### 2. Chi tiết cấu trúc Bảng CSDL

#### Bảng `goods_receipts` (Thông tin tổng quan phiếu nhập):

| Tên Cột | Kiểu Dữ Liệu | Ràng Buộc (Constraints) | Ý Nghĩa Chức Năng |
| :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | `PRIMARY KEY` | Khóa chính tự động tăng |
| `receipt_no` | `VARCHAR(50)` | `NOT NULL, UNIQUE` | Số phiếu nhập kho (Duy nhất, ví dụ PNK001) |
| `unit_name` | `VARCHAR(255)` | `NULL` | Tên đơn vị (ví dụ: Công ty ABC) |
| `department_name` | `VARCHAR(255)` | `NULL` | Tên bộ phận / kho (ví dụ: Kho vật tư) |
| `receipt_date` | `DATE` | `NOT NULL` | Ngày lập phiếu nhập kho (YYYY-MM-DD) |
| `debit_account` | `VARCHAR(50)` | `NULL` | Tài khoản Nợ (ví dụ: 152) |
| `credit_account` | `VARCHAR(50)` | `NULL` | Tài khoản Có (ví dụ: 331) |
| `supplier_name` | `VARCHAR(255)` | `NULL` | Họ tên người giao / Nhà cung cấp |
| `document_no` | `VARCHAR(100)` | `NULL` | Theo chứng từ số |
| `document_date` | `DATE` | `NULL` | Ngày chứng từ |
| `description` | `TEXT` | `NULL` | Diễn giải / Lý do nhập kho |
| `total_amount` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Tổng số tiền của phiếu (Backend tự tính) |
| `created_by` | `VARCHAR(255)` | `NULL` | Họ tên người lập phiếu |
| `delivered_by` | `VARCHAR(255)` | `NULL` | Họ tên người giao hàng |
| `warehouse_keeper` | `VARCHAR(255)` | `NULL` | Họ tên thủ kho |
| `chief_accountant` | `VARCHAR(255)` | `NULL` | Họ tên kế toán trưởng |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời điểm tạo phiếu |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời điểm cập nhật phiếu |

#### Bảng `goods_receipt_items` (Chi tiết các mặt hàng vật tư):

| Tên Cột | Kiểu Dữ Liệu | Ràng Buộc (Constraints) | Ý Nghĩa Chức Năng |
| :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | `PRIMARY KEY` | Khóa chính tự động tăng |
| `receipt_id` | `INTEGER` | `NOT NULL, FK -> goods_receipts(id) ON DELETE CASCADE` | ID phiếu nhập kho sở hữu vật tư này |
| `item_order` | `INTEGER` | `NOT NULL, CHECK (> 0)` | Thứ tự dòng vật tư trong phiếu (STT 1, 2, 3...) |
| `item_name` | `VARCHAR(255)` | `NOT NULL` | Tên nhãn hiệu, quy cách vật tư |
| `item_code` | `VARCHAR(100)` | `NULL` | Mã số vật tư |
| `unit` | `VARCHAR(50)` | `NULL` | Đơn vị tính (Bao, Kg, m,...) |
| `quantity_document` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Số lượng theo chứng từ |
| `quantity_received` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Số lượng thực nhập |
| `unit_price` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Đơn giá |
| `amount` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Thành tiền (`quantity_received * unit_price`) |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời điểm tạo dòng vật tư |

---

### 3. Tại sao chọn Kiểu Dữ Liệu `NUMERIC(18,2)` thay vì `FLOAT`?

- **Vấn đề của FLOAT**: `FLOAT` / `REAL` sử dụng định dạng số thực dấu phẩy động IEEE 754. Khi làm việc với tiền tệ, `FLOAT` sẽ gây ra sai số ngầm (ví dụ: `0.1 + 0.2 = 0.30000000000000004`). Điều này là **KHÔNG THỂ CHẤP NHẬN ĐƯỢC** trong kế toán và tài chính doanh nghiệp.
- **Ưu điểm của NUMERIC(18,2)**: `NUMERIC(18,2)` lưu trữ số thập phân chính xác tuyệt đối với 18 chữ số tổng cộng và 2 chữ số sau dấu phẩy (hỗ trợ tới 999.999.999.999.999,99 VNĐ), đảm bảo không bao giờ bị lệch 1 đồng nào khi nhân đơn giá và cộng tổng tiền.

---

### 4. Ràng buộc & Bảo vệ Dữ liệu (Constraints)

1. **Chống âm giá trị (`CHECK Constraints`)**:
   - `total_amount >= 0`
   - `quantity_document >= 0`
   - `quantity_received >= 0`
   - `unit_price >= 0`
   - `amount >= 0`
   - `item_order > 0`
2. **Đảm bảo tính Duy nhất (`UNIQUE Constraints`)**:
   - `receipt_no` duy nhất trên toàn CSDL: Không thể tạo 2 phiếu có cùng số phiếu.
   - `CONSTRAINT unique_receipt_item_order UNIQUE (receipt_id, item_order)`: Thứ tự vật tư trong cùng 1 phiếu không bao giờ bị trùng STT.

---

### 5. Tối ưu hóa Truy vấn bằng Chỉ mục (Indexes)

- `idx_goods_receipts_receipt_date`: Tối ưu hóa truy vấn sắp xếp danh sách phiếu nhập kho theo `receipt_date DESC`.
- `idx_goods_receipt_items_receipt_id`: Tối ưu hóa truy vấn JOIN danh sách vật tư theo `receipt_id`.

---

### 6. Quy trình PostgreSQL Transaction Nguyên Tử (Atomicity)

Khi thực hiện lệnh `POST /api/receipts` để tạo phiếu nhập kho:

```
BEGIN TRANSACTION;
  │
  ├──► 1. INSERT INTO goods_receipts (...) RETURNING id;
  │
  ├──► 2. LOOP INSERT INTO goods_receipt_items (receipt_id, ...);
  │
  ├──► NẾU THÀNH CÔNG ──► COMMIT TRANSACTION; (Lưu vĩnh viễn vào CSDL)
  │
  └──► NẾU BẤT KỲ LỖI NÀO ──► ROLLBACK TRANSACTION; (Hủy bỏ toàn bộ, CSDL sạch sẽ)
```

Điều này đảm bảo không bao giờ xảy ra tình trạng lỗi làm cho phiếu được lưu mà danh sách vật tư không được lưu.

---

## IV. TÓM TẮT HƯỚNG DẪN VẬN HÀNH

### 1. Chạy Backend REST API
```bash
cd backend
npm install
npm run db:migrate
npm run dev
```
- **Swagger Documentation UI**: [http://localhost:3000/swagger](http://localhost:3000/swagger)

### 2. Chạy Frontend Mobile App (iOS Simulator)
```bash
cd mobile
flutter pub get
flutter run -d iphone
```
