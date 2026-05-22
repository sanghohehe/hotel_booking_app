import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHotelApi {
  final _client = Supabase.instance.client;

  Future<HotelModel> createHotel({
    required String name,
    required String city,
    required String address,
    String? description,
    double starRating = 4.0,
    String? thumbnailUrl,
  }) async {
    final res =
        await _client
            .from('hotels')
            .insert({
              'name': name,
              'city': city,
              'address': address,
              'description': description,
              'star_rating': starRating,
              'thumbnail_url': thumbnailUrl?.trim().replaceAll('\n', ''),
              'images': thumbnailUrl != null ? [thumbnailUrl] : [],
            })
            .select()
            .single();
    return HotelModel.fromJson(res);
  }

  Future<HotelModel> updateHotel({
    required String id,
    required String name,
    required String city,
    required String address,
    String? description,
    double starRating = 4.0,
    String? thumbnailUrl,
  }) async {
    final res =
        await _client
            .from('hotels')
            .update({
              'name': name,
              'city': city,
              'address': address,
              'description': description,
              'star_rating': starRating,
              'thumbnail_url': thumbnailUrl?.trim().replaceAll('\n', ''),
              'images': thumbnailUrl != null ? [thumbnailUrl] : [],
            })
            .eq('id', id)
            .select()
            .single();
    return HotelModel.fromJson(res);
  }

  Future<List<RoomTypeModel>> getRoomTypesForHotel(String hotelId) async {
    final res = await _client
        .from('room_types')
        .select()
        .eq('hotel_id', hotelId);
    return (res as List).map((e) => RoomTypeModel.fromJson(e)).toList();
  }

  Future<void> deleteRoomType(String id) async =>
      await _client.from('room_types').delete().eq('id', id);
}
