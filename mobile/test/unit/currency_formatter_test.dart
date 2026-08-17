import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_receipt_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('should correctly format 8000000 to 8.000.000 ₫', () {
      final result = CurrencyFormatter.format(8000000);
      expect(result.contains('8.000.000'), isTrue);
      expect(result.contains('₫'), isTrue);
    });

    test('should correctly format 11900000 to 11.900.000 ₫', () {
      final result = CurrencyFormatter.format(11900000);
      expect(result.contains('11.900.000'), isTrue);
      expect(result.contains('₫'), isTrue);
    });

    test('should handle 0 correctly', () {
      final result = CurrencyFormatter.format(0);
      expect(result.contains('0'), isTrue);
      expect(result.contains('₫'), isTrue);
    });
  });
}
