import 'package:booking_app/src/core/module/chatbot/presentation/cubit/chatbot_state.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'bot_markdown.dart';
import 'hotel_card.dart';
import 'room_card.dart';
import 'booking_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final ChatbotState state;
  final bool showAvatar;
  final ValueChanged<String> onHotelTap;
  final ValueChanged<dynamic> onRoomBook;
  final ValueChanged<dynamic> onPaymentTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.state,
    required this.showAvatar,
    required this.onHotelTap,
    required this.onRoomBook,
    required this.onPaymentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: showAvatar
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0A84FF), Color(0xFF34AADC)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.travel_explore, color: Colors.white, size: 16),
                    )
                  : const SizedBox(width: 30),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              margin: EdgeInsets.only(top: 2, bottom: 2, left: isUser ? 48 : 0, right: isUser ? 0 : 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0A84FF) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? const Color(0xFF0A84FF).withOpacity(0.25) : Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.isNotEmpty)
                    isUser
                        ? Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45))
                        : BotMarkdown(text: message.content),
                  if (message.hotels != null && message.hotels!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...message.hotels!.map((h) => HotelCard(hotel: h, onTap: () => onHotelTap(h['id']))),
                  ],
                  if (message.availability != null && message.availability!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...message.availability!.map((r) => RoomCard(room: r, state: state, onBook: () => onRoomBook(r))),
                  ],
                  if (message.bookings != null && message.bookings!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...message.bookings!.map((b) => BookingCard(booking: b, onPayment: () => onPaymentTap(b))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}