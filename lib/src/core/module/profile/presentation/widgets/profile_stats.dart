import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int bookingCount;
  final int favoriteCount;
  final bool isLoading;
  final VoidCallback? onBookingTap; // Thêm callback
  final VoidCallback? onFavoriteTap; // Thêm callback

  const ProfileStats({
    super.key,
    required this.bookingCount,
    required this.favoriteCount,
    this.isLoading = false,
    this.onBookingTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          label: 'Bookings',
          value: bookingCount.toString(),
          onTap: onBookingTap, // Truyền vào đây
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          context,
          label: 'Favorites',
          value: favoriteCount.toString(),
          onTap: onFavoriteTap, // Truyền vào đây
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // Bọc GestureDetector để nhận sự kiện click
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
