import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/receipt_detail_provider.dart';
import '../providers/receipt_list_provider.dart';
import '../providers/receipt_repository_provider.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final int receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref, String receiptNo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa phiếu'),
        content: Text('Bạn có chắc chắn muốn xóa phiếu nhập kho "$receiptNo" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(receiptRepositoryProvider);
        await repository.deleteReceipt(receiptId);

        if (context.mounted) {
          ref.invalidate(receiptListProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa phiếu nhập kho thành công!'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          context.pop(true);
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể xóa phiếu. Vui lòng thử lại.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(receiptDetailProvider(receiptId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết phiếu #$receiptId'),
        actions: [
          detailState.maybeWhen(
            data: (receipt) => IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _confirmAndDelete(context, ref, receipt.receiptNo),
              tooltip: 'Xóa phiếu nhập',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailState.when(
        data: (receipt) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('THÔNG TIN PHIẾU', Icons.receipt_long),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Số phiếu:', receipt.receiptNo, isHeader: true),
                        _buildInfoRow('Ngày nhập:', DateFormatter.toDisplay(receipt.receiptDate)),
                        _buildInfoRow('Đơn vị:', receipt.unitName ?? 'N/A'),
                        _buildInfoRow('Bộ phận:', receipt.departmentName ?? 'N/A'),
                        _buildInfoRow('Nhà cung cấp:', receipt.supplierName ?? 'N/A'),
                        _buildInfoRow('Số chứng từ:', receipt.documentNo ?? 'N/A'),
                        _buildInfoRow('Ngày chứng từ:', DateFormatter.toDisplay(receipt.documentDate)),
                        _buildInfoRow('Tài khoản Nợ:', receipt.debitAccount ?? 'N/A'),
                        _buildInfoRow('Tài khoản Có:', receipt.creditAccount ?? 'N/A'),
                        _buildInfoRow('Diễn giải:', receipt.description ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('NGƯỜI LIÊN QUAN', Icons.people),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Người lập:', receipt.createdBy ?? 'N/A'),
                        _buildInfoRow('Người giao:', receipt.deliveredBy ?? 'N/A'),
                        _buildInfoRow('Thủ kho:', receipt.warehouseKeeper ?? 'N/A'),
                        _buildInfoRow('Kế toán trưởng:', receipt.chiefAccountant ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('DANH SÁCH VẬT TƯ', Icons.view_list),
                if (receipt.items == null || receipt.items!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Không có chi tiết vật tư.'),
                  )
                else
                  ...receipt.items!.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '#${item.itemOrder}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.itemName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (item.itemCode != null && item.itemCode!.isNotEmpty)
                              _buildSubInfo('Mã vật tư', item.itemCode!),
                            if (item.unit != null && item.unit!.isNotEmpty)
                              _buildSubInfo('Đơn vị tính', item.unit!),
                            _buildSubInfo('SL chứng từ', item.quantityDocument.toString()),
                            _buildSubInfo('SL thực nhập', item.quantityReceived.toString()),
                            _buildSubInfo('Đơn giá', CurrencyFormatter.format(item.unitPrice)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thành tiền:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.amount),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TỔNG TIỀN PHIẾU:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(receipt.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không thể tải chi tiết phiếu nhập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(receiptDetailProvider(receiptId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
