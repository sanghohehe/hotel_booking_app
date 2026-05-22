import 'package:flutter/material.dart';
import 'package:booking_app/src/core/module/admin/data/datasource/user_admin_api.dart';
import 'package:booking_app/src/core/module/bookings/data/models/booking_model.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';

class AdminUserDetailPage extends StatefulWidget {
  final UserProfileModel user;
  const AdminUserDetailPage({super.key, required this.user});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  final _api = UserAdminApi();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bookings = await _api.getBookingsByUserId(widget.user.userId);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.user.fullName ?? 'Chi tiết người dùng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildUserInfoCard(),
          _buildBookingStats(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lịch sử đặt phòng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final user = widget.user;
    return Container(
      margin: const EdgeInsets.all(16),
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
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue[50],
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.fullName?.isNotEmpty == true
                        ? user.fullName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Chưa cập nhật tên',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(user.phoneNumber!,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ],
                if (user.address != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.address!,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStats() {
    final total = _bookings.length;
    final done = _bookings.where((b) => b.status == 'done').length;
    final pending = _bookings.where((b) => b.status == 'pending').length;
    final cancelled = _bookings.where((b) => b.status == 'cancelled').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tổng', total, Colors.blue),
          _buildDivider(),
          _buildStatItem('Hoàn thành', done, Colors.green),
          _buildDivider(),
          _buildStatItem('Chờ xử lý', pending, Colors.orange),
          _buildDivider(),
          _buildStatItem('Đã hủy', cancelled, Colors.red),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 36, width: 1, color: Colors.grey[200]);
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBookingList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Chưa có đặt phòng nào',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _bookings.length,
        itemBuilder: (_, index) => _buildBookingCard(_bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusInfo = _getStatusInfo(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.hotelName ?? 'Khách sạn',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusInfo['label'],
                    style: TextStyle(
                      color: statusInfo['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (booking.hotelCity != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    booking.hotelCity!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
            if (booking.roomTypeName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.meeting_room, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    booking.roomTypeName!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateInfo(
                      'Check-in', booking.checkIn, Icons.login),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: Colors.grey),
                  _buildDateInfo(
                      'Check-out', booking.checkOut, Icons.logout),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${booking.totalPrice.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '${booking.checkOut.difference(booking.checkIn).inDays} đêm',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'done':
        return {'label': 'Hoàn thành', 'color': Colors.green};
      case 'confirmed':
        return {'label': 'Đã xác nhận', 'color': Colors.blue};
      case 'pending':
        return {'label': 'Chờ xử lý', 'color': Colors.orange};
      case 'cancelled':
        return {'label': 'Đã hủy', 'color': Colors.red};
      default:
        return {'label': status, 'color': Colors.grey};
    }
  }
}