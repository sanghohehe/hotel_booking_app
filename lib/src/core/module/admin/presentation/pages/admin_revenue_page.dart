import 'package:booking_app/src/core/module/admin/presentation/pages/admin_user_detail_page.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../supabase/supabase_manager.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  final _client = SupabaseManager.client;
  final _currencyFmt = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  // Filter
  String _period = 'month'; // 'week' | 'month' | 'year'
  late Future<_RevenueData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRevenue();
  }

  Future<void> _reload() async {
    setState(() => _future = _loadRevenue());
  }

  Future<_RevenueData> _loadRevenue() async {
    // Chỉ tính booking có status = done
    final raw = await _client
        .from('bookings')
        .select(
          'id, total_price, check_in, created_at, hotel_id, user_id, '
          'hotels(name)',
        )
        .eq('status', 'done')
        .order('check_in', ascending: true);

    final rows = (raw as List).cast<Map<String, dynamic>>();

    final now = DateTime.now();
    double totalAll = 0;
    double totalThisPeriod = 0;
    double totalLastPeriod = 0;
    int completedBookings = 0;

    final chartMap = <String, double>{};
    final hotelMap = <String, double>{};
    final hotelNameMap = <String, String>{};
    final userMap = <String, double>{};

    // Xác định khoảng thời gian
    DateTime periodStart;
    DateTime periodEnd = now; // Giới hạn trên của kỳ này
    DateTime lastPeriodStart;
    DateTime lastPeriodEnd;
    String Function(DateTime) chartKey;
    List<String> chartLabels;

    if (_period == 'week') {
      periodStart = now.subtract(Duration(days: now.weekday - 1));
      periodStart = DateTime(
        periodStart.year,
        periodStart.month,
        periodStart.day,
      );
      // Kỳ này kết thúc cuối tuần sau
      periodEnd = periodStart.add(const Duration(days: 7));
      lastPeriodStart = periodStart.subtract(const Duration(days: 7));
      lastPeriodEnd = periodStart;
      chartKey = (d) => DateFormat('EEE').format(d);
      chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (final l in chartLabels) {
        chartMap[l] = 0;
      }
    } else if (_period == 'month') {
      periodStart = DateTime(now.year, now.month, 1);
      periodEnd = DateTime(now.year, now.month + 1, 1);
      lastPeriodStart = DateTime(now.year, now.month - 1, 1);
      lastPeriodEnd = periodStart;
      chartKey = (d) => '${d.day}';
      chartLabels = List.generate(
        DateUtils.getDaysInMonth(now.year, now.month),
        (i) => '${i + 1}',
      );
      for (final l in chartLabels) {
        chartMap[l] = 0;
      }
    } else {
      // year
      periodStart = DateTime(now.year, 1, 1);
      periodEnd = DateTime(now.year + 1, 1, 1);
      lastPeriodStart = DateTime(now.year - 1, 1, 1);
      lastPeriodEnd = periodStart;
      chartKey = (d) => DateFormat('MMM').format(d);
      chartLabels = List.generate(
        12,
        (i) => DateFormat('MMM').format(DateTime(now.year, i + 1)),
      );
      for (final l in chartLabels) {
        chartMap[l] = 0;
      }
    }

    for (final row in rows) {
      final price = (row['total_price'] as num?)?.toDouble() ?? 0;
      final checkInStr = row['check_in'] as String?;
      if (checkInStr == null) continue;
      final checkIn = DateTime.tryParse(checkInStr);
      if (checkIn == null) continue;

      totalAll += price;
      completedBookings++;

      // Hotel
      final hotelId = row['hotel_id']?.toString() ?? '';
      final hotelName =
          (row['hotels'] as Map?)?['name']?.toString() ?? 'Unknown';
      hotelMap[hotelId] = (hotelMap[hotelId] ?? 0) + price;
      hotelNameMap[hotelId] = hotelName;

      // User
      final userId = row['user_id']?.toString() ?? '';
      userMap[userId] = (userMap[userId] ?? 0) + price;

      // Phân bổ chính xác vào Kỳ này / Kỳ trước / Biểu đồ
      if (!checkIn.isBefore(periodStart) && checkIn.isBefore(periodEnd)) {
        totalThisPeriod += price;
        final key = chartKey(checkIn);
        if (chartMap.containsKey(key)) {
          chartMap[key] = (chartMap[key] ?? 0) + price;
        }
      } else if (!checkIn.isBefore(lastPeriodStart) &&
          checkIn.isBefore(lastPeriodEnd)) {
        totalLastPeriod += price;
      }
    }

    // Top hotels
    final topHotels =
        hotelMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5Hotels =
        topHotels
            .take(5)
            .map(
              (e) => _TopItem(
                id: e.key,
                name: hotelNameMap[e.key] ?? 'Unknown',
                revenue: e.value,
              ),
            )
            .toList();

    // Top users
    final topUserIds =
        (userMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => e.key)
            .toList();

    List<_TopItem> top5Users = [];
    if (topUserIds.isNotEmpty) {
      // SỬA LỖI: Thay thế .inFilter bằng phương thức .in_ hợp lệ của Supabase
      final usersRaw = await _client
          .from('user_profiles')
          .select('user_id, full_name, avatar_url')
          .filter('user_id', 'in', topUserIds); // Thay cho .in_
      final userNameMap = <String, String>{};
      final userAvatarMap = <String, String?>{};
      final userRawDataMap = <String, Map<String, dynamic>>{};

      for (final u in (usersRaw as List)) {
        final m = (u as Map).cast<String, dynamic>();
        final uid = m['user_id']?.toString() ?? '';
        userNameMap[uid] = m['full_name']?.toString() ?? 'Unknown';
        userAvatarMap[uid] = m['avatar_url']?.toString();
        userRawDataMap[uid] =
            m; // Lưu lại map gốc để truyền sang trang chi tiết
      }

      top5Users =
          topUserIds
              .map(
                (uid) => _TopItem(
                  id: uid,
                  name: userNameMap[uid] ?? 'Unknown',
                  revenue: userMap[uid] ?? 0,
                  avatarUrl: userAvatarMap[uid],
                  userData: userRawDataMap[uid], // Gán dữ liệu map user vào đây
                ),
              )
              .toList();
    }

    // Chart spots
    final spots = <FlSpot>[];
    for (int i = 0; i < chartLabels.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartMap[chartLabels[i]] ?? 0));
    }

    return _RevenueData(
      totalAll: totalAll,
      totalThisPeriod: totalThisPeriod,
      totalLastPeriod: totalLastPeriod,
      completedBookings: completedBookings,
      chartLabels: chartLabels,
      chartSpots: spots,
      topHotels: top5Hotels,
      topUsers: top5Users,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Revenue Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<_RevenueData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPeriodFilter(),
                const SizedBox(height: 16),
                _buildSummaryCards(data),
                const SizedBox(height: 20),
                _buildChartCard(data),
                const SizedBox(height: 20),
                _buildTopHotels(data.topHotels),
                const SizedBox(height: 20),
                _buildTopUsers(data.topUsers),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Row(
      children: [
        _PeriodChip(
          label: 'Tuần',
          value: 'week',
          selected: _period == 'week',
          onTap: () {
            setState(() => _period = 'week');
            _reload();
          },
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Tháng',
          value: 'month',
          selected: _period == 'month',
          onTap: () {
            setState(() => _period = 'month');
            _reload();
          },
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Năm',
          value: 'year',
          selected: _period == 'year',
          onTap: () {
            setState(() => _period = 'year');
            _reload();
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards(_RevenueData data) {
    final changePercent =
        data.totalLastPeriod == 0
            ? 0.0
            : (data.totalThisPeriod - data.totalLastPeriod) /
                data.totalLastPeriod *
                100;
    final isUp = changePercent >= 0;

    return Column(
      children: [
        _SummaryCard(
          title: 'Tổng doanh thu',
          value: _currencyFmt.format(data.totalAll),
          icon: Icons.attach_money,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: _periodLabel(),
                value: _currencyFmt.format(data.totalThisPeriod),
                icon: Icons.trending_up,
                color: Colors.green,
                subtitle:
                    '${isUp ? '+' : ''}${changePercent.toStringAsFixed(1)}% vs kỳ trước',
                subtitleColor: isUp ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Hoàn thành',
                value: '${data.completedBookings}',
                icon: Icons.check_circle_outline,
                color: Colors.purple,
                subtitle: 'bookings',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(_RevenueData data) {
    if (data.chartSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = data.chartSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doanh thu theo ${_period == 'week'
                ? 'ngày trong tuần'
                : _period == 'month'
                ? 'ngày trong tháng'
                : 'tháng'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget:
                          (value, _) => Text(
                            value == 0
                                ? ''
                                : '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _period == 'month' ? 4 : 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.chartLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data.chartLabels[idx],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.chartLabels.length - 1).toDouble(),
                minY: 0,
                maxY: maxY * 1.2 == 0 ? 100 : maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.chartSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHotels(List<_TopItem> hotels) {
    if (hotels.isEmpty) return const SizedBox.shrink();

    return _RankingCard(
      title: 'Top khách sạn doanh thu cao nhất',
      icon: Icons.hotel,
      items: hotels,
      currencyFmt: _currencyFmt,
    );
  }

  Widget _buildTopUsers(List<_TopItem> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    return _RankingCard(
      title: 'Top khách hàng chi tiêu nhiều nhất',
      icon: Icons.people,
      items: users,
      currencyFmt: _currencyFmt,
      showAvatar: true,
      onItemTap: (item) {
        if (item.userData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AdminUserDetailPage(
                    // SỬA TẠI ĐÂY: Sử dụng factory constructor của class UserProfileModel để map dữ liệu
                    user: UserProfileModel.fromJson(item.userData!),
                    // Hoặc UserProfileModel.fromMap(item.userData!) tùy thuộc vào cách bạn đặt tên trong Model của mình
                  ),
            ),
          );
        }
      },
    );
  }

  String _periodLabel() {
    switch (_period) {
      case 'week':
        return 'Tuần này';
      case 'month':
        return 'Tháng này';
      case 'year':
        return 'Năm này';
      default:
        return '';
    }
  }
}

// ── Summary Card ──
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Color? subtitleColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: subtitleColor ?? Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period Chip ──
class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Ranking Card ──
class _RankingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_TopItem> items;
  final NumberFormat currencyFmt;
  final bool showAvatar;
  final Function(_TopItem)? onItemTap;

  const _RankingCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.currencyFmt,
    this.showAvatar = false,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final medals = ['🥇', '🥈', '🥉'];
            final rank = i < 3 ? medals[i] : '${i + 1}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      rank,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onItemTap?.call(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            if (showAvatar) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue[50],
                                backgroundImage:
                                    item.avatarUrl != null
                                        ? NetworkImage(item.avatarUrl!)
                                        : null,
                                child:
                                    item.avatarUrl == null
                                        ? Text(
                                          item.name.isNotEmpty
                                              ? item.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currencyFmt.format(item.revenue),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Data Models ──
class _RevenueData {
  final double totalAll;
  final double totalThisPeriod;
  final double totalLastPeriod;
  final int completedBookings;
  final List<String> chartLabels;
  final List<FlSpot> chartSpots;
  final List<_TopItem> topHotels;
  final List<_TopItem> topUsers;

  _RevenueData({
    required this.totalAll,
    required this.totalThisPeriod,
    required this.totalLastPeriod,
    required this.completedBookings,
    required this.chartLabels,
    required this.chartSpots,
    required this.topHotels,
    required this.topUsers,
  });
}

class _TopItem {
  final String id;
  final String name;
  final double revenue;
  final String? avatarUrl;
  final Map<String, dynamic>?
  userData; // SỬA LỖI: Thêm trường lưu trữ dữ liệu user để chuyển page

  _TopItem({
    required this.id,
    required this.name,
    required this.revenue,
    this.avatarUrl,
    this.userData,
  });
}
