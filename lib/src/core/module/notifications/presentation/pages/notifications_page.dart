import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/notification_api.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _api = NotificationApi();
  SupabaseClient get _client => Supabase.instance.client;

  String _timeText(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllRead();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _onTap(AppNotification n) async {
    try {
      if (!n.isRead) await _api.markRead(n.id);

      // TODO: Bạn có thể điều hướng theo n.type + n.data ở đây
      // Ví dụ:
      // if (n.type == 'booking_done') -> mở HotelDetailPage(openReviewOnStart: true)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _client.auth.currentUser?.id;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Bạn cần đăng nhập để xem thông báo.')),
      );
    }

    // RLS select_own đã lọc theo auth.uid() rồi
    final stream = _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Đọc hết')),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Lỗi load notifications:\n${snap.error}'),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snap.data!;
          final list = rows
              .map((e) => AppNotification.fromJson(e))
              .toList(growable: false);

          if (list.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];

              return InkWell(
                onTap: () => _onTap(n),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        n.isRead
                            ? Colors.grey.withOpacity(0.08)
                            : Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        n.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                fontWeight:
                                    n.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(n.body),
                            const SizedBox(height: 6),
                            Text(
                              _timeText(n.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
