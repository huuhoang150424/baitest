# Database Documentation - Warehouse Goods Receipt Management

Hệ thống lưu trữ dữ liệu Quản lý Phiếu nhập kho (Form 01-VT) trên cơ sở dữ liệu **PostgreSQL Neon (Cloud)**.

---

## 1. Entity Relationship (ERD) & Relationships

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

**Mối quan hệ:**
- Bảng `goods_receipts` liên kết với bảng `goods_receipt_items` theo tỷ lệ **1 : N** (Một phiếu nhập kho có thể chứa nhiều mặt hàng/vật tư).
- `goods_receipt_items.receipt_id` là khóa ngoại (Foreign Key) tham chiếu tới `goods_receipts.id`.
- Tùy chọn xóa: `ON DELETE CASCADE` (khi xóa một phiếu nhập kho, toàn bộ chi tiết vật tư thuộc phiếu đó sẽ tự động bị xóa).

---

## 2. Table `goods_receipts`

Lưu thông tin tổng quan của Phiếu nhập kho.

| Tên cột | Kiểu dữ liệu | Ràng buộc (Constraint) | Diễn giải |
| :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | `PRIMARY KEY` | Khóa chính (Tự động tăng) |
| `receipt_no` | `VARCHAR(50)` | `NOT NULL, UNIQUE` | Số phiếu nhập kho (Duy nhất) |
| `unit_name` | `VARCHAR(255)` | `NULL` | Tên đơn vị |
| `department_name` | `VARCHAR(255)` | `NULL` | Tên bộ phận / kho |
| `receipt_date` | `DATE` | `NOT NULL` | Ngày lập phiếu nhập kho |
| `debit_account` | `VARCHAR(50)` | `NULL` | Tài khoản Nợ |
| `credit_account` | `VARCHAR(50)` | `NULL` | Tài khoản Có |
| `supplier_name` | `VARCHAR(255)` | `NULL` | Họ tên người giao / Nhà cung cấp |
| `document_no` | `VARCHAR(100)` | `NULL` | Theo chứng từ số |
| `document_date` | `DATE` | `NULL` | Ngày chứng từ |
| `description` | `TEXT` | `NULL` | Lý do / Diễn giải nhập kho |
| `total_amount` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Tong tiền của phiếu nhập kho |
| `created_by` | `VARCHAR(255)` | `NULL` | Người lập phiếu |
| `delivered_by` | `VARCHAR(255)` | `NULL` | Người giao hàng |
| `warehouse_keeper` | `VARCHAR(255)` | `NULL` | Thủ kho |
| `chief_accountant` | `VARCHAR(255)` | `NULL` | Kế toán trưởng |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời gian tạo bản ghi |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời gian cập nhật bản ghi |

---

## 3. Table `goods_receipt_items`

Lưu chi tiết các mặt hàng / vật tư có trong phiếu nhập kho.

| Tên cột | Kiểu dữ liệu | Ràng buộc (Constraint) | Diễn giải |
| :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | `PRIMARY KEY` | Khóa chính |
| `receipt_id` | `INTEGER` | `NOT NULL, FK -> goods_receipts(id) ON DELETE CASCADE` | ID phiếu nhập kho |
| `item_order` | `INTEGER` | `NOT NULL, CHECK (> 0)` | Thứ tự dòng vật tư |
| `item_name` | `VARCHAR(255)` | `NOT NULL` | Tên nhãn hiệu, quy cách vật tư |
| `item_code` | `VARCHAR(100)` | `NULL` | Mã số vật tư |
| `unit` | `VARCHAR(50)` | `NULL` | Đơn vị tính (Bao, Kg, m,...) |
| `quantity_document` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Số lượng theo chứng từ |
| `quantity_received` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Số lượng thực nhập |
| `unit_price` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Đơn giá |
| `amount` | `NUMERIC(18,2)` | `NOT NULL, DEFAULT 0, CHECK (>= 0)` | Thành tiền (`quantity_received * unit_price`) |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT CURRENT_TIMESTAMP` | Thời gian tạo bản ghi |

---

## 4. Ràng buộc (Constraints) & Bảo mật dữ liệu

1. **Kiểu tiền tệ (Money Fields)**:
   - Sử dụng `NUMERIC(18,2)` cho tất cả các trường tiền tệ (`unit_price`, `amount`, `total_amount`) và số lượng (`quantity_document`, `quantity_received`).
   - **Tuyệt đối không dùng FLOAT / REAL** để tránh sai số tính toán làm tròn số thập phân.
2. **Tính toán tự động (Backend Auto-Calculation)**:
   - `amount = quantity_received * unit_price`
   - `total_amount = SUM(amount)`
3. **Ràng buộc giá trị không âm (Check Constraints)**:
   - `total_amount >= 0`
   - `quantity_document >= 0`
   - `quantity_received >= 0`
   - `unit_price >= 0`
   - `amount >= 0`
   - `item_order > 0`
4. **Ràng buộc duy nhất (Unique Constraints)**:
   - `receipt_no` phải là duy nhất trên toàn hệ thống (`UNIQUE`).
   - Thứ tự vật tư trong cùng 1 phiếu `(receipt_id, item_order)` phải là duy nhất (`UNIQUE`).

---

## 5. Chỉ mục (Indexes)

- `idx_goods_receipts_receipt_date`: Tối ưu hóa truy vấn sắp xếp danh sách phiếu nhập kho theo `receipt_date DESC`.
- `idx_goods_receipt_items_receipt_id`: Tối ưu hóa truy vấn JOIN lấy danh sách vật tư theo `receipt_id`.
