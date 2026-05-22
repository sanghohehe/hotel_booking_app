import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;

  const ChatDetailPage({super.key, required this.conversationId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  bool loading = true;

  List<dynamic> messages = [];
  @override
  void initState() {
    super.initState();
    print('CHAT DETAIL INIT');

    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      print('========= LOAD CHAT =========');
      print('conversationId: ${widget.conversationId}');

      final List<dynamic> data = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .eq('conversation_id', widget.conversationId)
          .order('created_at', ascending: true);

      print('DATA:');
      print(data);

      setState(() {
        messages = data;
        loading = false;
      });
    } catch (e, s) {
      print('========= ERROR =========');
      print(e);
      print(s);

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chat')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? const Center(child: Text('Không có tin nhắn'))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];

                  final isUser = m['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m['message'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
