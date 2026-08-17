import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'receipt_repository_provider.dart';

final healthCheckProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(receiptRepositoryProvider);
  return await repository.checkHealth();
});
