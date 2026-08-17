import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/create_receipt_request.dart';
import '../../../../data/models/receipt_model.dart';
import 'receipt_repository_provider.dart';

class CreateReceiptStateNotifier extends StateNotifier<AsyncValue<Receipt?>> {
  final Ref _ref;

  CreateReceiptStateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<Receipt?> submitReceipt(CreateReceiptRequest request) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(receiptRepositoryProvider);
      final receipt = await repository.createReceipt(request);
      state = AsyncValue.data(receipt);
      return receipt;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createReceiptProvider = StateNotifierProvider<CreateReceiptStateNotifier, AsyncValue<Receipt?>>((ref) {
  return CreateReceiptStateNotifier(ref);
});
