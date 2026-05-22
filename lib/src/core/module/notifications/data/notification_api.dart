import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/notification_model.dart';

class NotificationApi {
  SupabaseClient get _client => Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not logged in');
    return id;
  }

  /// Lấy noti của user hiện tại (RLS select_own tự lọc theo auth.uid())
  Future<List<AppNotification>> getMyNotifications({int limit = 50}) async {
    final uid = _client.auth.currentUser?.id;
    // debug để check đúng user
    // ignore: avoid_print
    print('[noti] currentUserId=$uid');

    final data = await _client
        .from('notifications')
        .select('id, type, title, body, data, is_read, created_at')
        .order('created_at', ascending: false)
        .limit(limit);

    // ignore: avoid_print
    print('[noti] rows=${(data as List).length}');

    return (data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Đếm unread (để làm badge)
  Future<int> countUnread() async {
    final data = await _client
        .from('notifications')
        .select('id')
        // có thể thêm eq('user_id', _userId) nhưng mình KHÔNG thêm để tránh lệch client/user
        .eq('is_read', false);

    return (data as List).length;
  }

  Future<void> markRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', _userId);
  }

  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId)
        .eq('is_read', false);
  }
}
