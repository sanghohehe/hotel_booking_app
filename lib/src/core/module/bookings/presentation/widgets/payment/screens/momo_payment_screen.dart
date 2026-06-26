import 'dart:async';
import 'dart:math';
import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:flutter/material.dart';

import '../utils/fake_qr_painter.dart';
import 'processing_screen.dart';

class MomoPaymentScreen extends StatefulWidget {
  final BookingEntity booking;
  const MomoPaymentScreen({super.key, required this.booking});

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  int _countdown = 60;
  int _qrSeed = 0;
  Timer? _timer;
  bool _processing = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _qrSeed = widget.booking.id.hashCode ^ DateTime.now().millisecondsSinceEpoch;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        _onQrExpired();
      }
    });
  }

  Future<void> _onQrExpired() async {
    if (!mounted || _dialogShowing || _processing) return;
    _dialogShowing = true;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFF3E0)),
                child: const Icon(Icons.timer_off_rounded, color: Color(0xFFE65100), size: 38),
              ),
              const SizedBox(height: 20),
              const Text('Mã QR đã hết hạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Mã QR chỉ có hiệu lực trong 60 giây.\nBạn muốn tạo mã mới hay đổi phương thức thanh toán?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('refresh'),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Tạo mã QR mới', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE2070),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop('change'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đổi phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    _dialogShowing = false;
    if (!mounted) return;
    if (action == 'refresh') _refreshQr();
    else if (action == 'change') Navigator.of(context).pop();
  }

  void _refreshQr() {
    setState(() {
      _countdown = 60;
      _qrSeed = DateTime.now().millisecondsSinceEpoch;
    });
    _startTimer();
  }

  Future<void> _confirm() async {
    setState(() => _processing = true);
    _timer?.cancel();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          booking: widget.booking,
          method: 'momo',
          onProcess: () async {
            final success = Random().nextDouble() < 0.95;
            await BookingApi().payMock(
              bookingId: widget.booking.id,
              method: 'momo',
              finalPrice: widget.booking.totalPrice,
              success: success,
            );
            return success;
          },
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
      return;
    }

    final retry = await showFailureDialog(context);
    if (!mounted) return;
    if (!retry) {
      Navigator.of(context).pop(false);
    } else {
      _refreshQr();
      setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = _countdown <= 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Thanh toán MoMo', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFAE2070), Color(0xFFD81B60)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const Text('Số tiền cần thanh toán', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
              ),
              child: Column(
                children: [
                  const Text('Quét mã QR bằng ứng dụng MoMo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: expired ? 0.25 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFAE2070), width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomPaint(painter: FakeQrPainter(seed: _qrSeed)),
                        ),
                      ),
                      if (expired)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_off_rounded, color: Color(0xFFE65100), size: 40),
                              SizedBox(height: 8),
                              Text('Mã đã hết hạn', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE65100))),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: expired
                          ? const Color(0xFFFCE4EC)
                          : _countdown <= 15
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          expired ? Icons.timer_off : Icons.timer_outlined,
                          size: 16,
                          color: expired ? Colors.red : _countdown <= 15 ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expired ? 'Mã QR đã hết hạn' : 'Hết hạn sau ${_countdown}s',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: expired ? Colors.red : _countdown <= 15 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFAE2070), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sau khi quét mã thành công trên MoMo, nhấn "Xác nhận đã thanh toán" bên dưới.',
                      style: TextStyle(fontSize: 13, color: Color(0xFFAE2070)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (expired)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Đổi method', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _refreshQr,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tạo mã mới', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAE2070),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _processing ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE2070),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Xác nhận đã thanh toán', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}