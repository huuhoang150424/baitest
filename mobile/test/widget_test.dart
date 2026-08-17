import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_receipt_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WarehouseReceiptApp(),
      ),
    );
    expect(find.byType(WarehouseReceiptApp), findsOneWidget);
  });
}
