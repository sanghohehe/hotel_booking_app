import 'package:flutter/material.dart';
import '../../cubit/chatbot_state.dart';
import '../../cubit/chatbot_cubit.dart';

class ChatbotQuickReplies extends StatelessWidget {
  final ChatbotState state;
  final ChatbotCubit cubit;
  final VoidCallback onPickDate;

  const ChatbotQuickReplies({
    super.key,
    required this.state,
    required this.cubit,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final sugg = <String>[];
    if (state.botContext['hotel_id'] != null &&
        state.botContext['check_in'] == null)
      sugg.add('📅 Chọn ngày');
    if (state.botContext['hotel_id'] != null &&
        state.botContext['check_in'] != null)
      sugg.add('🛏 Xem phòng trống');
    if (state.messages.any((m) => m.role == 'assistant'))
      sugg.add('📋 Booking của tôi');
    if (sugg.isEmpty) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFFF2F6FC),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              sugg
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          s,
                          style: const TextStyle(
                            color: Color(0xFF1A56DB),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE8F0FE),
                        side: BorderSide.none,
                        onPressed: () {
                          if (s.contains('Chọn ngày'))
                            onPickDate();
                          else if (s.contains('Xem phòng'))
                            cubit.send('còn phòng không');
                          else
                            cubit.send('list_bookings');
                        },
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
