import '../entities/chat_message_entity.dart';

abstract class ChatbotRepository {
  Future<ChatMessageEntity> sendMessage({
    required String message,
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> context,
  });
}
