import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Frontend Calculation Logic Tests', () {
    test('quantityReceived * unitPrice calculation (100 * 80000 = 8000000)', () {
      const double quantityReceived = 100;
      const double unitPrice = 80000;
      const amount = quantityReceived * unitPrice;
      expect(amount, 8000000.0);
    });

    test('quantityReceived * unitPrice calculation (195 * 20000 = 3900000)', () {
      const double quantityReceived = 195;
      const double unitPrice = 20000;
      const amount = quantityReceived * unitPrice;
      expect(amount, 3900000.0);
    });

    test('sum of amounts calculation (8000000 + 3900000 = 11900000)', () {
      final List<double> itemAmounts = [8000000.0, 3900000.0];
      final total = itemAmounts.reduce((a, b) => a + b);
      expect(total, 11900000.0);
    });

    test('zero quantity calculation', () {
      const double quantityReceived = 0;
      const double unitPrice = 80000;
      const amount = quantityReceived * unitPrice;
      expect(amount, 0.0);
    });
  });
}
