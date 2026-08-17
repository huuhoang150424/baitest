import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_receipt_app/data/models/receipt_model.dart';
import 'package:warehouse_receipt_app/data/models/create_receipt_request.dart';

void main() {
  group('Receipt Model Parsing Tests', () {
    test('Receipt.fromJson should correctly parse backend JSON format', () {
      final json = {
        'id': 1,
        'receiptNo': 'PNK001',
        'unitName': 'Công ty ABC',
        'departmentName': 'Kho vật tư',
        'receiptDate': '2026-08-17',
        'debitAccount': '152',
        'creditAccount': '331',
        'supplierName': 'Nhà cung cấp XYZ',
        'totalAmount': 11900000,
        'items': [
          {
            'id': 1,
            'itemOrder': 1,
            'itemName': 'Xi măng',
            'itemCode': 'XM001',
            'unit': 'Bao',
            'quantityDocument': 100,
            'quantityReceived': 100,
            'unitPrice': 80000,
            'amount': 8000000
          }
        ]
      };

      final receipt = Receipt.fromJson(json);

      expect(receipt.id, 1);
      expect(receipt.receiptNo, 'PNK001');
      expect(receipt.totalAmount, 11900000.0);
      expect(receipt.items, isNotNull);
      expect(receipt.items!.length, 1);
      expect(receipt.items![0].itemName, 'Xi măng');
      expect(receipt.items![0].amount, 8000000.0);
    });

    test('CreateReceiptRequest.toJson should exclude amount & totalAmount', () {
      final request = CreateReceiptRequest(
        receiptNo: 'PNK001',
        receiptDate: '2026-08-17',
        items: [
          CreateReceiptItemRequest(
            itemOrder: 1,
            itemName: 'Xi măng',
            quantityDocument: 100,
            quantityReceived: 100,
            unitPrice: 80000,
          )
        ],
      );

      final json = request.toJson();

      expect(json.containsKey('amount'), isFalse);
      expect(json.containsKey('totalAmount'), isFalse);
      expect(json['receiptNo'], 'PNK001');
      expect(json['items'], isA<List>());
      expect((json['items'] as List)[0].containsKey('amount'), isFalse);
    });
  });
}
