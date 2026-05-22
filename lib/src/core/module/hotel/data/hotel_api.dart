import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:diacritic/diacritic.dart';

import '../../../supabase/supabase_manager.dart';
import 'models/hotel_model.dart';

class HotelApi {
  final SupabaseClient _client = SupabaseManager.client;

  String _normalize(String input) {
    return removeDiacritics(input).toLowerCase().trim();
  }

  // =========================================================
  // SAFE CLEAN CORE
  // =========================================================

  List<String> _cleanList(dynamic data) {
    try {
      if (data == null) return [];

      List rawList;

      if (data is List) {
        rawList = data;
      } else if (data is String) {
        rawList = [data];
      } else {
        return [];
      }

      final cleaned =
          rawList
              .where((e) => e != null)
              .expand((e) {
                final value = e.toString();

                // FIX DỮ LIỆU CŨ BỊ "url1,url2"
                if (value.contains(',')) {
                  return value.split(',');
                }

                return [value];
              })
              .map((e) => e.replaceAll('\n', ''))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e.startsWith('http'))
              .toList();

      print('CLEAN LIST => $cleaned');

      return List<String>.from(cleaned);
    } catch (e) {
      print('CLEAN LIST ERROR: $e');
      return [];
    }
  }

  String? _cleanString(String? value) {
    if (value == null) return null;

    final cleaned = value.replaceAll('\n', '').trim();

    if (cleaned.isEmpty) return null;

    return cleaned;
  }

  // =========================================================
  // SELECT
  // =========================================================

  static const String _hotelSelect = '''
    id,
    name,
    city,
    address,
    description,
    star_rating,
    thumbnail_url,
    images,
    room_types(
      id,
      hotel_id,
      name,
      price_per_night,
      capacity,
      bed_type,
      description,
      image_url,
      amenities,
      inventory
    )
  ''';

  // =========================================================
  // GET HOTELS
  // =========================================================

  Future<List<HotelModel>> getHotels({
    double? minRating,
    String? city,
    String? keyword,
    int page = 1,
    int limit = 10,
  }) async {
    final from = (page - 1) * limit;
    final to = from + limit - 1;

    var query = _client.from('hotels').select(_hotelSelect);

    if (minRating != null) {
      query = query.gte('star_rating', minRating);
    }

    if (city != null && city.isNotEmpty) {
      query = query.ilike('city', '%$city%');
    }

    final response = await query.range(from, to);

    return (response as List)
        .map((e) => HotelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =========================================================
  // GET BY IDS
  // =========================================================

  Future<List<HotelModel>> getHotelsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];

      final data = await _client
          .from('hotels')
          .select(_hotelSelect)
          .inFilter('id', ids)
          .order('star_rating', ascending: false);

      return (data as List)
          .map((e) => HotelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('GET HOTELS BY IDS ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // DETAIL
  // =========================================================

  Future<HotelModel> getHotelDetail(String hotelId) async {
    try {
      final data =
          await _client
              .from('hotels')
              .select(_hotelSelect)
              .eq('id', hotelId)
              .single();

      return HotelModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('GET HOTEL DETAIL ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // CREATE HOTEL
  // =========================================================

  Future<HotelModel> createHotel({
    required String name,
    required String city,
    required String address,
    String? description,
    double starRating = 4.0,
    String? thumbnailUrl,
    List<String>? images,
  }) async {
    try {
      final cleanImages = _cleanList(images);

      final payload = <String, dynamic>{
        'name': _cleanString(name),
        'city': _cleanString(city),
        'address': _cleanString(address),
        'star_rating': starRating,

        // FIX QUAN TRỌNG
        'images': cleanImages,
      };

      if (description != null) {
        payload['description'] = _cleanString(description);
      }

      if (thumbnailUrl != null) {
        payload['thumbnail_url'] = _cleanString(thumbnailUrl);
      }

      print('================ CREATE HOTEL ================');
      print(payload);
      print(payload['images'].runtimeType);
      print('================================================');

      final data =
          await _client
              .from('hotels')
              .insert(payload)
              .select(_hotelSelect)
              .single();

      return HotelModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('CREATE HOTEL ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // UPDATE HOTEL
  // =========================================================

  Future<HotelModel> updateHotel({
    required String id,
    String? name,
    String? city,
    String? address,
    String? description,
    double? starRating,
    String? thumbnailUrl,
    List<String>? images,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (name != null) {
        payload['name'] = _cleanString(name);
      }

      if (city != null) {
        payload['city'] = _cleanString(city);
      }

      if (address != null) {
        payload['address'] = _cleanString(address);
      }

      if (description != null) {
        payload['description'] = _cleanString(description);
      }

      if (starRating != null) {
        payload['star_rating'] = starRating;
      }

      if (thumbnailUrl != null) {
        payload['thumbnail_url'] = _cleanString(thumbnailUrl);
      }

      if (images != null) {
        payload['images'] = _cleanList(images);
      }

      print('================ UPDATE HOTEL ================');
      print(payload);
      print('IMAGES TYPE: ${payload['images'].runtimeType}');
      print('IMAGES VALUE: ${payload['images']}');
      print('================================================');

      final data =
          await _client
              .from('hotels')
              .update(payload)
              .eq('id', id)
              .select(_hotelSelect)
              .single();

      return HotelModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('UPDATE HOTEL ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteHotel(String id) async {
    try {
      await _client.from('hotels').delete().eq('id', id);
    } catch (e) {
      print('DELETE HOTEL ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteRoomType(String id) async {
    try {
      await _client.from('room_types').delete().eq('id', id);
    } catch (e) {
      print('DELETE ROOM TYPE ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // ROOM TYPES
  // =========================================================

  Future<List<RoomTypeModel>> getRoomTypesForHotel(String hotelId) async {
    try {
      final data = await _client
          .from('room_types')
          .select()
          .eq('hotel_id', hotelId);

      return (data as List)
          .map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('GET ROOM TYPES ERROR: $e');
      rethrow;
    }
  }

  // =========================================================
  // UPDATE ROOM TYPE
  // =========================================================

  Future<RoomTypeModel> updateRoomType({
    required String id,
    String? name,
    double? pricePerNight,
    int? capacity,
    String? bedType,
    String? description,
    List<String>? imageUrl,
    List<String>? amenities,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (name != null) {
        payload['name'] = _cleanString(name);
      }

      if (pricePerNight != null) {
        payload['price_per_night'] = pricePerNight;
      }

      if (capacity != null) {
        payload['capacity'] = capacity;
      }

      if (bedType != null) {
        payload['bed_type'] = _cleanString(bedType);
      }

      if (description != null) {
        payload['description'] = _cleanString(description);
      }

      if (imageUrl != null) {
        payload['image_url'] = List<String>.from(_cleanList(imageUrl));
      }

      if (amenities != null) {
        payload['amenities'] = List<String>.from(_cleanList(amenities));
      }

      print('================ UPDATE ROOM ================');
      print(payload);
      print('IMAGE_URL TYPE: ${payload['image_url'].runtimeType}');
      print('IMAGE_URL VALUE: ${payload['image_url']}');
      print('================================================');

      final data =
          await _client
              .from('room_types')
              .update(payload)
              .eq('id', id)
              .select()
              .single();

      return RoomTypeModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('UPDATE ROOM ERROR: $e');
      rethrow;
    }
  }

  Future<List<HotelModel>> getAllHotels() async {
    final response = await _client.from('hotels').select(_hotelSelect);
    return (response as List)
        .map((e) => HotelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
