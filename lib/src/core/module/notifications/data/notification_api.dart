import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/notification_model.dart';

class NotificationApi {
  SupabaseClient get _client => Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not logged in');
    return id;
  }

  Future<List<AppNotification>> getMyNotifications({int limit = 50}) async {
    final uid = _client.auth.currentUser?.id;
  
    print('[noti] currentUserId=$uid');

    final data = await _client
        .from('notifications')
        .select('id, type, title, body, data, is_read, created_at')
        .order('created_at', ascending: false)
        .limit(limit);

    print('[noti] rows=${(data as List).length}');

    return (data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> countUnread() async {
    final data = await _client
        .from('notifications')
        .select('id')
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

  Future<List<AppNotification>> getAdminNotifications({int limit = 50}) async {
    final data = await _client
        .from('notifications')
        .select('id, type, title, body, data, is_read, created_at')
        .eq('is_admin_notification', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> countAdminUnread() async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('is_admin_notification', true)
        .eq('is_read', false);

    return (data as List).length;
  }

  Future<void> markAdminRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('is_admin_notification', true);
  }

  Future<void> markAllAdminRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('is_admin_notification', true)
        .eq('is_read', false);
  }
}
