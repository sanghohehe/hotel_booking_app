import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_model.dart';
import 'status_chip.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isPaying;
  final VoidCallback onPay;
  final VoidCallback onCancel;
  final VoidCallback onMarkDone;
  final VoidCallback onReview;

  final String Function(String) paymentLabel;
  final Color Function(BuildContext, String) paymentChipBg;
  final Color Function(String) paymentChipTextColor;
  final Color Function(String) statusChipBg;
  final Color Function(String) statusChipText;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isPaying,
    required this.onPay,
    required this.onCancel,
    required this.onMarkDone,
    required this.onReview,
    required this.paymentLabel,
    required this.paymentChipBg,
    required this.paymentChipTextColor,
    required this.statusChipBg,
    required this.statusChipText,
  });

  IconData _getAmenityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('wifi')) return Icons.wifi;
    if (n.contains('điều hòa') || n.contains('ac')) return Icons.ac_unit;
    if (n.contains('giường') || n.contains('queen') || n.contains('king'))
      return Icons.king_bed_outlined;
    if (n.contains('tivi')) return Icons.tv;
    return Icons.done;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');

    final isPending = booking.status == 'pending';
    final isConfirmed = booking.status == 'confirmed';
    final isDone = booking.status == 'done';
    final isCancelled =
        booking.status == 'cancelled' || booking.status == 'canceled';

    final canCancel =
        (isPending || isConfirmed) && booking.checkIn.isAfter(now);
    final canMarkDone = isConfirmed && !booking.checkOut.isAfter(now);
    final isPaid = booking.paymentStatus == 'paid';
    final canPay = (isPending || isConfirmed) && !isPaid && !isCancelled;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      (booking.roomImage != null &&
                              booking.roomImage!.isNotEmpty)
                          ? CachedNetworkImage(
                            imageUrl: booking.roomImage!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            // Sử dụng hàm placeholder có sẵn của bạn khi đang tải
                            placeholder: (context, url) => _buildPlaceholder(),
                            // Sử dụng hàm placeholder có sẵn của bạn khi lỗi
                            errorWidget:
                                (context, url, error) => _buildPlaceholder(),
                            // Tối ưu bộ nhớ cho ảnh kích thước 90x90
                            memCacheWidth: 180,
                          )
                          : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hotelName ?? 'Khách sạn không tên',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Dòng loại phòng (Family, Deluxe...)
                      if (booking.roomTypeName != null)
                        Text(
                          booking.roomTypeName!,
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.guestsAdults} người lớn${booking.guestsChildren > 0 ? ', ${booking.guestsChildren} trẻ em' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 12),

            if (booking.roomAmenities.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    booking.roomAmenities.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getAmenityIcon(amenity),
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              amenity,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                StatusChip(
                  label: booking.status,
                  bgColor: statusChipBg(booking.status),
                  textColor: statusChipText(booking.status),
                ),
                const SizedBox(width: 6),
                StatusChip(
                  label: paymentLabel(booking.paymentStatus),
                  bgColor: paymentChipBg(context, booking.paymentStatus),
                  textColor: paymentChipTextColor(booking.paymentStatus),
                ),
              ],
            ),
            const Divider(height: 24),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isDone)
                  ActionChip(
                    avatar: const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.orange,
                    ),
                    label: const Text('Review'),
                    onPressed: onReview,
                  ),
                if (canPay)
                  FilledButton.icon(
                    onPressed: isPaying ? null : onPay,
                    icon:
                        isPaying
                            ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.payment, size: 16),
                    label: Text(isPaying ? 'Paying...' : 'Pay Now'),
                  ),
                if (canCancel)
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                if (canMarkDone)
                  ElevatedButton(
                    onPressed: onMarkDone,
                    child: const Text('Mark Done'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}
