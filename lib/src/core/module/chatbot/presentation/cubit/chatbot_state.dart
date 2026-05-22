import '../../domain/entities/chat_message_entity.dart';

class ChatbotState {
  final List<ChatMessageEntity> messages;

  final bool isSending;

  final Map<String, dynamic> botContext;

  final int guests;

  final String streamingText;

  final String? conversationId;

  const ChatbotState({
    this.messages = const [],
    this.isSending = false,
    this.botContext = const {},
    this.guests = 2,
    this.streamingText = '',
    this.conversationId,
  });

  // ───────────────── INITIAL ─────────────────

  factory ChatbotState.initial() {
    return const ChatbotState();
  }

  // ───────────────── GETTERS ─────────────────

  bool get isStreaming => streamingText.isNotEmpty;

  // ───────────────── FORMAT ─────────────────

  String formatVnd(dynamic v) {
    final n = (v is num) ? v.toDouble() : double.tryParse(v.toString());

    if (n == null) return '';

    final s = n.toStringAsFixed(0);

    return '${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}đ';
  }

  // ───────────────── COPY WITH ─────────────────

  ChatbotState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isSending,
    Map<String, dynamic>? botContext,
    int? guests,
    String? streamingText,

    // IMPORTANT
    String? conversationId,
    bool clearConversationId = false,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,

      isSending: isSending ?? this.isSending,

      botContext: botContext ?? this.botContext,

      guests: guests ?? this.guests,

      streamingText: streamingText ?? this.streamingText,

      conversationId:
          clearConversationId ? null : conversationId ?? this.conversationId,
    );
  }
}
