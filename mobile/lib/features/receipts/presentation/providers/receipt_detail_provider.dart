import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/receipt_model.dart';
import 'receipt_repository_provider.dart';

final receiptDetailProvider = FutureProvider.autoDispose.family<Receipt, int>((ref, id) async {
  final repository = ref.watch(receiptRepositoryProvider);
  return await repository.getReceiptById(id);
});
