import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../bookings/presentation/pages/booking_confirm_page.dart';

class RoomCard extends StatelessWidget {
  final HotelEntity hotel;
  final dynamic room;

  const RoomCard({super.key, required this.hotel, required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToConfirm(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildRoomImage(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Ưu đãi tốt nhất',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10), // Giảm padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name ?? 'Phòng tiêu chuẩn',
                          style: theme.textTheme.titleMedium?.copyWith(
                            // Giảm text size
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'x${room.capacity ?? 0}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Giảm spacing
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildFeatureChip(Icons.wifi, 'Free Wifi'),
                      _buildFeatureChip(Icons.ac_unit, 'Điều hòa'),
                      if (room.bedType != null)
                        _buildFeatureChip(
                          Icons.king_bed_outlined,
                          room.bedType!,
                        ),
                    ],
                  ),
                  const Divider(height: 16), // Giảm divider height
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá mỗi đêm',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '\$${(room.pricePerNight ?? 0).toStringAsFixed(0)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                TextSpan(
                                  text: ' /đêm',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _navigateToConfirm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          minimumSize: const Size(
                            60,
                            32,
                          ), // Rút gọn kích thước nút
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Đặt ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
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

  Widget _buildRoomImage() {
    String? displayImageUrl;

    try {
      // ROOM IMAGE
      if (room.imageUrl != null &&
          room.imageUrl is List &&
          room.imageUrl.isNotEmpty) {
        final first = room.imageUrl.first.toString().trim();

        if (first.isNotEmpty && first.startsWith('http')) {
          displayImageUrl = first;
        }
      }

      // HOTEL IMAGE FALLBACK
      if (displayImageUrl == null && hotel.thumbnailUrl != null) {
        final thumb = hotel.thumbnailUrl!.trim();

        if (thumb.isNotEmpty && thumb.startsWith('http')) {
          displayImageUrl = thumb;
        }
      }
    } catch (e) {
      debugPrint('IMAGE PARSE ERROR: $e');
    }

    // PLACEHOLDER
    if (displayImageUrl == null) {
      return Container(
        height: 110,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel_rounded, size: 30, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              'Không có hình ảnh',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: displayImageUrl,
      height: 110,
      width: double.infinity,
      fit: BoxFit.cover,

      // Thay thế cho loadingBuilder
      placeholder:
          (context, url) => Container(
            height: 110,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),

      // Thay thế cho errorBuilder
      errorWidget: (context, url, error) {
        // In log lỗi tương tự như code cũ của bạn
        debugPrint('IMAGE LOAD ERROR: $url');
        debugPrint(error.toString());

        return Container(
          height: 110,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 30, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                'Ảnh lỗi',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingConfirmPage(hotel: hotel, roomType: room),
      ),
    );
  }
}
