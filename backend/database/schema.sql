-- Database Schema for Warehouse Goods Receipt Management (Phiếu Nhập Kho - Form 01-VT)

CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    receipt_no VARCHAR(50) NOT NULL UNIQUE,
    unit_name VARCHAR(255),
    department_name VARCHAR(255),
    receipt_date DATE NOT NULL,
    debit_account VARCHAR(50),
    credit_account VARCHAR(50),
    supplier_name VARCHAR(255),
    document_no VARCHAR(100),
    document_date DATE,
    description TEXT,
    total_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    created_by VARCHAR(255),
    delivered_by VARCHAR(255),
    warehouse_keeper VARCHAR(255),
    chief_accountant VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id SERIAL PRIMARY KEY,
    receipt_id INTEGER NOT NULL REFERENCES goods_receipts(id) ON DELETE CASCADE,
    item_order INTEGER NOT NULL CHECK (item_order > 0),
    item_name VARCHAR(255) NOT NULL,
    item_code VARCHAR(100),
    unit VARCHAR(50),
    quantity_document NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (quantity_document >= 0),
    quantity_received NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (quantity_received >= 0),
    unit_price NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (unit_price >= 0),
    amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_receipt_item_order UNIQUE (receipt_id, item_order)
);

-- Indexes for optimal query performance
CREATE INDEX IF NOT EXISTS idx_goods_receipts_receipt_date ON goods_receipts(receipt_date DESC);
CREATE INDEX IF NOT EXISTS idx_goods_receipt_items_receipt_id ON goods_receipt_items(receipt_id);
