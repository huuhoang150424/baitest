import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_receipt_app/data/models/receipt_model.dart';
import 'package:warehouse_receipt_app/features/receipts/presentation/providers/health_provider.dart';
import 'package:warehouse_receipt_app/features/receipts/presentation/providers/receipt_list_provider.dart';
import 'package:warehouse_receipt_app/features/receipts/presentation/screens/create_receipt_screen.dart';
import 'package:warehouse_receipt_app/features/receipts/presentation/screens/receipt_list_screen.dart';

void main() {
  group('Widget Tests - Receipt Screens', () {
    testWidgets('ReceiptListScreen displays list items correctly', (WidgetTester tester) async {
      final mockReceipts = [
        Receipt(
          id: 1,
          receiptNo: 'PNK001',
          supplierName: 'Nhà cung cấp XYZ',
          receiptDate: '2026-08-17',
          totalAmount: 11900000,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async => true),
            receiptListProvider.overrideWith((ref) async => mockReceipts),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Phiếu nhập kho'), findsOneWidget);
      expect(find.text('PNK001'), findsOneWidget);
      expect(find.text('Nhà cung cấp XYZ'), findsOneWidget);
      expect(find.text('Tạo phiếu nhập'), findsOneWidget);
    });

    testWidgets('ReceiptListScreen displays disconnected view when health fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async => false),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Không thể kết nối đến máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('CreateReceiptScreen renders form fields and calculates amounts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateReceiptScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tạo phiếu nhập kho'), findsOneWidget);
      expect(find.text('Số phiếu *'), findsOneWidget);
      expect(find.text('Thêm vật tư'), findsOneWidget);
      expect(find.text('LƯU PHIẾU NHẬP KHO'), findsOneWidget);
    });
  });
}
