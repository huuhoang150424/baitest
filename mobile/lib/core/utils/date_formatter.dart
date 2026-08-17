import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');

  /// Convert ISO / YYYY-MM-DD string to display format (DD/MM/YYYY)
  static String toDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return _displayDateFormat.format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  /// Convert DateTime to API format (YYYY-MM-DD)
  static String toApi(DateTime dateTime) {
    return _apiDateFormat.format(dateTime);
  }

  /// Format DateTime for UI display (DD/MM/YYYY)
  static String formatDateTime(DateTime dateTime) {
    return _displayDateFormat.format(dateTime);
  }
}
