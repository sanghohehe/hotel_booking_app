import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../hotel/data/models/hotel_model.dart';

class HotelAdminCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HotelAdminCard({
    super.key,
    required this.hotel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Logic lấy giá thấp nhất
    final minPrice =
        hotel.roomTypes.isNotEmpty
            ? hotel.roomTypes
                .map((e) => e.pricePerNight)
                .reduce((a, b) => a < b ? a : b)
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail
              _buildThumbnail(),
              // Info
              Expanded(child: _buildInfo(minPrice)),
              // Actions
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return SizedBox(
      width: 100,
      child:
          hotel.thumbnailUrl != null && hotel.thumbnailUrl!.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: hotel.thumbnailUrl!,
                fit: BoxFit.cover,
                // Hiển thị một khung màu xám nhẹ trong khi chờ tải ảnh
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                // Hiển thị icon lỗi nếu URL hỏng hoặc không có mạng
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
              )
              : Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
    );
  }

  Widget _buildInfo(double? minPrice) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotel.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hotel.city,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildChip('${hotel.starRating} ★', Colors.orange),
              const SizedBox(width: 8),
              _buildChip(
                minPrice != null ? '\$${minPrice.toInt()}+' : 'N/A',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.grey[50],
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
            onPressed: onEdit,
          ),
          const Divider(height: 1, indent: 10, endIndent: 10),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
