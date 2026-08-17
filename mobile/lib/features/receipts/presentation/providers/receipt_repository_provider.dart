import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository();
});
