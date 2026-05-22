// pubspec.yaml dependencies cần thêm:
//   flutter_markdown: ^0.7.4
//   http: ^1.2.0  (nếu chưa có)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _dotAnimController;
  bool _showScrollFab = false;

  // ─── Theme ────────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF0A84FF);
  static const _bgPage = Color(0xFFF2F6FC);
  static const _bubbleUser = Color(0xFF0A84FF);
  static const _bubbleBot = Colors.white;
  static const _textUser = Colors.white;
  static const _textBot = Color(0xFF1C1C1E);
  static const _chipBg = Color(0xFFE8F0FE);
  static const _chipText = Color(0xFF1A56DB);

  @override
  void initState() {
    super.initState();
    context.read<ChatbotCubit>().startNewChat();
    _dotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final atBottom =
          _scrollController.position.maxScrollExtent -
              _scrollController.offset <
          150;
      if (!atBottom && !_showScrollFab) setState(() => _showScrollFab = true);
      if (atBottom && _showScrollFab) setState(() => _showScrollFab = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _dotAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend(ChatbotCubit cubit) {
    if (Supabase.instance.client.auth.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục.')),
      );
      return;
    }
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    cubit.send(text);
    _controller.clear();
    setState(() {}); // refresh send button color
  }

  Future<void> _pickDateRange(ChatbotCubit cubit, ChatbotState state) async {
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
            data: Theme.of(
              ctx,
            ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
            child: child!,
          ),
    );
    if (picked != null) cubit.onDateRangeSelected(picked);
  }

  Future<void> _showGuestPicker(ChatbotCubit cubit, int current) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int temp = current;
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
                        _CounterBtn(
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
                              color: _primary,
                            ),
                          ),
                        ),
                        _CounterBtn(
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
                          backgroundColor: _primary,
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
    if (result != null) cubit.updateGuests(result);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatbotCubit>();

    return Scaffold(
      backgroundColor: _bgPage,

      // 👇 BUTTON XEM LỊCH SỬ CHAT
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A84FF), Color(0xFF34AADC)],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.history, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'Lịch sử Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder(
                  future: Supabase.instance.client
                      .from('conversations')
                      .select()
                      .order('created_at', ascending: false),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final sessions = snapshot.data as List<dynamic>;

                    if (sessions.isEmpty) {
                      return const Center(child: Text('Chưa có lịch sử chat'));
                    }

                    return ListView.separated(
                      itemCount: sessions.length,
                      separatorBuilder:
                          (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final s = sessions[index];

                        return ListTile(
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: _primary,
                            ),
                          ),

                          title: Text(
                            s['title'] ?? 'Cuộc trò chuyện ${index + 1}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          subtitle: Text(
                            s['created_at'].toString().substring(0, 16),
                          ),

                          trailing: const Icon(Icons.chevron_right),

                          onTap: () async {
                            Navigator.pop(context);

                            await cubit.loadConversation(s['id']);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      appBar: _buildAppBar(cubit),

      floatingActionButton:
          _showScrollFab
              ? FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: _primary,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              )
              : null,

      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (ctx, state) {
          if (state.isSending || state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },

        builder: (ctx, state) {
          return Column(
            children: [
              _buildContextBar(state, cubit),

              if (state.botContext['hotel_id'] == null) _buildCityChips(cubit),

              Expanded(child: _buildMessageList(state, cubit)),

              if (state.isSending && !state.isStreaming) _buildTypingDots(),

              _buildQuickReplies(state, cubit),

              _buildInputArea(state, cubit),
            ],
          );
        },
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Travel AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textBot,
                ),
              ),
              Text(
                'Trợ lý đặt phòng',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: _primary),
          tooltip: 'Cuộc hội thoại mới',
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<ChatbotCubit>().reset();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  // ─── Context bar ──────────────────────────────────────────────────────────
  Widget _buildContextBar(ChatbotState state, ChatbotCubit cubit) {
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
              _CtxChip(
                icon: Icons.hotel_outlined,
                label: 'Đã chọn khách sạn',
                color: Colors.green,
              ),
              const SizedBox(width: 6),
            ],
            if (hasDate) ...[
              _CtxChip(
                icon: Icons.date_range_outlined,
                label:
                    '${state.botContext['check_in']} → ${state.botContext['check_out']}',
                color: Colors.orange,
              ),
              const SizedBox(width: 6),
            ],
            _CtxChip(
              icon: Icons.person_outline,
              label: '${state.guests} khách',
              color: _primary,
              onTap: () => _showGuestPicker(cubit, state.guests),
            ),
            const SizedBox(width: 6),
            _CtxChip(
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

  // ─── City chips ───────────────────────────────────────────────────────────
  Widget _buildCityChips(ChatbotCubit cubit) {
    final cities = ['Hà Nội', 'Đà Nẵng', 'TP.HCM', 'Hội An', 'Phú Quốc'];
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
                              color: _chipText,
                            ),
                            label: Text(
                              city,
                              style: const TextStyle(
                                color: _chipText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: _chipBg,
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

  // ─── Message list ─────────────────────────────────────────────────────────
  Widget _buildMessageList(ChatbotState state, ChatbotCubit cubit) {
    // Tổng số item = tin nhắn đã hoàn thành + 1 bubble streaming (nếu có)
    final streamingActive = state.isStreaming;
    final itemCount = state.messages.length + (streamingActive ? 1 : 0);

    if (itemCount == 0) return _buildWelcome(cubit);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        // Bubble streaming (luôn ở cuối)
        if (streamingActive && i == state.messages.length) {
          return _buildStreamingBubble(state.streamingText);
        }
        final msg = state.messages[i];
        final showAvatar =
            msg.role == 'assistant' &&
            (i == 0 || state.messages[i - 1].role != 'assistant');
        return _buildBubble(msg, state, cubit, showAvatar: showAvatar);
      },
    );
  }

  // ─── Welcome screen ───────────────────────────────────────────────────────
  Widget _buildWelcome(ChatbotCubit cubit) {
    final suggestions = [
      ('🏨', 'Tìm KS Đà Nẵng', 'tìm khách sạn ở Đà Nẵng'),
      ('📋', 'Booking của tôi', 'list_bookings'),
      ('🌟', 'KS 5 sao Hà Nội', 'tìm khách sạn ở Hà Nội'),
      ('🏝️', 'KS Phú Quốc', 'tìm khách sạn ở Phú Quốc'),
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF34AADC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.travel_explore,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xin chào! 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tôi có thể giúp bạn tìm khách sạn,\nkiểm tra phòng trống và đặt phòng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children:
                  suggestions
                      .map(
                        (s) => InkWell(
                          onTap: () => cubit.send(s.$3),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  s.$1,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.$2,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _textBot,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bubble hoàn chỉnh ────────────────────────────────────────────────────
  Widget _buildBubble(
    ChatMessageEntity m,
    ChatbotState state,
    ChatbotCubit cubit, {
    bool showAvatar = false,
  }) {
    final isUser = m.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child:
                  showAvatar
                      ? Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A84FF), Color(0xFF34AADC)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                      : const SizedBox(width: 30),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              margin: EdgeInsets.only(
                top: 2,
                bottom: 2,
                left: isUser ? 48 : 0,
                right: isUser ? 0 : 48,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _bubbleUser : _bubbleBot,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isUser
                            ? _primary.withOpacity(0.25)
                            : Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (m.content.isNotEmpty)
                    isUser
                        // User: plain text
                        ? Text(
                          m.content,
                          style: const TextStyle(
                            color: _textUser,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        )
                        // Bot: Markdown rendering ✨
                        : _BotMarkdown(text: m.content),

                  if (m.hotels != null && m.hotels!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...m.hotels!.map((h) => _buildHotelCard(h, cubit, state)),
                  ],
                  if (m.availability != null && m.availability!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...m.availability!.map(
                      (r) => _buildRoomCard(r, state, cubit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Streaming bubble (text đang đến dần) ────────────────────────────────
  Widget _buildStreamingBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 2),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF34AADC)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.travel_explore,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              margin: const EdgeInsets.only(top: 2, bottom: 2, right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _bubbleBot,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BotMarkdown(text: text),
                  // Con trỏ nhấp nháy
                  const SizedBox(height: 4),
                  _BlinkingCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Typing dots (trước khi có bất kỳ chunk nào) ─────────────────────────
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
                        color: _primary,
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

  // ─── Quick replies ────────────────────────────────────────────────────────
  Widget _buildQuickReplies(ChatbotState state, ChatbotCubit cubit) {
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
      color: _bgPage,
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
                            color: _chipText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: _chipBg,
                        side: BorderSide.none,
                        onPressed: () {
                          if (s.contains('Chọn ngày'))
                            _pickDateRange(cubit, state);
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

  // ─── Input area ───────────────────────────────────────────────────────────
  Widget _buildInputArea(ChatbotState state, ChatbotCubit cubit) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _bgPage,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(cubit),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 15, color: _textBot),
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: state.isSending ? null : () => _handleSend(cubit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      (_controller.text.trim().isNotEmpty && !state.isSending)
                          ? _primary
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color:
                      (_controller.text.trim().isNotEmpty && !state.isSending)
                          ? Colors.white
                          : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hotel card ───────────────────────────────────────────────────────────
  Widget _buildHotelCard(dynamic h, ChatbotCubit cubit, ChatbotState state) {
    final stars = (h['star_rating'] as num?)?.toInt() ?? 0;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          cubit.updateBotContext({'hotel_id': h['id']});
          _pickDateRange(cubit, state);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.hotel, color: Colors.blue.shade300, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          h['city'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (stars > 0) ...[
                          const SizedBox(width: 6),
                          Row(
                            children: List.generate(
                              stars.clamp(0, 5),
                              (_) => const Icon(
                                Icons.star,
                                size: 11,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Room card ────────────────────────────────────────────────────────────
  Widget _buildRoomCard(dynamic r, ChatbotState state, ChatbotCubit cubit) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['name'] ?? 'Phòng',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.formatVnd(r['price_per_night']),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (r['available_rooms'] != null)
                    Text(
                      'Còn ${r['available_rooms']} phòng',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            FilledButton(
              onPressed: state.isSending ? null : () => cubit.bookRoom(r),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Đặt ngay',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _BotMarkdown: render Markdown trong bubble bot ───────────────────────────
class _BotMarkdown extends StatelessWidget {
  final String text;
  const _BotMarkdown({required this.text});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 15,
          height: 1.45,
        ),
        strong: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        em: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontStyle: FontStyle.italic,
          fontSize: 15,
        ),
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          color: const Color(0xFF0A84FF),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        listBullet: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15),
        blockquoteDecoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(color: Colors.blue.shade200, width: 3),
          ),
        ),
        h1: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
      onTapLink: (text, href, title) {
        // Handle link tap nếu cần
      },
    );
  }
}

// ─── _BlinkingCursor ──────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder:
          (_, __) => Opacity(
            opacity: _ctrl.value,
            child: Container(
              width: 2,
              height: 16,
              color: const Color(0xFF0A84FF),
            ),
          ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────
class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE8F0FE) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF0A84FF) : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _CtxChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _CtxChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
