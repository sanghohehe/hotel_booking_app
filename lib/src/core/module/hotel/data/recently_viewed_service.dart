import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';

class RecentlyViewedService {
  static const _key = 'recently_viewed_hotels';
  static const _maxItems = 5;

  // Lưu khách sạn vừa xem
  static Future<void> saveHotel(HotelEntity hotel) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];

    // Convert hotel thành JSON string
    final hotelJson = jsonEncode({
      'id': hotel.id,
      'name': hotel.name,
      'city': hotel.city,
      'address': hotel.address,
      'starRating': hotel.starRating,
      'thumbnailUrl': hotel.thumbnailUrl,
      'description': hotel.description,
      'images': hotel.images,
      'roomTypes': (hotel.roomTypes)
          .whereType<RoomTypeModel>()
          .map((r) => r.toJson())
          .toList(),
    });

    // Xóa nếu đã tồn tại (tránh trùng)
    stored.removeWhere((e) {
      try {
        return jsonDecode(e)['id'] == hotel.id;
      } catch (_) {
        return false;
      }
    });

    // Thêm vào đầu danh sách
    stored.insert(0, hotelJson);

    // Giữ tối đa _maxItems
    final trimmed = stored.take(_maxItems).toList();

    await prefs.setStringList(_key, trimmed);
  }

  // Đọc danh sách khách sạn đã xem
  static Future<List<HotelEntity>> getHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];

    return stored.map((e) {
      try {
        final map = jsonDecode(e) as Map<String, dynamic>;
        return HotelEntity(
          id: map['id'],
          name: map['name'],
          city: map['city'],
          address: map['address'],
          starRating: (map['starRating'] as num).toDouble(),
          thumbnailUrl: map['thumbnailUrl'],
          description: map['description'],
          images: List<String>.from(map['images'] ?? []),
          roomTypes: ((map['roomTypes'] as List?) ?? [])
              .map((r) => RoomTypeModel.fromJson(r as Map<String, dynamic>))
              .toList(),
        );
      } catch (_) {
        return null;
      }
    }).whereType<HotelEntity>().toList();
  }

  // Xóa toàn bộ lịch sử
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}