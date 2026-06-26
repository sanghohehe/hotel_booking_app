import 'package:booking_app/src/core/module/bookings/presentation/widgets/payment/screens/momo_payment_screen.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/payment/screens/visa_payment_screen.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/payment/screens/vnpay_payment_screen.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/payment/widgets/order_summary_card.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/payment/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:booking_app/src/core/module/vouchers/data/voucher_model.dart';
import 'package:booking_app/src/core/module/vouchers/presentation/widgets/voucher_input_widget.dart';

import '../../domain/entities/bookingEntity .dart';

class PaymentPage extends StatefulWidget {
  final BookingEntity booking;
  const PaymentPage({super.key, required this.booking});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _method = 'momo';
  VoucherModel? _appliedVoucher;
  double? _finalPrice;

  void _onMethodSelected(String method) {
    setState(() => _method = method);
  }

  Future<void> _proceed() async {
    final priceToCharge = _finalPrice ?? widget.booking.totalPrice;
    final bookingWithDiscount = widget.booking.copyWith(
      totalPrice: priceToCharge,
    );

    Widget screen;
    switch (_method) {
      case 'momo':
        screen = MomoPaymentScreen(booking: bookingWithDiscount);
        break;
      case 'vnpay':
        screen = VnpayPaymentScreen(booking: bookingWithDiscount);
        break;
      default:
        screen = VisaPaymentScreen(booking: bookingWithDiscount);
    }

    final success = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen));

    if (success == true && mounted) {
      Navigator.of(context).pop(true); // Thành công quay về màn hình trước đó
    }
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
            // Thẻ tóm tắt thông tin hóa đơn
            OrderSummaryCard(booking: b),
            const SizedBox(height: 28),

            // Nhập mã giảm giá
            VoucherInputWidget(
              originalPrice: widget.booking.totalPrice,
              onVoucherChanged: (voucher, finalPrice) {
                setState(() {
                  _appliedVoucher = voucher;
                  _finalPrice = finalPrice;
                });
              },
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

            // Danh sách các phương thức lựa chọn
            PaymentMethodCard(
              value: 'momo',
              selected: _method == 'momo',
              onTap: _onMethodSelected,
              color: const Color(0xFFAE2070),
              icon: Icons.account_balance_wallet_rounded,
              title: 'Ví MoMo',
              subtitle: 'Quét mã QR để thanh toán',
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              value: 'vnpay',
              selected: _method == 'vnpay',
              onTap: _onMethodSelected,
              color: const Color(0xFF005BAA),
              icon: Icons.qr_code_rounded,
              title: 'VNPay',
              subtitle: 'Thẻ ATM nội địa & Internet Banking',
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              value: 'visa',
              selected: _method == 'visa',
              onTap: _onMethodSelected,
              color: const Color(0xFF1A1F71),
              icon: Icons.credit_card_rounded,
              title: 'Thẻ Visa / Mastercard',
              subtitle: 'Thẻ quốc tế, thanh toán bảo mật',
            ),
            const SizedBox(height: 32),

            // Button CTA Tiếp tục
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
                      '• \$${fmt.format((_finalPrice ?? b.totalPrice).toInt())}',
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
