import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../bookings/data/booking_api.dart';
import '../../../../bookings/presentation/pages/booking_confirm_page.dart';

class RoomCard extends StatefulWidget {
  final HotelEntity hotel;
  final dynamic room;

  const RoomCard({super.key, required this.hotel, required this.room});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  // null = đang check, true = còn phòng, false = hết phòng
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      final available = await BookingApi().isRoomAvailable(
        widget.hotel.id,
        widget.room.id as String,
      );
      if (mounted) setState(() => _isAvailable = available);
    } catch (_) {
      // Nếu lỗi → hiện như còn phòng, không block user
      if (mounted) setState(() => _isAvailable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnavailable = _isAvailable == false;
    final isChecking = _isAvailable == null;

    return Opacity(
      // ✅ Làm mờ card khi hết phòng
      opacity: isUnavailable ? 0.65 : 1.0,
      child: Container(
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
          // ✅ Disable tap khi hết phòng hoặc đang check
          onTap:
              (isUnavailable || isChecking)
                  ? null
                  : () => _navigateToConfirm(context),
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

                  // ✅ Badge "Hết phòng" thay badge "Ưu đãi" khi unavailable
                  Positioned(
                    top: 8,
                    left: 8,
                    child:
                        isUnavailable
                            ? _SoldOutBadge()
                            : isChecking
                            ? _CheckingBadge()
                            : _BestDealBadge(theme: theme),
                  ),

                  // ✅ Overlay mờ khi hết phòng
                  if (isUnavailable)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                          child: const Center(
                            child: Icon(
                              Icons.do_not_disturb_alt_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.room.name ?? 'Phòng tiêu chuẩn',
                            style: theme.textTheme.titleMedium?.copyWith(
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
                              'x${widget.room.capacity ?? 0}',
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildFeatureChip(Icons.wifi, 'Free Wifi'),
                        _buildFeatureChip(Icons.ac_unit, 'Điều hòa'),
                        if (widget.room.bedType != null)
                          _buildFeatureChip(
                            Icons.king_bed_outlined,
                            widget.room.bedType!,
                          ),
                      ],
                    ),
                    const Divider(height: 16),
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
                                        '\$${(widget.room.pricePerNight ?? 0).toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isUnavailable
                                              ? Colors.grey
                                              : Colors.green[700],
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

                        // ✅ Nút thay đổi theo trạng thái
                        if (isChecking)
                          const SizedBox(
                            width: 60,
                            height: 32,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else if (isUnavailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Hết phòng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _navigateToConfirm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              minimumSize: const Size(60, 32),
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
      ),
    );
  }

  Widget _buildRoomImage() {
    String? displayImageUrl;

    try {
      if (widget.room.imageUrl != null &&
          widget.room.imageUrl is List &&
          widget.room.imageUrl.isNotEmpty) {
        final first = widget.room.imageUrl.first.toString().trim();
        if (first.isNotEmpty && first.startsWith('http')) {
          displayImageUrl = first;
        }
      }

      if (displayImageUrl == null && widget.hotel.thumbnailUrl != null) {
        final thumb = widget.hotel.thumbnailUrl!.trim();
        if (thumb.isNotEmpty && thumb.startsWith('http')) {
          displayImageUrl = thumb;
        }
      }
    } catch (e) {
      debugPrint('IMAGE PARSE ERROR: $e');
    }

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
      placeholder:
          (context, url) => Container(
            height: 110,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) {
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
        builder:
            (_) =>
                BookingConfirmPage(hotel: widget.hotel, roomType: widget.room),
      ),
    );
  }
}

// ✅ Badge hết phòng
class _SoldOutBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Hết phòng',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ✅ Badge đang kiểm tra
class _CheckingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'Đang kiểm tra',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Badge ưu đãi (giữ nguyên logic cũ)
class _BestDealBadge extends StatelessWidget {
  final ThemeData theme;
  const _BestDealBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
