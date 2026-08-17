import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/receipt_model.dart';
import 'receipt_repository_provider.dart';

final receiptListProvider = FutureProvider.autoDispose<List<Receipt>>((ref) async {
  final repository = ref.watch(receiptRepositoryProvider);
  return await repository.getReceipts();
});
