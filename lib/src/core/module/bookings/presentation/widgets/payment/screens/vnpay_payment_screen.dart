import 'dart:async';
import 'dart:math';
import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/payment_formatters.dart';
import 'processing_screen.dart';

class VnpayPaymentScreen extends StatefulWidget {
  final BookingEntity booking;
  const VnpayPaymentScreen({super.key, required this.booking});

  @override
  State<VnpayPaymentScreen> createState() => _VnpayPaymentScreenState();
}

class _VnpayPaymentScreenState extends State<VnpayPaymentScreen> {
  final _cardCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showOtp = false;
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  int _otpCountdown = 120;
  Timer? _otpTimer;
  bool _processing = false;
  String _generatedOtp = '';

  @override
  void dispose() {
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _bankCtrl.dispose();
    _otpTimer?.cancel();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    _generatedOtp = (100000 + Random().nextInt(900000)).toString();

    setState(() {
      _showOtp = true;
      _otpCountdown = 120;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sms_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Mã OTP: $_generatedOtp  (Demo)'),
          ],
        ),
        backgroundColor: const Color(0xFF005BAA),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _otpCountdown--);
      if (_otpCountdown <= 0) t.cancel();
    });
  }

  Future<void> _verifyOtp() async {
    final entered = _otpCtrls.map((c) => c.text).join();
    if (entered.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập đủ 6 số OTP'), backgroundColor: Colors.red));
      return;
    }
    if (entered != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP không đúng'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _processing = true);
    _otpTimer?.cancel();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          booking: widget.booking,
          method: 'vnpay',
          onProcess: () async {
            final success = Random().nextDouble() < 0.95;
            await BookingApi().payMock(
              bookingId: widget.booking.id,
              method: 'vnpay',
              finalPrice: widget.booking.totalPrice,
              success: success,
            );
            return success;
          },
        ),
      ),
    );

    if (result == false && mounted) {
      final retry = await showFailureDialog(context);
      if (!retry && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        for (final c in _otpCtrls) {
          c.clear();
        }
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('VNPay', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF003087), Color(0xFF005BAA)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text('VNPay Secure Gateway', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_showOtp) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin thẻ ATM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 16),
                      _VnpayField(
                        controller: _cardCtrl,
                        label: 'Số thẻ ATM',
                        hint: '9704 XXXX XXXX XXXX',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter(),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        validator: (v) {
                          final clean = v?.replaceAll(' ', '') ?? '';
                          if (clean.length < 16) return 'Số thẻ không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _VnpayField(
                        controller: _nameCtrl,
                        label: 'Tên chủ thẻ',
                        hint: 'NGUYEN VAN A',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Nhập tên chủ thẻ' : null,
                      ),
                      const SizedBox(height: 14),
                      _VnpayField(
                        controller: _bankCtrl,
                        label: 'Tên ngân hàng',
                        hint: 'Vietcombank / Techcombank...',
                        icon: Icons.account_balance_rounded,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Nhập tên ngân hàng' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005BAA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Nhận mã OTP', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                      child: const Icon(Icons.sms_rounded, color: Color(0xFF005BAA), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nhập mã OTP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Mã OTP đã gửi đến SĐT đăng ký thẻ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        return Container(
                          width: 44,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF005BAA), width: 1.5), borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: TextField(
                              controller: _otpCtrls[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (v) {
                                if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _otpCountdown > 0 ? 'Hết hạn sau ${_otpCountdown}s' : 'OTP đã hết hạn',
                      style: TextStyle(color: _otpCountdown > 30 ? Colors.grey : Colors.red, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_processing || _otpCountdown <= 0) ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005BAA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Xác nhận OTP', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VnpayField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const _VnpayField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF005BAA), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF005BAA), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}