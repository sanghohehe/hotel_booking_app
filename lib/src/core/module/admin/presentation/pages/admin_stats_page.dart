import 'package:booking_app/src/core/module/admin/presentation/pages/admin_user_page.dart';
import 'package:flutter/material.dart';

import '../../../../supabase/supabase_manager.dart';
import 'admin_bookings_page.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final _client = SupabaseManager.client;
  late Future<_AdminStats> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStats();
  }

  Future<_AdminStats> _loadStats() async {
    final hotels = await _client.from('hotels').select('id');
    final bookings = await _client.from('bookings').select('id, total_price');
    final users = await _client.from('user_profiles').select('user_id');

    final hotelCount = (hotels as List).length;
    final bookingCount = (bookings as List).length;
    final userCount = (users as List).length;

    double revenue = 0;
    for (final row in bookings as List) {
      final v = row['total_price'];
      if (v is num) {
        revenue += v.toDouble();
      }
    }

    return _AdminStats(
      hotelCount: hotelCount,
      bookingCount: bookingCount,
      userCount: userCount,
      totalRevenue: revenue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<_AdminStats>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading stats:\n${snapshot.error}'));
        }

        final stats = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _future = _loadStats();
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(
                title: 'Total hotels',
                value: stats.hotelCount.toString(),
                icon: Icons.hotel,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Total bookings',
                value: stats.bookingCount.toString(),
                icon: Icons.receipt_long,
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminBookingsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Total users',
                value: stats.userCount.toString(),
                icon: Icons.person,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminUserPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Total revenue',
                value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminStats {
  final int hotelCount;
  final int bookingCount;
  final int userCount;
  final double totalRevenue;

  _AdminStats({
    required this.hotelCount,
    required this.bookingCount,
    required this.userCount,
    required this.totalRevenue,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
