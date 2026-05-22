import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/notification_api.dart';
import '../pages/notifications_page.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _api = NotificationApi();
  SupabaseClient get _client => Supabase.instance.client;

  RealtimeChannel? _channel;
  int _unread = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    _bindRealtime();
  }

  Future<void> _loadUnread() async {
    try {
      final uid = _client.auth.currentUser?.id;
      // ignore: avoid_print
      print('[bell] currentUserId=$uid');

      final c = await _api.countUnread();
      if (!mounted) return;
      setState(() {
        _unread = c;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _bindRealtime() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    // NOTE: realtime_client của bạn không nhận filter String nữa -> KHÔNG dùng filter.
    _channel =
        _client
            .channel('notifications_bell_$uid')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'notifications',
              callback: (payload) {
                // Không filter ở đây, chỉ reload count (RLS vẫn đảm bảo data của user)
                _loadUnread();
              },
            )
            .subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      _client.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Thông báo',
      onPressed: () async {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
        // quay về thì refresh badge
        unawaited(_loadUnread());
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (!_loading && _unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
