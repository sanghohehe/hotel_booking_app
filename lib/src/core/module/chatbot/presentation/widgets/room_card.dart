import 'package:booking_app/src/core/module/chatbot/presentation/cubit/chatbot_state.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final dynamic room;
  final ChatbotState state;
  final VoidCallback onBook;

  const RoomCard({
    super.key,
    required this.room,
    required this.state,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room['name'] ?? 'Phòng', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(state.formatVnd(room['price_per_night']), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 15)),
                  if (room['available_rooms'] != null)
                    Text('Còn ${room['available_rooms']} phòng', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            FilledButton(
              onPressed: state.isSending ? null : onBook,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Đặt ngay', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}