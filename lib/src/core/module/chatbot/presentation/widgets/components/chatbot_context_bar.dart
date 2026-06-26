import 'package:flutter/material.dart';
import '../../cubit/chatbot_state.dart';
import '../../cubit/chatbot_cubit.dart';
import '../ctx_chip.dart';

class ChatbotContextBar extends StatelessWidget {
  final ChatbotState state;
  final ChatbotCubit cubit;
  final Function(int) onGuestPickerTap;

  const ChatbotContextBar({
    super.key,
    required this.state,
    required this.cubit,
    required this.onGuestPickerTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasHotel = state.botContext['hotel_id'] != null;
    final hasDate = state.botContext['check_in'] != null;
    if (!hasHotel && !hasDate && state.guests == 1)
      return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (hasHotel) ...[
              const CtxChip(
                icon: Icons.hotel_outlined,
                label: 'Đã chọn khách sạn',
                color: Colors.green,
              ),
              const SizedBox(width: 6),
            ],
            if (hasDate) ...[
              CtxChip(
                icon: Icons.date_range_outlined,
                label:
                    '${state.botContext['check_in']} → ${state.botContext['check_out']}',
                color: Colors.orange,
              ),
              const SizedBox(width: 6),
            ],
            CtxChip(
              icon: Icons.person_outline,
              label: '${state.guests} khách',
              color: const Color(0xFF0A84FF),
              onTap: () => onGuestPickerTap(state.guests),
            ),
            const SizedBox(width: 6),
            CtxChip(
              icon: Icons.list_alt_outlined,
              label: 'Booking của tôi',
              color: Colors.purple,
              onTap: () => cubit.send('list_bookings'),
            ),
          ],
        ),
      ),
    );
  }
}
