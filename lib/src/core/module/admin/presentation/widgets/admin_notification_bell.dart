import 'dart:async';

import 'package:booking_app/src/core/module/admin/presentation/pages/admin_notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../notifications/data/notification_api.dart';

class AdminNotificationBell extends StatefulWidget {
  const AdminNotificationBell({super.key});

  @override
  State<AdminNotificationBell> createState() => _AdminNotificationBellState();
}

class _AdminNotificationBellState extends State<AdminNotificationBell> {
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
      final c = await _api.countAdminUnread();
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
    _channel = _client
        .channel('admin_notifications_bell')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
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
      tooltip: 'Thông báo Admin',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminNotificationsPage()),
        );
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