import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/create_receipt_request.dart';
import '../providers/create_receipt_provider.dart';

class CreateReceiptItemFormModel {
  int itemOrder;
  TextEditingController itemNameController;
  TextEditingController itemCodeController;
  TextEditingController unitController;
  TextEditingController quantityDocController;
  TextEditingController quantityRecController;
  TextEditingController unitPriceController;

  CreateReceiptItemFormModel({
    required this.itemOrder,
    String itemName = '',
    String itemCode = '',
    String unit = '',
    String quantityDoc = '1',
    String quantityRec = '1',
    String unitPrice = '0',
  })  : itemNameController = TextEditingController(text: itemName),
        itemCodeController = TextEditingController(text: itemCode),
        unitController = TextEditingController(text: unit),
        quantityDocController = TextEditingController(text: quantityDoc),
        quantityRecController = TextEditingController(text: quantityRec),
        unitPriceController = TextEditingController(text: unitPrice);

  double get quantityReceived => double.tryParse(quantityRecController.text) ?? 0.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get previewAmount => quantityReceived * unitPrice;

  void dispose() {
    itemNameController.dispose();
    itemCodeController.dispose();
    unitController.dispose();
    quantityDocController.dispose();
    quantityRecController.dispose();
    unitPriceController.dispose();
  }
}

class CreateReceiptScreen extends ConsumerStatefulWidget {
  const CreateReceiptScreen({super.key});

  @override
  ConsumerState<CreateReceiptScreen> createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends ConsumerState<CreateReceiptScreen> {
  final _formKey = GlobalKey<FormState>();

  final _receiptNoController = TextEditingController();
  final _unitNameController = TextEditingController();
  final _departmentNameController = TextEditingController();
  final _debitAccountController = TextEditingController(text: '152');
  final _creditAccountController = TextEditingController(text: '331');
  final _supplierNameController = TextEditingController();
  final _documentNoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _createdByController = TextEditingController();
  final _deliveredByController = TextEditingController();
  final _warehouseKeeperController = TextEditingController();
  final _chiefAccountantController = TextEditingController();

  DateTime _receiptDate = DateTime.now();
  DateTime? _documentDate;

  final List<CreateReceiptItemFormModel> _items = [];

  @override
  void initState() {
    super.initState();
    // Default: Add 1 initial item card
    _addItem();
  }

  void _addItem() {
    setState(() {
      _items.add(
        CreateReceiptItemFormModel(
          itemOrder: _items.length + 1,
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phiếu nhập kho phải chứa ít nhất 1 vật tư'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
      // Re-index itemOrders
      for (int i = 0; i < _items.length; i++) {
        _items[i].itemOrder = i + 1;
      }
    });
  }

  double get _calculatedTotalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.previewAmount);
  }

  @override
  void dispose() {
    _receiptNoController.dispose();
    _unitNameController.dispose();
    _departmentNameController.dispose();
    _debitAccountController.dispose();
    _creditAccountController.dispose();
    _supplierNameController.dispose();
    _documentNoController.dispose();
    _descriptionController.dispose();
    _createdByController.dispose();
    _deliveredByController.dispose();
    _warehouseKeeperController.dispose();
    _chiefAccountantController.dispose();

    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _selectReceiptDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiptDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _receiptDate = picked;
      });
    }
  }

  Future<void> _selectDocumentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _documentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _documentDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 vật tư'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final request = CreateReceiptRequest(
      receiptNo: _receiptNoController.text.trim(),
      unitName: _unitNameController.text.trim(),
      departmentName: _departmentNameController.text.trim(),
      receiptDate: DateFormatter.toApi(_receiptDate),
      debitAccount: _debitAccountController.text.trim(),
      creditAccount: _creditAccountController.text.trim(),
      supplierName: _supplierNameController.text.trim(),
      documentNo: _documentNoController.text.trim(),
      documentDate: _documentDate != null ? DateFormatter.toApi(_documentDate!) : null,
      description: _descriptionController.text.trim(),
      createdBy: _createdByController.text.trim(),
      deliveredBy: _deliveredByController.text.trim(),
      warehouseKeeper: _warehouseKeeperController.text.trim(),
      chiefAccountant: _chiefAccountantController.text.trim(),
      items: _items.map((item) {
        return CreateReceiptItemRequest(
          itemOrder: item.itemOrder,
          itemName: item.itemNameController.text.trim(),
          itemCode: item.itemCodeController.text.trim(),
          unit: item.unitController.text.trim(),
          quantityDocument: double.tryParse(item.quantityDocController.text) ?? 0.0,
          quantityReceived: double.tryParse(item.quantityRecController.text) ?? 0.0,
          unitPrice: double.tryParse(item.unitPriceController.text) ?? 0.0,
        );
      }).toList(),
    );

    try {
      await ref.read(createReceiptProvider.notifier).submitReceipt(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm phiếu nhập thành công!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        context.pop(true);
      }
    } on ApiException catch (apiErr) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErr.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createReceiptState = ref.watch(createReceiptProvider);
    final isSubmitting = createReceiptState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo phiếu nhập kho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('THÔNG TIN CHUNG PHIẾU (FORM 01-VT)', Icons.description),
              const SizedBox(height: 8),

              TextFormField(
                controller: _receiptNoController,
                decoration: const InputDecoration(
                  labelText: 'Số phiếu *',
                  hintText: 'Ví dụ: PNK001',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số phiếu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị',
                        hintText: 'Công ty ABC',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _departmentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bộ phận',
                        hintText: 'Kho vật tư',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _selectReceiptDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày nhập *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormatter.formatDateTime(_receiptDate)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _debitAccountController,
                      decoration: const InputDecoration(
                        labelText: 'Tài khoản Nợ',
                        hintText: '152',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _creditAccountController,
                      decoration: const InputDecoration(
                        labelText: 'Tài khoản Có',
                        hintText: '331',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _supplierNameController,
                decoration: const InputDecoration(
                  labelText: 'Nhà cung cấp / Người giao',
                  hintText: 'Nhà cung cấp XYZ',
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _documentNoController,
                      decoration: const InputDecoration(
                        labelText: 'Theo chứng từ số',
                        hintText: 'CT001',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDocumentDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày chứng từ',
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(
                          _documentDate != null
                              ? DateFormatter.formatDateTime(_documentDate!)
                              : 'Chọn ngày',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Diễn giải / Lý do nhập kho',
                  hintText: 'Nhập vật tư phục vụ sản xuất...',
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('NGƯỜI LIÊN QUAN', Icons.people_outline),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _createdByController,
                      decoration: const InputDecoration(labelText: 'Người lập'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _deliveredByController,
                      decoration: const InputDecoration(labelText: 'Người giao'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _warehouseKeeperController,
                      decoration: const InputDecoration(labelText: 'Thủ kho'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _chiefAccountantController,
                      decoration: const InputDecoration(labelText: 'Kế toán trưởng'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('DANH SÁCH VẬT TƯ', Icons.playlist_add_check),
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm vật tư'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...List.generate(_items.length, (index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFCFD8DC)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${item.itemOrder} Vật tư',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _removeItem(index),
                              tooltip: 'Xóa vật tư này',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: item.itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên vật tư *',
                            hintText: 'Xi măng, Sắt, Gạch...',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập tên vật tư';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: item.itemCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Mã vật tư',
                                  hintText: 'XM001',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: item.unitController,
                                decoration: const InputDecoration(
                                  labelText: 'Đơn vị tính',
                                  hintText: 'Bao, Kg, m...',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: item.quantityDocController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'SL chứng từ',
                                ),
                                validator: (val) {
                                  final numVal = double.tryParse(val ?? '');
                                  if (numVal == null || numVal < 0) {
                                    return 'SL không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: item.quantityRecController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'SL thực nhập *',
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (val) {
                                  final numVal = double.tryParse(val ?? '');
                                  if (numVal == null || numVal < 0) {
                                    return 'SL không được âm';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: item.unitPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Đơn giá (VNĐ) *',
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            final numVal = double.tryParse(val ?? '');
                            if (numVal == null || numVal < 0) {
                              return 'Đơn giá không được âm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thành tiền (Preview):',
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            Text(
                              CurrencyFormatter.format(item.previewAmount),
                              style: const TextStyle(
                                fontSize: 14,
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

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TỔNG TIỀN DỰ KIẾN:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_calculatedTotalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitForm,
                  child: isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Cập nhật...'),
                          ],
                        )
                      : const Text('LƯU PHIẾU NHẬP KHO'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1565C0)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
