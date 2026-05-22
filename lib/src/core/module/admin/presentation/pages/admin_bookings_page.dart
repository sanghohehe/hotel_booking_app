import 'package:booking_app/src/core/module/admin/presentation/pages/admin_user_detail_page.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../supabase/supabase_manager.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final _client = SupabaseManager.client;
  late Future<List<_AdminBookingItem>> _future;

  String _statusFilter = 'all';
  final Set<String> _confirmingIds = <String>{};
  final Set<String> _rejectingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _future = _loadBookings();
  }

  DateTime _parseDate(Map<String, dynamic> row, String k1, String k2) {
    final v = row[k1] ?? row[k2];
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'done':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _paymentColor(String s) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _paymentIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'momo':
        return Icons.account_balance_wallet;
      case 'vnpay':
        return Icons.payment;
      case 'cash':
        return Icons.money;
      default:
        return Icons.credit_card_off;
    }
  }

  Future<List<_AdminBookingItem>> _loadBookings() async {
    dynamic q = _client.from('bookings').select();

    if (_statusFilter != 'all') {
      q = q.eq('status', _statusFilter);
    }

    final raw = await q.order('created_at', ascending: false);
    final rows = (raw as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return [];

    final hotelIds =
        rows.map((e) => e['hotel_id']).whereType<String>().toSet().toList();
    final roomIds =
        rows.map((e) => e['room_type_id']).whereType<String>().toSet().toList();
    final userIds =
        rows.map((e) => e['user_id']).whereType<String>().toSet().toList();

    final hotelsData = await _client
        .from('hotels')
        .select('id, name, city')
        .inFilter('id', hotelIds);

    final roomsData = await _client
        .from('room_types')
        .select('id, name')
        .inFilter('id', roomIds);

    final usersData = await _client
        .from('user_profiles')
        .select()
        .inFilter('user_id', userIds);

    final hotelMap = <String, Map<String, dynamic>>{};
    for (final h in (hotelsData as List)) {
      final m = (h as Map).cast<String, dynamic>();
      final id = m['id']?.toString();
      if (id != null) hotelMap[id] = m;
    }

    final roomMap = <String, Map<String, dynamic>>{};
    for (final r in (roomsData as List)) {
      final m = (r as Map).cast<String, dynamic>();
      final id = m['id']?.toString();
      if (id != null) roomMap[id] = m;
    }

    final userMap = <String, Map<String, dynamic>>{};
    for (final u in (usersData as List)) {
      final m = (u as Map).cast<String, dynamic>();
      final id = m['user_id']?.toString();
      if (id != null) userMap[id] = m;
    }

    return rows.map((b) {
      final hotelId = b['hotel_id']?.toString();
      final roomTypeId = b['room_type_id']?.toString();
      final userId = b['user_id']?.toString() ?? '';

      final hotel = hotelId == null ? null : hotelMap[hotelId];
      final room = roomTypeId == null ? null : roomMap[roomTypeId];
      final user = userId.isEmpty ? null : userMap[userId];

      final checkIn = _parseDate(b, 'check_in_date', 'check_in');
      final checkOut = _parseDate(b, 'check_out_date', 'check_out');
      final createdAt = _parseDate(b, 'created_at', 'createdAt');

      final totalPrice =
          b['total_price'] is num ? (b['total_price'] as num).toDouble() : 0.0;

      final adults =
          (b['guests_adults'] as num?)?.toInt() ??
          (b['adults'] as num?)?.toInt() ??
          0;

      final children =
          (b['guests_children'] as num?)?.toInt() ??
          (b['children'] as num?)?.toInt() ??
          0;

      return _AdminBookingItem(
        id: b['id']?.toString() ?? '',
        userId: userId,
        status: b['status']?.toString() ?? 'pending',
        checkIn: checkIn,
        checkOut: checkOut,
        createdAt: createdAt,
        totalPrice: totalPrice,
        adults: adults,
        children: children,
        hotelName: hotel?['name']?.toString() ?? 'Unknown hotel',
        hotelCity: hotel?['city']?.toString() ?? '',
        roomName: room?['name']?.toString() ?? '',
        userName: user?['full_name']?.toString() ?? 'Unknown user',
        userEmail: user?['email']?.toString() ?? '',
        userAvatarUrl: user?['avatar_url']?.toString(),
        userPhone: user?['phone_number']?.toString(),
        userAddress: user?['address']?.toString(),
        paymentStatus: b['payment_status']?.toString() ?? 'pending',
        paymentMethod: b['payment_method']?.toString(),
      );
    }).toList();
  }

  Future<void> _reload() async {
    setState(() => _future = _loadBookings());
  }

  // ✅ Confirm booking
  Future<void> _confirmBooking(_AdminBookingItem b) async {
    if (_confirmingIds.contains(b.id)) return;

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.verified_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text('Xác nhận booking'),
              ],
            ),
            content: Text('Xác nhận booking này?\n\nID: ${b.id}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (ok != true) return;
    setState(() => _confirmingIds.add(b.id));

    try {
      final raw = await _client
          .from('bookings')
          .update({'status': 'confirmed'})
          .eq('id', b.id)
          .eq('status', 'pending')
          .select('id, status');

      final rows = (raw as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể confirm: booking không còn pending.'),
          ),
        );
        await _reload();
        return;
      }

      // Gửi notification cho user
      try {
        await _client.from('notifications').insert({
          'user_id': b.userId,
          'type': 'booking_confirmed',
          'title': '✅ Booking đã được xác nhận',
          'body':
              'Booking tại ${b.hotelName} (${b.roomName}) đã được xác nhận. Chúc bạn có chuyến đi vui vẻ!',
        });
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã xác nhận booking thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _confirmingIds.remove(b.id));
    }
  }

  // ✅ Reject booking
  Future<void> _rejectBooking(_AdminBookingItem b) async {
    if (_rejectingIds.contains(b.id)) return;

    final reasonCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text('Từ chối booking'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Từ chối booking này?\n\nID: ${b.id}'),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Lý do từ chối (tùy chọn)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Từ chối',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (ok != true) return;
    setState(() => _rejectingIds.add(b.id));

    try {
      final raw = await _client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', b.id)
          .eq('status', 'pending')
          .select('id, status');

      final rows = (raw as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể từ chối: booking không còn pending.'),
          ),
        );
        await _reload();
        return;
      }

      // Gửi notification cho user
      try {
        final reason = reasonCtrl.text.trim();
        await _client.from('notifications').insert({
          'user_id': b.userId,
          'type': 'booking_cancelled',
          'title': '❌ Booking đã bị từ chối',
          'body':
              reason.isNotEmpty
                  ? 'Booking tại ${b.hotelName} đã bị từ chối. Lý do: $reason'
                  : 'Booking tại ${b.hotelName} đã bị từ chối bởi admin.',
        });
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Đã từ chối booking.'),
          backgroundColor: Colors.red,
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _rejectingIds.remove(b.id));
    }
  }

  // ✅ Navigate sang AdminUserDetailPage
  void _openUserDetail(_AdminBookingItem b) {
    final user = UserProfileModel(
      userId: b.userId,
      fullName: b.userName,
      phoneNumber: b.userPhone,
      address: b.userAddress,
      avatarUrl: b.userAvatarUrl,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUserDetailPage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Bookings')),
      body: FutureBuilder<List<_AdminBookingItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          return Column(
            children: [
              // Filter dropdown
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: DropdownButtonFormField<String>(
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text('Confirmed'),
                    ),
                    DropdownMenuItem(value: 'done', child: Text('Done')),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    setState(() => _statusFilter = v);
                    await _reload();
                  },
                ),
              ),

              Expanded(
                child:
                    bookings.isEmpty
                        ? Center(
                          child: Text(
                            _statusFilter == 'all'
                                ? 'Chưa có booking nào.'
                                : 'Không có booking với status = $_statusFilter',
                            textAlign: TextAlign.center,
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: _reload,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: bookings.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final b = bookings[index];
                              final dateRange =
                                  '${dateFmt.format(b.checkIn)} → ${dateFmt.format(b.checkOut)}';
                              final statusColor = _statusColor(b.status);
                              final canAction = b.status == 'pending';
                              final confirming = _confirmingIds.contains(b.id);
                              final rejecting = _rejectingIds.contains(b.id);

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Hotel name + Status badge ──
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            b.hotelName,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(
                                              0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            b.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),
                                    Text(
                                      '${b.hotelCity} • ${b.roomName}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),

                                    const Divider(height: 20),

                                    // ── User info (clickable) ──
                                    GestureDetector(
                                      onTap: () => _openUserDetail(b),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.blue[50],
                                            backgroundImage:
                                                b.userAvatarUrl != null
                                                    ? NetworkImage(
                                                      b.userAvatarUrl!,
                                                    )
                                                    : null,
                                            child:
                                                b.userAvatarUrl == null
                                                    ? Text(
                                                      b.userName.isNotEmpty
                                                          ? b.userName[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: TextStyle(
                                                        color: Colors.blue[700],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                    : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  b.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (b.userEmail.isNotEmpty)
                                                  Text(
                                                    b.userEmail,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // ── Date + Guests ──
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.date_range,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateRange,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.group,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${b.adults} adults'
                                          '${b.children > 0 ? ' • ${b.children} children' : ''}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // ── Payment status ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _paymentIcon(b.paymentMethod),
                                            size: 18,
                                            color: _paymentColor(
                                              b.paymentStatus,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  b.paymentMethod
                                                          ?.toUpperCase() ??
                                                      'CHƯA THANH TOÁN',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  b.paymentStatus.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _paymentColor(
                                                      b.paymentStatus,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${b.totalPrice.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Created: ${dateFmt.format(b.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),

                                    // ── Action buttons (chỉ hiện khi pending) ──
                                    if (canAction) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          // Từ chối
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed:
                                                  rejecting
                                                      ? null
                                                      : () => _rejectBooking(b),
                                              icon:
                                                  rejecting
                                                      ? const SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                      : const Icon(
                                                        Icons.cancel_outlined,
                                                        size: 16,
                                                      ),
                                              label: Text(
                                                rejecting
                                                    ? 'Đang xử lý...'
                                                    : 'Từ chối',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Xác nhận
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  confirming
                                                      ? null
                                                      : () =>
                                                          _confirmBooking(b),
                                              icon:
                                                  confirming
                                                      ? const SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                      : const Icon(
                                                        Icons.verified_outlined,
                                                        size: 16,
                                                      ),
                                              label: Text(
                                                confirming
                                                    ? 'Đang xử lý...'
                                                    : 'Xác nhận',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Data class ──
class _AdminBookingItem {
  final String id;
  final String userId;
  final String status;
  final DateTime checkIn;
  final DateTime checkOut;
  final DateTime createdAt;
  final double totalPrice;
  final int adults;
  final int children;
  final String hotelName;
  final String hotelCity;
  final String roomName;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl; // ✅ thêm
  final String? userPhone; // ✅ thêm
  final String? userAddress; // ✅ thêm
  final String paymentStatus; // ✅ thêm
  final String? paymentMethod; // ✅ thêm

  _AdminBookingItem({
    required this.id,
    required this.userId,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.createdAt,
    required this.totalPrice,
    required this.adults,
    required this.children,
    required this.hotelName,
    required this.hotelCity,
    required this.roomName,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    this.userPhone,
    this.userAddress,
    required this.paymentStatus,
    this.paymentMethod,
  });
}
