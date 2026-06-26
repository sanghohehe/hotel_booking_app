import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import '../controllers/chatbot_controller.dart';

// Import Custom components & Sub-widgets
import '../widgets/welcome_screen.dart';
import '../widgets/message_bubble.dart';
import '../widgets/streaming_bubble.dart';
import '../widgets/components/chatbot_history_drawer.dart';
import '../widgets/components/chatbot_context_bar.dart';
import '../widgets/components/chatbot_quick_replies.dart';
import '../widgets/components/chatbot_input_area.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  late ChatbotController _controller;
  late AnimationController _dotAnimController;

  @override
  void initState() {
    super.initState();
    context.read<ChatbotCubit>().startNewChat();
    _controller = ChatbotController(context: context, setState: setState);
    _dotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatbotCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      drawer: ChatbotHistoryDrawer(cubit: cubit),
      appBar: _buildAppBar(cubit),
      floatingActionButton:
          _controller.showScrollFab
              ? FloatingActionButton.small(
                onPressed: _controller.scrollToBottom,
                backgroundColor: const Color(0xFF0A84FF),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              )
              : null,
      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (ctx, state) {
          if (state.isSending || state.messages.isNotEmpty)
            _controller.scrollToBottom();
        },
        builder: (ctx, state) {
          return Column(
            children: [
              ChatbotContextBar(
                state: state,
                cubit: cubit,
                onGuestPickerTap: _controller.showGuestPicker,
              ),
              if (state.botContext['hotel_id'] == null) _buildCityChips(cubit),
              Expanded(child: _buildMessageList(state, cubit)),
              if (state.isSending && !state.isStreaming) _buildTypingDots(),
              ChatbotQuickReplies(
                state: state,
                cubit: cubit,
                onPickDate: () => _controller.pickDateRange(state),
              ),
              ChatbotInputArea(
                state: state,
                controller: _controller.textController,
                onSend: _controller.handleSend,
                onChanged: () => setState(() {}),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatbotCubit cubit) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A84FF), Color(0xFF34AADC)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.travel_explore,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Travel AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              Text(
                'Trợ lý đặt phòng',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0A84FF)),
          onPressed: () {
            HapticFeedback.mediumImpact();
            cubit.reset();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildCityChips(ChatbotCubit cubit) {
    final cities = ['Hà Nội', 'Đà Nẵng', 'Quy Nhơn', 'Hải Phòng', 'Hà Giang'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Tìm nhanh theo thành phố',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  cities
                      .map(
                        (city) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF1A56DB),
                            ),
                            label: Text(
                              city,
                              style: const TextStyle(
                                color: Color(0xFF1A56DB),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: const Color(0xFFE8F0FE),
                            side: BorderSide.none,
                            onPressed:
                                () => cubit.send('tìm khách sạn ở $city'),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatbotState state, ChatbotCubit cubit) {
    final streamingActive = state.isStreaming;
    final itemCount = state.messages.length + (streamingActive ? 1 : 0);

    if (itemCount == 0)
      return WelcomeScreen(onSelectSuggestion: (text) => cubit.send(text));

    return ListView.builder(
      controller: _controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        if (streamingActive && i == state.messages.length) {
          return StreamingBubble(text: state.streamingText);
        }
        final msg = state.messages[i];
        final showAvatar =
            msg.role == 'assistant' &&
            (i == 0 || state.messages[i - 1].role != 'assistant');
        return MessageBubble(
          message: msg,
          state: state,
          showAvatar: showAvatar,
          onHotelTap: (hotelId) {
            cubit.updateBotContext({'hotel_id': hotelId});
            _controller.pickDateRange(state);
          },
          onRoomBook: (room) => _controller.openRoomPayment(room, state),
          onPaymentTap: (booking) => _controller.openPayment(booking),
        );
      },
    );
  }

  Widget _buildTypingDots() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 50, bottom: 8, top: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _dotAnimController,
            builder: (_, __) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = (_dotAnimController.value + i / 3) % 1.0;
                  final scale =
                      0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A84FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
