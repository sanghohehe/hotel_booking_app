import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  @override
  Future<ChatMessageEntity> sendMessage({
    required String message,
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> context, 
  }) async {
    final res = await Supabase.instance.client.functions.invoke(
      'chatbot',
      body: {'message': message, 'history': history, 'context': context},
    );

    final data = res.data;
    return ChatMessageEntity(
      role: 'assistant',
      content: data['reply']?.toString() ?? '',
      hotels: data['hotels'] as List?,
      availability: data['availability'] as List?,
      bookings: data['bookings'] as List?,
    );
  }
}
