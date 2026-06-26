import 'dart:math';
import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/payment_formatters.dart';
import 'processing_screen.dart';

class VisaPaymentScreen extends StatefulWidget {
  final BookingEntity booking;
  const VisaPaymentScreen({super.key, required this.booking});

  @override
  State<VisaPaymentScreen> createState() => _VisaPaymentScreenState();
}

class _VisaPaymentScreenState extends State<VisaPaymentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _isFlipped = false;
  bool _processing = false;
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
    _cvvCtrl.addListener(() {
      final hasFocus = _cvvCtrl.text.isNotEmpty;
      if (hasFocus && !_isFlipped) {
        setState(() => _isFlipped = true);
        _flipCtrl.forward();
      } else if (!hasFocus && _isFlipped) {
        setState(() => _isFlipped = false);
        _flipCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String get _displayCard {
    final v = _cardCtrl.text.replaceAll(' ', '');
    if (v.isEmpty) return '**** **** **** ****';
    final padded = v.padRight(16, '*');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }

  bool get _isVisa => _cardCtrl.text.startsWith('4');
  bool get _isMaster => _cardCtrl.text.startsWith('5');

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => ProcessingScreen(
              booking: widget.booking,
              method: 'visa',
              onProcess: () async {
                final success = Random().nextDouble() < 0.95;
                await BookingApi().payMock(
                  bookingId: widget.booking.id,
                  method: 'visa',
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
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Thẻ quốc tế',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (_, __) {
                    final angle = _flipAnim.value * pi;
                    final showFront = angle < pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                      child: showFront ? _buildCardFront() : _buildCardBack(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberFormatter(),
                        LengthLimitingTextInputFormatter(19),
                      ],
                      validator: (v) {
                        final clean = v?.replaceAll(' ', '') ?? '';
                        if (clean.length < 16)
                          return 'Số thẻ không hợp lệ (cần 16 số)';
                        return null;
                      },
                      decoration: _fieldDecor(
                        'Số thẻ',
                        '1234 5678 9012 3456',
                        Icons.credit_card,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => setState(() {}),
                      validator:
                          (v) =>
                              (v?.trim().isEmpty ?? true)
                                  ? 'Nhập tên chủ thẻ'
                                  : null,
                      decoration: _fieldDecor(
                        'Tên chủ thẻ',
                        'NGUYEN VAN A',
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ExpiryFormatter(),
                              LengthLimitingTextInputFormatter(5),
                            ],
                            validator: (v) {
                              if (v == null || v.length < 5) return 'MM/YY';
                              return null;
                            },
                            decoration: _fieldDecor(
                              'Hết hạn',
                              'MM/YY',
                              Icons.date_range,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator:
                                (v) => (v?.length ?? 0) < 3 ? 'CVV 3 số' : null,
                            decoration: _fieldDecor(
                              'CVV',
                              '•••',
                              Icons.lock_outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _processing ? null : _pay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1F71),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Thanh toán \$${widget.booking.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecor(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1A1F71), size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A1F71), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F71), Color(0xFF2962FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                _isVisa
                    ? 'VISA'
                    : _isMaster
                    ? 'MASTERCARD'
                    : 'CARD',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _displayCard,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    _nameCtrl.text.isEmpty ? 'YOUR NAME' : _nameCtrl.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1F71), Color(0xFF2962FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(height: 40, color: Colors.black87),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: Container(height: 36, color: Colors.white24)),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 36,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      _cvvCtrl.text.isEmpty
                          ? 'CVV'
                          : _cvvCtrl.text.padRight(3, '•'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
