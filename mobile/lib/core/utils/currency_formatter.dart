import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Format a numeric amount to Vietnamese currency string (e.g. 11.900.000 ₫)
  static String format(num amount) {
    return _formatter.format(amount).trim();
  }
}
