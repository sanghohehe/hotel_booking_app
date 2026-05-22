import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatbotUseCase {
  final _client = Supabase.instance.client;

  ChatbotUseCase();

  Future<ChatMessageEntity> execute({
    required String message,
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> context,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'chatbot',
        body: {'message': message, 'history': history, 'context': context},
      );

      if (response.status != 200) {
        throw Exception('Server returned ${response.status}');
      }

      final data = response.data;

      return ChatMessageEntity(
        role: 'assistant',
        content: data['reply'] ?? '',
        hotels: data['hotels'],
        availability: data['availability'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
