import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:flutter/material.dart';

// --- Global Failure Dialog ---
Future<bool> showFailureDialog(BuildContext context) async {
  final retry = await showDialog<bool>(
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
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFCE4EC)),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Thanh toán thất bại', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Giao dịch không thể hoàn tất.\nKiểm tra lại thông tin và thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đổi phương thức', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return retry ?? false;
}

// --- Processing Screen Container ---
class ProcessingScreen extends StatefulWidget {
  final BookingEntity booking;
  final String method;
  final Future<bool> Function() onProcess;

  const ProcessingScreen({
    super.key,
    required this.booking,
    required this.method,
    required this.onProcess,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with TickerProviderStateMixin {
  int _step = 0;
  bool? _success;
  late final AnimationController _pulseCtrl;
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkAnim;
  final _steps = ['Đang kết nối...', 'Xác thực thanh toán...', 'Hoàn tất'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _runFlow();
  }

  Future<void> _runFlow() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _step = 1);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _step = 2);

    final result = await widget.onProcess();
    if (!mounted) return;

    _pulseCtrl.stop();
    setState(() => _success = result);
    _checkCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: _success == null
                        ? AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, __) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1565C0).withOpacity(0.08 + _pulseCtrl.value * 0.08),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(12 + _pulseCtrl.value * 6),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1565C0)),
                                child: const Icon(Icons.sync_rounded, color: Colors.white, size: 42),
                              ),
                            ),
                          )
                        : ScaleTransition(
                            scale: _checkAnim,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _success! ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              ),
                              child: Icon(_success! ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 56),
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                  if (_success == null) ...[
                    Text(_steps[_step], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text('Vui lòng không tắt ứng dụng', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _step;
                        final done = i < _step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: done || active ? const Color(0xFF1565C0) : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    Text(
                      _success! ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _success! ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _success! ? 'Đơn đặt phòng của bạn đã được xác nhận' : 'Giao dịch không thành công. Vui lòng thử lại.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}