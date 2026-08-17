class CreateReceiptItemRequest {
  final int itemOrder;
  final String itemName;
  final String? itemCode;
  final String? unit;
  final double quantityDocument;
  final double quantityReceived;
  final double unitPrice;

  CreateReceiptItemRequest({
    required this.itemOrder,
    required this.itemName,
    this.itemCode,
    this.unit,
    required this.quantityDocument,
    required this.quantityReceived,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemOrder': itemOrder,
      'itemName': itemName,
      if (itemCode != null && itemCode!.isNotEmpty) 'itemCode': itemCode,
      if (unit != null && unit!.isNotEmpty) 'unit': unit,
      'quantityDocument': quantityDocument,
      'quantityReceived': quantityReceived,
      'unitPrice': unitPrice,
      // Note: amount is NOT sent to backend (backend auto-calculates)
    };
  }
}

class CreateReceiptRequest {
  final String receiptNo;
  final String? unitName;
  final String? departmentName;
  final String receiptDate;
  final String? debitAccount;
  final String? creditAccount;
  final String? supplierName;
  final String? documentNo;
  final String? documentDate;
  final String? description;
  final String? createdBy;
  final String? deliveredBy;
  final String? warehouseKeeper;
  final String? chiefAccountant;
  final List<CreateReceiptItemRequest> items;

  CreateReceiptRequest({
    required this.receiptNo,
    this.unitName,
    this.departmentName,
    required this.receiptDate,
    this.debitAccount,
    this.creditAccount,
    this.supplierName,
    this.documentNo,
    this.documentDate,
    this.description,
    this.createdBy,
    this.deliveredBy,
    this.warehouseKeeper,
    this.chiefAccountant,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiptNo': receiptNo,
      if (unitName != null && unitName!.isNotEmpty) 'unitName': unitName,
      if (departmentName != null && departmentName!.isNotEmpty) 'departmentName': departmentName,
      'receiptDate': receiptDate,
      if (debitAccount != null && debitAccount!.isNotEmpty) 'debitAccount': debitAccount,
      if (creditAccount != null && creditAccount!.isNotEmpty) 'creditAccount': creditAccount,
      if (supplierName != null && supplierName!.isNotEmpty) 'supplierName': supplierName,
      if (documentNo != null && documentNo!.isNotEmpty) 'documentNo': documentNo,
      if (documentDate != null && documentDate!.isNotEmpty) 'documentDate': documentDate,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (createdBy != null && createdBy!.isNotEmpty) 'createdBy': createdBy,
      if (deliveredBy != null && deliveredBy!.isNotEmpty) 'deliveredBy': deliveredBy,
      if (warehouseKeeper != null && warehouseKeeper!.isNotEmpty) 'warehouseKeeper': warehouseKeeper,
      if (chiefAccountant != null && chiefAccountant!.isNotEmpty) 'chiefAccountant': chiefAccountant,
      'items': items.map((e) => e.toJson()).toList(),
      // Note: totalAmount is NOT sent to backend (backend auto-calculates)
    };
  }
}
