import '../../core/network/api_client.dart';
import '../models/create_receipt_request.dart';
import '../models/receipt_model.dart';

class ReceiptRepository {
  final ApiClient _apiClient;

  ReceiptRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Check backend and PostgreSQL health status
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get('/health');
      if (response is Map<String, dynamic>) {
        return response['status'] == 'ok' && response['database'] == 'connected';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch list of receipts
  Future<List<Receipt>> getReceipts() async {
    final response = await _apiClient.get('/api/receipts');
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((e) => Receipt.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Fetch single receipt by ID
  Future<Receipt> getReceiptById(int id) async {
    final response = await _apiClient.get('/api/receipts/$id');
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return Receipt.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid API response format');
  }

  /// Create a new receipt
  Future<Receipt> createReceipt(CreateReceiptRequest request) async {
    final response = await _apiClient.post(
      '/api/receipts',
      data: request.toJson(),
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return Receipt.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid API response format');
  }

  /// Delete a receipt by ID
  Future<void> deleteReceipt(int id) async {
    await _apiClient.delete('/api/receipts/$id');
  }
}
