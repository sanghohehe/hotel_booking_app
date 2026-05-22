import 'package:booking_app/src/core/module/bookings/presentation/widgets/booking_section_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookingInfoCard extends StatelessWidget {
  final String hotelName;
  final String roomTypeName;
  final String? imageUrl;
  final int maxCapacity;

  const BookingInfoCard({
    super.key,
    required this.hotelName,
    required this.roomTypeName,
    this.imageUrl,
    required this.maxCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? '',
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              // Hiển thị khi đang tải ảnh
              placeholder:
                  (context, url) => Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              // Hiển thị khi URL rỗng hoặc lỗi tải ảnh
              errorWidget:
                  (context, url, error) => Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
              // Tối ưu RAM cho kích thước 85x85
              memCacheWidth: 170,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  roomTypeName,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                Text('Sức chứa: $maxCapacity'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
