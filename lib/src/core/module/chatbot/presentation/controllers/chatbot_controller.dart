import 'package:booking_app/src/core/module/chatbot/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:booking_app/src/core/module/bookings/presentation/pages/payment_page.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import '../widgets/counter_btn.dart';

class ChatbotController {
  final BuildContext context;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final Function(VoidCallback) setState;

  bool showScrollFab = false;

  ChatbotController({required this.context, required this.setState}) {
    scrollController.addListener(_scrollListener);
  }

  void dispose() {
    textController.dispose();
    scrollController.dispose();
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final atBottom =
        scrollController.position.maxScrollExtent - scrollController.offset <
        150;
    if (!atBottom && !showScrollFab) setState(() => showScrollFab = true);
    if (atBottom && showScrollFab) setState(() => showScrollFab = false);
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void handleSend() {
    if (Supabase.instance.client.auth.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục.')),
      );
      return;
    }
    final text = textController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<ChatbotCubit>().send(text);
    textController.clear();
    setState(() {});
  }

  Future<void> pickDateRange(ChatbotState state) async {
    if (state.botContext['hotel_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách sạn trước.')),
      );
      return;
    }
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF0A84FF)),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      context.read<ChatbotCubit>().onDateRangeSelected(picked);
    }
  }

  Future<void> showGuestPicker(int currentGuests) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int temp = currentGuests;
        return StatefulBuilder(
          builder: (context, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Text(
                      'Số khách',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CounterBtn(
                          icon: Icons.remove,
                          enabled: temp > 1,
                          onTap: () => setModal(() => temp--),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '$temp',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A84FF),
                            ),
                          ),
                        ),
                        CounterBtn(
                          icon: Icons.add,
                          enabled: temp < 20,
                          onTap: () => setModal(() => temp++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, temp),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      context.read<ChatbotCubit>().updateGuests(result);
    }
  }

  Future<void> openPayment(dynamic b) async {
    final checkIn = DateTime.parse(b['check_in'] as String);
    final checkOut = DateTime.parse(b['check_out'] as String);

    final booking = BookingEntity(
      id: b['id'] as String,
      checkIn: checkIn,
      checkOut: checkOut,
      totalPrice: (b['total_price'] as num).toDouble(),
      status: b['status'] as String? ?? '',
      paymentStatus: b['payment_status'] as String? ?? '',
      guestsAdults: (b['guests_adults'] as num?)?.toInt() ?? 1,
      guestsChildren: 0,
      hotelId: null,
      hotelName: b['hotels']?['name'] as String?,
      hotelCity: b['hotels']?['city'] as String?,
      roomTypeName: b['room_types']?['name'] as String?,
      nights: checkOut.difference(checkIn).inDays,
    );

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentPage(booking: booking)));
    context.read<ChatbotCubit>().send('list_bookings', addUserBubble: false);
  }

  Future<void> openRoomPayment(dynamic r, ChatbotState state) async {
    final checkIn = state.botContext['check_in'] as String?;
    final checkOut = state.botContext['check_out'] as String?;

    if (checkIn == null || checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày trước.')),
      );
      return;
    }

    final ciDate = DateTime.parse(checkIn);
    final coDate = DateTime.parse(checkOut);
    final nights = coDate.difference(ciDate).inDays;
    final pricePerNight = (r['price_per_night'] as num).toDouble();

    final tempBooking = BookingEntity(
      id: r['id'] ?? r['room_type_id'] ?? '',
      checkIn: ciDate,
      checkOut: coDate,
      totalPrice: pricePerNight * nights,
      status: 'pending',
      paymentStatus: 'unpaid',
      guestsAdults: state.guests,
      guestsChildren: 0,
      hotelName: state.botContext['hotel_name'] as String?,
      roomTypeName: r['name'] as String?,
      nights: nights,
    );

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PaymentPage(booking: tempBooking)),
    );

    if (paid == true) {
      final cubit = context.read<ChatbotCubit>();
      cubit.bookRoom(r);
      await Future.delayed(const Duration(milliseconds: 1800));

      final lastBotMessage = cubit.state.messages.lastWhere(
        (m) => m.role == 'assistant' && m.booking != null,
        orElse: () =>  ChatMessageEntity(role: 'assistant', content: ''),
      );

      final realBookingId = lastBotMessage.booking?['id'] as String?;
      if (realBookingId != null) {
        await cubit.confirmPayment(
          bookingId: realBookingId,
          paymentMethod: 'momo',
          finalAmount: tempBooking.totalPrice,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đặt phòng thành công, nhưng vui lòng kiểm tra lại trang Bookings',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
