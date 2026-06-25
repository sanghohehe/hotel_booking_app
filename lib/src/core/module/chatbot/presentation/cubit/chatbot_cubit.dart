import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_message_entity.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final dynamic chatbotUseCase;

  final String _edgeFunctionUrl =
      'https://vangrwbliciqgrkwgmou.supabase.co/functions/v1/chatbot';

  ChatbotCubit(this.chatbotUseCase) : super(ChatbotState.initial());

  // ───────────────── RESET ─────────────────

  void reset() {
    emit(ChatbotState.initial());
  }

  void startNewChat() {
    emit(
      state.copyWith(
        messages: [],
        botContext: {},
        streamingText: '',
        clearConversationId: true,
      ),
    );
  }

  // ───────────────── HELPERS ─────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ───────────────── CONTEXT ─────────────────

  void updateGuests(int count) {
    emit(state.copyWith(guests: count));
    updateBotContext({'guests': count});
  }

  void updateBotContext(Map<String, dynamic> updates) {
    final newCtx = Map<String, dynamic>.from(state.botContext)..addAll(updates);

    emit(state.copyWith(botContext: newCtx));
  }

  void onDateRangeSelected(DateTimeRange range) {
    final ci = _fmtDate(range.start);
    final co = _fmtDate(range.end);

    send(
      'còn phòng ($ci → $co)',
      contextOverride: {'check_in': ci, 'check_out': co},
    );
  }

  // ───────────────── FLOW ĐẶT PHÒNG ─────────────────

  void selectHotel(dynamic hotel) {
    updateBotContext({'hotel_id': hotel['id'], 'hotel_name': hotel['name']});

    send(
      'Tôi đã chọn khách sạn ${hotel['name']}, cho mình xem phòng trống nhé',
      addUserBubble: false,
    );
  }

  void bookRoom(dynamic room) {
    final roomId = room['id'] ?? room['room_type_id'];

    send(
      'đặt phòng',
      contextOverride: {
        'room_type_id': roomId,
        'hotel_id': state.botContext['hotel_id'],
      },
    );
  }

  // ───────────────── SEND MESSAGE ─────────────────

  Future<void> send(
    String text, {
    bool addUserBubble = true,
    Map<String, dynamic>? contextOverride,
  }) async {
    if (text.trim().isEmpty || state.isSending) {
      return;
    }

    final activeContext = Map<String, dynamic>.from(state.botContext);

    if (contextOverride != null) {
      activeContext.addAll(contextOverride);

      emit(state.copyWith(botContext: activeContext));
    }

    var currentMessages = List<ChatMessageEntity>.from(state.messages);

    if (addUserBubble) {
      currentMessages.add(ChatMessageEntity(role: 'user', content: text));

      emit(state.copyWith(messages: currentMessages, isSending: true));
    } else {
      emit(state.copyWith(isSending: true));
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      _appendError('Phiên đăng nhập không hợp lệ.');
      return;
    }

    final history =
        state.messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList();

    try {
      await _sendRequest(
        text: text,
        history: history,
        context: activeContext,
        token: session.accessToken,
      );
    } catch (e) {
      _appendError('Lỗi kết nối: $e');
    }
  }

  // ───────────────── LOAD CONVERSATION ─────────────────

  Future<void> loadConversation(String conversationId) async {
    try {
      emit(state.copyWith(isSending: true));

      final res = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages =
          (res as List).map((e) {
            final metadata = e['metadata'];

            return ChatMessageEntity(
              role: e['role'] ?? 'assistant',
              content: e['message'] ?? '',
              type: metadata?['type'],
              hotels: metadata?['hotels'],
              availability: metadata?['availability'],
              bookings: metadata?['bookings'],
              booking: metadata?['booking'],
            );
          }).toList();

      emit(
        state.copyWith(
          messages: messages,
          conversationId: conversationId,
          isSending: false,
          streamingText: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSending: false));
    }
  }

  // ───────────────── REQUEST ─────────────────

  Future<void> _sendRequest({
    required String text,
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> context,
    required String token,
  }) async {
    final uri = Uri.parse(_edgeFunctionUrl);

    final body = jsonEncode({
      'message': text,
      'history': history,
      'conversation_id': state.conversationId,
      'context': context,

      // IMPORTANT
      'stream': false,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      _appendError('Server lỗi ${response.statusCode}');
      return;
    }

    _handleJsonResponse(response.body);
  }

  // ───────────────── CONFIRM PAYMENT ─────────────────

  /// Gọi sau khi thanh toán thành công từ PaymentPage
  Future<void> confirmPayment({
    required String bookingId,
    String paymentMethod = 'momo',
    double? finalAmount,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      final response =
          await Supabase.instance.client
              .from('bookings')
              .update({
                'payment_status': 'paid',
                'paid_at': DateTime.now().toIso8601String(),
                'payment_method': paymentMethod,
                if (finalAmount != null) 'total_price': finalAmount,
              })
              .eq('id', bookingId)
              .select();

      if (response.isNotEmpty) {
        _appendSuccessMessage(
          'Thanh toán thành công! Booking đã được xác nhận.',
        );
      } else {
        _appendError('Không tìm thấy booking để cập nhật thanh toán.');
      }
    } catch (e) {
      print('❌ Lỗi confirm payment: $e');
      _appendError(
        'Cập nhật thanh toán thất bại. Vui lòng kiểm tra trong Bookings.',
      );
    }
  }

  void _appendSuccessMessage(String msg) {
    final finalMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(ChatMessageEntity(role: 'assistant', content: '✅ $msg'));

    emit(state.copyWith(messages: finalMessages));
  }

  // ───────────────── HANDLE RESPONSE ─────────────────

  void _handleJsonResponse(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final reply = data['reply'] as String? ?? '';

      final type = data['type'] as String?;

      final conversationId = data['conversation_id'] as String?;

      final msg = ChatMessageEntity(
        role: 'assistant',
        content: reply,
        type: type,
        hotels: data['hotels'] as List<dynamic>?,
        availability: data['availability'] as List<dynamic>?,
        bookings: data['bookings'] as List<dynamic>?,
        booking: data['booking'],
      );

      final finalMessages = List<ChatMessageEntity>.from(state.messages)
        ..add(msg);

      emit(
        state.copyWith(
          messages: finalMessages,
          conversationId: conversationId ?? state.conversationId,
          isSending: false,
          streamingText: '',
        ),
      );
    } catch (e) {
      _appendError('Không thể đọc phản hồi từ server.');
    }
  }

  // ───────────────── ERROR ─────────────────

  void _appendError(String msg) {
    final finalMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(ChatMessageEntity(role: 'assistant', content: '⚠️ $msg'));

    emit(
      state.copyWith(
        messages: finalMessages,
        isSending: false,
        streamingText: '',
      ),
    );
  }
}
