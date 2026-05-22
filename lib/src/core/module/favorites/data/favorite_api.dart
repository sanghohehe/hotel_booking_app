import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../supabase/supabase_manager.dart';

class FavoriteApi {
  final SupabaseClient _client = SupabaseManager.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw Exception('Not logged in');
    }
    return id;
  }

  /// Lấy danh sách hotel_id mà user đã yêu thích
  Future<Set<String>> getMyFavoriteHotelIds() async {
    final data = await _client
        .from('favorites')
        .select('hotel_id')
        .eq('user_id', _userId);

    final list = (data as List).map((e) => e['hotel_id'] as String).toSet();

    return list;
  }

  /// Đếm số khách sạn yêu thích
  Future<int> getMyFavoriteCount() async {
    final ids = await getMyFavoriteHotelIds();
    return ids.length;
  }

  /// Kiểm tra 1 hotel có đang là favorite không
  Future<bool> isFavorite(String hotelId) async {
    final data =
        await _client
            .from('favorites')
            .select('id')
            .eq('user_id', _userId)
            .eq('hotel_id', hotelId)
            .maybeSingle();

    return data != null;
  }

  /// Thêm vào favorites
  Future<void> addFavorite(String hotelId) async {
    await _client.from('favorites').insert({
      'user_id': _userId,
      'hotel_id': hotelId,
    });
  }

  /// Xoá khỏi favorites
  Future<void> removeFavorite(String hotelId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', _userId)
        .eq('hotel_id', hotelId);
  }
}
