import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cubit/chatbot_cubit.dart';

class ChatbotHistoryDrawer extends StatelessWidget {
  final ChatbotCubit cubit;
  const ChatbotHistoryDrawer({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  if (!snapshot.hasData)
                    return const Center(child: Text('Không có dữ liệu'));

                  final sessions = snapshot.data as List<dynamic>;
                  if (sessions.isEmpty)
                    return const Center(child: Text('Chưa có lịch sử chat'));

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
                            color: const Color(0xFF0A84FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF0A84FF),
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
    );
  }
}
