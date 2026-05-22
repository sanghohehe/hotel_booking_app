import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// TODO: Sửa import này đúng với path project của bạn
import '../../domain/entities/bookingEntity .dart';
import '../../data/booking_api.dart';
import '../pages/bookings_page.dart'; // TODO: kiểm tra lại path này

// ══════════════════════════════════════════════
//  FAILURE DIALOG — dùng chung cho cả 3 method
// ══════════════════════════════════════════════

Future<bool> _showFailureDialog(BuildContext context) async {
  final retry = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFCE4EC),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFC62828),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thanh toán thất bại',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Giao dịch không thể hoàn tất.\nKiểm tra lại thông tin và thử lại.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Đổi phương thức',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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

// ══════════════════════════════════════════════
//  ENTRY POINT — không đổi interface với bên ngoài
// ══════════════════════════════════════════════
class PaymentPage extends StatefulWidget {
  final BookingEntity booking;
  const PaymentPage({super.key, required this.booking});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _method = 'momo';

  void _onMethodSelected(String method) {
    setState(() => _method = method);
  }

  Future<void> _proceed() async {
    Widget screen;
    switch (_method) {
      case 'momo':
        screen = _MomoScreen(booking: widget.booking);
        break;
      case 'vnpay':
        screen = _VnpayScreen(booking: widget.booking);
        break;
      default:
        screen = _VisaScreen(booking: widget.booking);
    }

    final bool? result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen));

    // Nếu thất bại (false), _ProcessingScreen đã pop về đây
    // Nếu thành công, _ProcessingScreen tự navigate đến BookingsPage rồi
    // Không cần xử lý gì thêm ở đây
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order summary card ──────────────────
            Container(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.hotel_rounded,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.hotelName ?? 'Khách sạn',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (b.roomTypeName != null)
                              Text(
                                b.roomTypeName!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Nhận phòng',
                    value: DateFormat('dd/MM/yyyy').format(b.checkIn),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Trả phòng',
                    value: DateFormat('dd/MM/yyyy').format(b.checkOut),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Khách',
                    value:
                        '${b.guestsAdults} người lớn'
                        '${b.guestsChildren > 0 ? ', ${b.guestsChildren} trẻ em' : ''}',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '\$${b.totalPrice.toStringAsFixed(0)}',
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
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Chọn phương thức',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            // ── Payment method cards ────────────────
            _MethodCard(
              value: 'momo',
              selected: _method == 'momo',
              onTap: _onMethodSelected,
              color: const Color(0xFFAE2070),
              icon: Icons.account_balance_wallet_rounded,
              title: 'Ví MoMo',
              subtitle: 'Quét mã QR để thanh toán',
            ),
            const SizedBox(height: 12),
            _MethodCard(
              value: 'vnpay',
              selected: _method == 'vnpay',
              onTap: _onMethodSelected,
              color: const Color(0xFF005BAA),
              icon: Icons.qr_code_rounded,
              title: 'VNPay',
              subtitle: 'Thẻ ATM nội địa & Internet Banking',
            ),
            const SizedBox(height: 12),
            _MethodCard(
              value: 'visa',
              selected: _method == 'visa',
              onTap: _onMethodSelected,
              color: const Color(0xFF1A1F71),
              icon: Icons.credit_card_rounded,
              title: 'Thẻ Visa / Mastercard',
              subtitle: 'Thẻ quốc tế, thanh toán bảo mật',
            ),

            const SizedBox(height: 32),

            // ── CTA ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tiếp tục thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• \$${fmt.format(b.totalPrice.toInt())}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Giao dịch được mã hóa SSL 256-bit',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String value;
  final bool selected;
  final void Function(String) onTap;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _MethodCard({
    required this.value,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : Colors.grey[300]!,
                  width: 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
              child:
                  selected
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  PROCESSING SCREEN — dùng chung cho cả 3 method
// ══════════════════════════════════════════════

class _ProcessingScreen extends StatefulWidget {
  final BookingEntity booking;
  final String method;
  final Future<bool> Function() onProcess;

  const _ProcessingScreen({
    required this.booking,
    required this.method,
    required this.onProcess,
  });

  @override
  State<_ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<_ProcessingScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0: connecting, 1: verifying, 2: done
  bool? _success;

  late final AnimationController _pulseCtrl;
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkAnim;

  final _steps = ['Đang kết nối...', 'Xác thực thanh toán...', 'Hoàn tất'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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

    // Thực sự gọi API
    final result = await widget.onProcess();
    if (!mounted) return;

    _pulseCtrl.stop();
    setState(() => _success = result);
    _checkCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    if (result) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BookingsPage()),
        (route) => route.isFirst,
      );
    } else {
      Navigator.of(context).pop<bool>(false);
    }
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
                  // ── Animated icon ───────────────
                  SizedBox(
                    width: 120,
                    height: 120,
                    child:
                        _success == null
                            ? AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder:
                                  (_, __) => Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFF1565C0,
                                      ).withOpacity(
                                        0.08 + _pulseCtrl.value * 0.08,
                                      ),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(
                                        12 + _pulseCtrl.value * 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1565C0),
                                      ),
                                      child: const Icon(
                                        Icons.sync_rounded,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                            )
                            : ScaleTransition(
                              scale: _checkAnim,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _success!
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                ),
                                child: Icon(
                                  _success!
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: Colors.white,
                                  size: 56,
                                ),
                              ),
                            ),
                  ),

                  const SizedBox(height: 40),

                  // ── Step labels ─────────────────
                  if (_success == null) ...[
                    Text(
                      _steps[_step],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng không tắt ứng dụng',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    // Step dots
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
                            color:
                                done
                                    ? const Color(0xFF1565C0)
                                    : active
                                    ? const Color(0xFF1565C0)
                                    : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    Text(
                      _success!
                          ? 'Thanh toán thành công!'
                          : 'Thanh toán thất bại',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color:
                            _success!
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _success!
                          ? 'Đơn đặt phòng của bạn đã được xác nhận'
                          : 'Giao dịch không thành công. Vui lòng thử lại.',
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

// ══════════════════════════════════════════════
//  MOMO SCREEN — QR + countdown
// ══════════════════════════════════════════════

class _MomoScreen extends StatefulWidget {
  final BookingEntity booking;
  const _MomoScreen({required this.booking});

  @override
  State<_MomoScreen> createState() => _MomoScreenState();
}

class _MomoScreenState extends State<_MomoScreen> {
  int _countdown = 60;
  int _qrSeed = 0; // thay đổi mỗi lần tạo mã mới để QR render lại
  Timer? _timer;
  bool _processing = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _qrSeed =
        widget.booking.id.hashCode ^ DateTime.now().millisecondsSinceEpoch;
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

  /// Tự động hiện dialog khi QR hết hạn
  Future<void> _onQrExpired() async {
    if (!mounted || _dialogShowing || _processing) return;
    _dialogShowing = true;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFF3E0),
                    ),
                    child: const Icon(
                      Icons.timer_off_rounded,
                      color: Color(0xFFE65100),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mã QR đã hết hạn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã QR chỉ có hiệu lực trong 60 giây.\nBạn muốn tạo mã mới hay đổi phương thức thanh toán?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop('refresh'),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Tạo mã QR mới',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAE2070),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đổi phương thức thanh toán',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    _dialogShowing = false;
    if (!mounted) return;

    if (action == 'refresh') {
      _refreshQr();
    } else if (action == 'change') {
      Navigator.of(context).pop(); // về PaymentPage
    }
  }

  /// Tạo lại mã QR mới + reset countdown
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
        builder:
            (_) => _ProcessingScreen(
              booking: widget.booking,
              method: 'momo',
              onProcess: () => _doPayment('momo'),
            ),
      ),
    );
    // Thất bại → hiện dialog, cho thử lại hoặc đổi method
    if (result == false && mounted) {
      final retry = await _showFailureDialog(context);
      if (!retry && mounted) {
        Navigator.of(context).pop(); // về PaymentPage chọn method khác
      } else if (mounted) {
        // Thử lại → tạo QR mới luôn
        _refreshQr();
        setState(() => _processing = false);
      }
    }
  }

  Future<bool> _doPayment(String method) async {
    // 95% thành công
    final success = Random().nextDouble() < 0.95;
    await BookingApi().payMock(
      bookingId: widget.booking.id,
      method: method,
      success: success,
    );
    return success;
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
        title: const Text(
          'Thanh toán MoMo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header MoMo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAE2070), Color(0xFFD81B60)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Số tiền cần thanh toán',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QR Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Quét mã QR bằng ứng dụng MoMo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 20),

                  // QR — seed thay đổi mỗi lần refresh
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
                            border: Border.all(
                              color: const Color(0xFFAE2070),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomPaint(
                            painter: _FakeQrPainter(seed: _qrSeed),
                          ),
                        ),
                      ),
                      // Overlay khi hết hạn — user biết QR không còn dùng được
                      if (expired)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_off_rounded,
                                color: Color(0xFFE65100),
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Mã đã hết hạn',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Countdown badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          expired
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
                          color:
                              expired
                                  ? Colors.red
                                  : _countdown <= 15
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expired
                              ? 'Mã QR đã hết hạn'
                              : 'Hết hạn sau ${_countdown}s',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                expired
                                    ? Colors.red
                                    : _countdown <= 15
                                    ? Colors.orange
                                    : Colors.green,
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
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFAE2070),
                    size: 18,
                  ),
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

            // Nút thay đổi theo trạng thái
            if (expired)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Đổi method',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _refreshQr,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Tạo mã mới',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAE2070),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xác nhận đã thanh toán',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  VNPAY SCREEN — ATM card + OTP
// ══════════════════════════════════════════════

class _VnpayScreen extends StatefulWidget {
  final BookingEntity booking;
  const _VnpayScreen({required this.booking});

  @override
  State<_VnpayScreen> createState() => _VnpayScreenState();
}

class _VnpayScreenState extends State<_VnpayScreen> {
  final _cardCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showOtp = false;
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhập đủ 6 số OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (entered != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP không đúng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _processing = true);
    _otpTimer?.cancel();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => _ProcessingScreen(
              booking: widget.booking,
              method: 'vnpay',
              onProcess: () async {
                final success = Random().nextDouble() < 0.95;
                await BookingApi().payMock(
                  bookingId: widget.booking.id,
                  method: 'vnpay',
                  success: success,
                );
                return success;
              },
            ),
      ),
    );
    // Thất bại → hiện dialog, cho thử lại hoặc đổi method
    if (result == false && mounted) {
      final retry = await _showFailureDialog(context);
      if (!retry && mounted) {
        Navigator.of(context).pop(); // về PaymentPage chọn method khác
      } else if (mounted) {
        // Reset để nhập lại OTP
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
        title: const Text(
          'VNPay',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // VNPay brand bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003087), Color(0xFF005BAA)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'VNPay Secure Gateway',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!_showOtp) ...[
              // ── ATM form ───────────────────────
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin thẻ ATM',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _VnpayField(
                        controller: _cardCtrl,
                        label: 'Số thẻ ATM',
                        hint: '9704 XXXX XXXX XXXX',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
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
                        validator:
                            (v) =>
                                (v?.trim().isEmpty ?? true)
                                    ? 'Nhập tên chủ thẻ'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      _VnpayField(
                        controller: _bankCtrl,
                        label: 'Tên ngân hàng',
                        hint: 'Vietcombank / Techcombank...',
                        icon: Icons.account_balance_rounded,
                        validator:
                            (v) =>
                                (v?.trim().isEmpty ?? true)
                                    ? 'Nhập tên ngân hàng'
                                    : null,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Nhận mã OTP',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── OTP screen ─────────────────────
              Container(
                padding: const EdgeInsets.all(24),
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sms_rounded,
                        color: Color(0xFF005BAA),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nhập mã OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mã OTP đã gửi đến SĐT đăng ký thẻ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        return Container(
                          width: 44,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF005BAA),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _otpCtrls[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (v) {
                                if (v.isNotEmpty && i < 5) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      _otpCountdown > 0
                          ? 'Hết hạn sau ${_otpCountdown}s'
                          : 'OTP đã hết hạn',
                      style: TextStyle(
                        color: _otpCountdown > 30 ? Colors.grey : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (_processing || _otpCountdown <= 0)
                                ? null
                                : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005BAA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xác nhận OTP',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
          borderSide: const BorderSide(color: Color(0xFF005BAA), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  VISA SCREEN — card form + flip animation
// ══════════════════════════════════════════════

class _VisaScreen extends StatefulWidget {
  final BookingEntity booking;
  const _VisaScreen({required this.booking});

  @override
  State<_VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<_VisaScreen>
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
            (_) => _ProcessingScreen(
              booking: widget.booking,
              method: 'visa',
              onProcess: () async {
                final success = Random().nextDouble() < 0.95;
                await BookingApi().payMock(
                  bookingId: widget.booking.id,
                  method: 'visa',
                  success: success,
                );
                return success;
              },
            ),
      ),
    );
    // Thất bại → hiện dialog, cho thử lại hoặc đổi method
    if (result == false && mounted) {
      final retry = await _showFailureDialog(context);
      if (!retry && mounted) {
        Navigator.of(context).pop(); // về PaymentPage chọn method khác
      } else if (mounted) {
        setState(() => _processing = false); // reset để thử lại
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
              // ── Flip card preview ───────────────
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

              // ── Form fields ─────────────────────
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
                    // Card number
                    TextFormField(
                      controller: _cardCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
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

                    // Cardholder name
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

                    // Expiry + CVV row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryFormatter(),
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

// ══════════════════════════════════════════════
//  FAKE QR PAINTER
// ══════════════════════════════════════════════

class _FakeQrPainter extends CustomPainter {
  final int seed;
  const _FakeQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final rng = Random(seed);
    final cell = size.width / 21;

    // Corner squares
    _drawCornerSquare(canvas, paint, 0, 0, cell);
    _drawCornerSquare(canvas, paint, 14 * cell, 0, cell);
    _drawCornerSquare(canvas, paint, 0, 14 * cell, cell);

    // Random data cells
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if (_isCornerZone(r, c)) continue;
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2),
            paint,
          );
        }
      }
    }
  }

  void _drawCornerSquare(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double cell,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), paint);
    canvas.drawRect(
      Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
      paint,
    );
  }

  bool _isCornerZone(int r, int c) {
    return (r < 8 && c < 8) || (r < 8 && c > 12) || (r > 12 && c < 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
//  INPUT FORMATTERS
// ══════════════════════════════════════════════

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length <= 2) return newValue.copyWith(text: text);
    final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
