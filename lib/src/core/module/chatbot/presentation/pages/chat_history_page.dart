import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_detail_page.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  bool loading = false;

  List<dynamic> conversations = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      load();
    });
  }

  Future<void> load() async {
    try {
      setState(() {
        loading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() {
          loading = false;
        });

        return;
      }

      final List<dynamic> data = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        conversations = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử Chat')),

      body: Builder(
        builder: (_) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (conversations.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử chat'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final c = conversations[index];

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(c['title'] ?? ''),
                subtitle: Text(c['created_at'].toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(conversationId: c['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
