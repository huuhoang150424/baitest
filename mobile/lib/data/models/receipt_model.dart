import 'receipt_item_model.dart';

class Receipt {
  final int id;
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
  final double totalAmount;
  final String? createdBy;
  final String? deliveredBy;
  final String? warehouseKeeper;
  final String? chiefAccountant;
  final String? createdAt;
  final List<ReceiptItem>? items;

  Receipt({
    required this.id,
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
    required this.totalAmount,
    this.createdBy,
    this.deliveredBy,
    this.warehouseKeeper,
    this.chiefAccountant,
    this.createdAt,
    this.items,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as int,
      receiptNo: json['receiptNo'] ?? '',
      unitName: json['unitName'] as String?,
      departmentName: json['departmentName'] as String?,
      receiptDate: json['receiptDate'] ?? '',
      debitAccount: json['debitAccount'] as String?,
      creditAccount: json['creditAccount'] as String?,
      supplierName: json['supplierName'] as String?,
      documentNo: json['documentNo'] as String?,
      documentDate: json['documentDate'] as String?,
      description: json['description'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['createdBy'] as String?,
      deliveredBy: json['deliveredBy'] as String?,
      warehouseKeeper: json['warehouseKeeper'] as String?,
      chiefAccountant: json['chiefAccountant'] as String?,
      createdAt: json['createdAt'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
