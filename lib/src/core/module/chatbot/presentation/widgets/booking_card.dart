import 'package:booking_app/src/core/module/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onPayment;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final hotel = booking['hotels'];
    final room = booking['room_types'];
    final status = booking['status'] as String? ?? '';
    final payment = booking['payment_status'] as String? ?? '';

    final statusColor = switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      'done' => Colors.blue,
      _ => Colors.grey,
    };

    final statusLabel = switch (status) {
      'confirmed' => '✅ Đã xác nhận',
      'pending' => '⏳ Chờ xác nhận',
      'cancelled' => '❌ Đã hủy',
      'done' => '🏁 Hoàn thành',
      _ => status,
    };

    final checkIn = DateTime.tryParse(booking['check_in'] as String? ?? '');
    final checkOut = DateTime.tryParse(booking['check_out'] as String? ?? '');
    final nights = (checkIn != null && checkOut != null) ? checkOut.difference(checkIn).inDays : 0;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(hotel?['name'] ?? 'Khách sạn', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (hotel?['city'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(hotel!['city'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
            if (room?['name'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.meeting_room, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(room!['name'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Check-in', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(booking['check_in'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Check-out', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(booking['check_out'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.read<ChatbotCubit>().state.formatVnd(booking['total_price']),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                          ),
                          Text('$nights đêm', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(payment == 'paid' ? Icons.check_circle_outline : Icons.pending_outlined, size: 14, color: payment == 'paid' ? Colors.green : Colors.orange),
                const SizedBox(width: 4),
                Text(
                  payment == 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán',
                  style: TextStyle(color: payment == 'paid' ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (status == 'confirmed' && payment != 'paid') ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPayment,
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text('Thanh toán ngay', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}