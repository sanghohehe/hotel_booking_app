import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final ValueChanged<String> onSelectSuggestion;
  const WelcomeScreen({super.key, required this.onSelectSuggestion});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      ('🏨', 'Tìm KS Đà Nẵng', 'tìm khách sạn ở Đà Nẵng'),
      ('📋', 'Booking của tôi', 'list_bookings'),
      ('🌟', 'KS 5 sao Hà Nội', 'tìm khách sạn ở Hà Nội'),
      ('🏝️', 'KS Nha Trang', 'tìm khách sạn ở Nha Trang'),
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0A84FF), Color(0xFF34AADC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFF0A84FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.travel_explore, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Xin chào! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tôi có thể giúp bạn tìm khách sạn,\nkiểm tra phòng trống và đặt phòng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 28),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: suggestions.map((s) => InkWell(
                onTap: () => onSelectSuggestion(s.$3),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.$2,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}