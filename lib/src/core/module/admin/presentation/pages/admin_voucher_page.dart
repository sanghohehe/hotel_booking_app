import 'package:booking_app/src/core/module/vouchers/data/voucher_api.dart';
import 'package:booking_app/src/core/module/vouchers/data/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class AdminVoucherPage extends StatefulWidget {
  const AdminVoucherPage({super.key});

  @override
  State<AdminVoucherPage> createState() => _AdminVoucherPageState();
}

class _AdminVoucherPageState extends State<AdminVoucherPage> {
  final _api = VoucherApi();
  late Future<List<VoucherModel>> _future;
  final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _future = _api.getAllVouchers();
  }

  void _reload() => setState(() => _future = _api.getAllVouchers());

  Color _statusColor(VoucherModel v) {
    if (!v.isActive) return Colors.grey;
    if (v.isExpired) return Colors.red;
    if (v.isNotStarted) return Colors.orange;
    if (v.isFull) return Colors.purple;
    return Colors.green;
  }

  String _statusLabel(VoucherModel v) {
    if (!v.isActive) return 'Tắt';
    if (v.isExpired) return 'Hết hạn';
    if (v.isNotStarted) return 'Chưa bắt đầu';
    if (v.isFull) return 'Hết lượt';
    return 'Đang hoạt động';
  }

  Future<void> _openForm({VoucherModel? voucher}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VoucherFormSheet(voucher: voucher, api: _api),
    );
    if (result == true) _reload();
  }

  Future<void> _delete(VoucherModel v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xóa voucher'),
            content: Text('Xóa voucher "${v.code}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _api.deleteVoucher(v.id);
      _reload();
    }
  }

  Future<void> _toggle(VoucherModel v) async {
    await _api.toggleActive(v.id, !v.isActive);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý Voucher'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tạo voucher'),
      ),
      body: FutureBuilder<List<VoucherModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final vouchers = snapshot.data ?? [];

          if (vouchers.isEmpty) {
            return const Center(child: Text('Chưa có voucher nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: vouchers.length,
              itemBuilder: (_, i) {
                final v = vouchers[i];
                final statusColor = _statusColor(v);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code + status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              v.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(v),
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '-${v.discountPercent}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Thời gian
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_dateFmt.format(v.startDate)} → ${_dateFmt.format(v.endDate)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Lượt dùng
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã dùng: ${v.usedCount}/${v.maxUses}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:
                                    v.maxUses == 0
                                        ? 0
                                        : v.usedCount / v.maxUses,
                                backgroundColor: Colors.grey[200],
                                color: v.isFull ? Colors.red : Colors.green,
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Actions
                      Row(
                        children: [
                          // Toggle active
                          Switch(
                            value: v.isActive,
                            onChanged: (_) => _toggle(v),
                            activeColor: Colors.green,
                          ),
                          Text(
                            v.isActive ? 'Bật' : 'Tắt',
                            style: TextStyle(
                              fontSize: 12,
                              color: v.isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          // Edit
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: Colors.blue,
                            onPressed: () => _openForm(voucher: v),
                            tooltip: 'Sửa',
                          ),
                          // Delete
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.red,
                            onPressed: () => _delete(v),
                            tooltip: 'Xóa',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Form tạo/sửa voucher ──
class _VoucherFormSheet extends StatefulWidget {
  final VoucherModel? voucher;
  final VoucherApi api;

  const _VoucherFormSheet({this.voucher, required this.api});

  @override
  State<_VoucherFormSheet> createState() => _VoucherFormSheetState();
}

class _VoucherFormSheetState extends State<_VoucherFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _maxUsesCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;
  final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    if (v != null) {
      _codeCtrl.text = v.code;
      _discountCtrl.text = v.discountPercent.toString();
      _maxUsesCtrl.text = v.maxUses.toString();
      _startDate = v.startDate;
      _endDate = v.endDate;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    _maxUsesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final v = widget.voucher;
      if (v == null) {
        // Tạo mới
        await _api.createVoucher(
          VoucherModel(
            id: '',
            code: _codeCtrl.text.toUpperCase().trim(),
            discountPercent: int.parse(_discountCtrl.text),
            maxUses: int.parse(_maxUsesCtrl.text),
            usedCount: 0,
            startDate: _startDate!,
            endDate: _endDate!,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        // Cập nhật
        await _api.updateVoucher(
          id: v.id,
          updates: {
            'code': _codeCtrl.text.toUpperCase().trim(),
            'discount_percent': int.parse(_discountCtrl.text),
            'max_uses': int.parse(_maxUsesCtrl.text),
            'start_date': _startDate!.toIso8601String().split('T').first,
            'end_date': _endDate!.toIso8601String().split('T').first,
          },
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  VoucherApi get _api => widget.api;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.voucher == null ? 'Tạo voucher mới' : 'Sửa voucher',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mã voucher
            TextFormField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Mã voucher (VD: SUMMER20)',
                border: OutlineInputBorder(),
              ),
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty ? 'Nhập mã voucher' : null,
            ),
            const SizedBox(height: 12),

            // Giảm giá + số lượng
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giảm giá (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0 || n > 100) return '1-100%';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxUsesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số lượt tối đa',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Nhập số > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ngày
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate == null
                          ? 'Ngày bắt đầu'
                          : _dateFmt.format(_startDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate == null
                          ? 'Ngày kết thúc'
                          : _dateFmt.format(_endDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : Text(
                          widget.voucher == null
                              ? 'Tạo voucher'
                              : 'Lưu thay đổi',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
