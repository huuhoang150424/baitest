export interface GoodsReceiptItem {
  id: number;
  receiptId: number;
  itemOrder: number;
  itemName: string;
  itemCode?: string | null;
  unit?: string | null;
  quantityDocument: number;
  quantityReceived: number;
  unitPrice: number;
  amount: number;
  createdAt?: string;
}

export interface GoodsReceipt {
  id: number;
  receiptNo: string;
  unitName?: string | null;
  departmentName?: string | null;
  receiptDate: string;
  debitAccount?: string | null;
  creditAccount?: string | null;
  supplierName?: string | null;
  documentNo?: string | null;
  documentDate?: string | null;
  description?: string | null;
  totalAmount: number;
  createdBy?: string | null;
  deliveredBy?: string | null;
  warehouseKeeper?: string | null;
  chiefAccountant?: string | null;
  createdAt?: string;
  updatedAt?: string;
  items?: GoodsReceiptItem[];
}

export interface GoodsReceiptListItem {
  id: number;
  receiptNo: string;
  receiptDate: string;
  supplierName?: string | null;
  totalAmount: number;
  createdAt?: string;
}

export interface CreateReceiptItemInput {
  itemOrder: number;
  itemName: string;
  itemCode?: string | null;
  unit?: string | null;
  quantityDocument: number;
  quantityReceived: number;
  unitPrice: number;
  amount?: number; // client can supply, but backend will ignore & recalculate
}

export interface CreateReceiptInput {
  receiptNo: string;
  unitName?: string | null;
  departmentName?: string | null;
  receiptDate: string;
  debitAccount?: string | null;
  creditAccount?: string | null;
  supplierName?: string | null;
  documentNo?: string | null;
  documentDate?: string | null;
  description?: string | null;
  createdBy?: string | null;
  deliveredBy?: string | null;
  warehouseKeeper?: string | null;
  chiefAccountant?: string | null;
  items: CreateReceiptItemInput[];
  totalAmount?: number; // client can supply, but backend will ignore & recalculate
}

export interface CreateReceiptResult {
  id: number;
  receiptNo: string;
  receiptDate: string;
  totalAmount: number;
}
