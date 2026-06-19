// Widget nhập voucher — thêm vào PaymentPage
// Đặt giữa order summary card và phần "Chọn phương thức"

import 'package:flutter/material.dart';
import '../../data/voucher_api.dart';
import '../../data/voucher_model.dart';

class VoucherInputWidget extends StatefulWidget {
  final double originalPrice;
  final void Function(VoucherModel? voucher, double finalPrice)
  onVoucherChanged;

  const VoucherInputWidget({
    super.key,
    required this.originalPrice,
    required this.onVoucherChanged,
  });

  @override
  State<VoucherInputWidget> createState() => _VoucherInputWidgetState();
}

class _VoucherInputWidgetState extends State<VoucherInputWidget> {
  final _ctrl = TextEditingController();
  final _api = VoucherApi();
  VoucherModel? _applied;
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final voucher = await _api.validateVoucher(code);
      if (voucher == null) {
        setState(() {
          _error = 'Mã không hợp lệ, đã hết hạn, hoặc bạn đã dùng rồi.';
          _applied = null;
        });
        widget.onVoucherChanged(null, widget.originalPrice);
      } else {
        final discount = voucher.discountAmount(widget.originalPrice);
        final finalPrice = widget.originalPrice - discount;
        setState(() => _applied = voucher);
        widget.onVoucherChanged(voucher, finalPrice);
      }
    } catch (e) {
      setState(() => _error = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _remove() {
    setState(() {
      _applied = null;
      _error = null;
      _ctrl.clear();
    });
    widget.onVoucherChanged(null, widget.originalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final discount = _applied?.discountAmount(widget.originalPrice) ?? 0;
    final finalPrice = widget.originalPrice - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Mã giảm giá',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_applied == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã voucher...',
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _checking ? null : _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _checking
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Áp dụng',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Applied state
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _applied!.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Giảm ${_applied!.discountPercent}% (-\$${discount.toStringAsFixed(0)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.grey,
                    onPressed: _remove,
                    tooltip: 'Bỏ voucher',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tổng sau giảm
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá gốc: \$${widget.originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Text(
                        'Tổng sau giảm',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${finalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
