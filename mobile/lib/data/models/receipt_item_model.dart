class ReceiptItem {
  final int? id;
  final int? receiptId;
  final int itemOrder;
  final String itemName;
  final String? itemCode;
  final String? unit;
  final double quantityDocument;
  final double quantityReceived;
  final double unitPrice;
  final double amount;

  ReceiptItem({
    this.id,
    this.receiptId,
    required this.itemOrder,
    required this.itemName,
    this.itemCode,
    this.unit,
    required this.quantityDocument,
    required this.quantityReceived,
    required this.unitPrice,
    required this.amount,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] as int?,
      receiptId: json['receiptId'] as int?,
      itemOrder: json['itemOrder'] is int
          ? json['itemOrder'] as int
          : int.tryParse(json['itemOrder'].toString()) ?? 1,
      itemName: json['itemName'] ?? '',
      itemCode: json['itemCode'] as String?,
      unit: json['unit'] as String?,
      quantityDocument: (json['quantityDocument'] as num?)?.toDouble() ?? 0.0,
      quantityReceived: (json['quantityReceived'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (receiptId != null) 'receiptId': receiptId,
      'itemOrder': itemOrder,
      'itemName': itemName,
      'itemCode': itemCode,
      'unit': unit,
      'quantityDocument': quantityDocument,
      'quantityReceived': quantityReceived,
      'unitPrice': unitPrice,
      'amount': amount,
    };
  }
}
