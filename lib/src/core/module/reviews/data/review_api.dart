import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../supabase/supabase_manager.dart';
import 'models/review_model.dart';

class ReviewApi {
  final SupabaseClient _client = SupabaseManager.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw Exception('Not logged in');
    }
    return id;
  }

  /// Lấy list review của 1 khách sạn (kèm profile)
  Future<List<ReviewModel>> getReviewsForHotel(String hotelId) async {
    final data = await _client
        .from('reviews')
        .select(
          'id, hotel_id, user_id, rating, comment, images, created_at, '
          'profiles:profiles!reviews_user_id_profiles_fkey(full_name, avatar_url)',
        )
        .eq('hotel_id', hotelId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Upload ảnh review lên Storage -> trả về list public url
  Future<List<String>> uploadReviewImages({
    required List<File> files,
    required String hotelId,
  }) async {
    final bucket = _client.storage.from('review_images');
    final userId = _userId;

    final urls = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      // unique name để không cần FileOptions/upsert
      final ext = p.extension(file.path); // ".jpg"
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i$ext';
      final path = 'reviews/$hotelId/$userId/$fileName';

      await bucket.upload(path, file);

      final publicUrl = bucket.getPublicUrl(path);
      urls.add(publicUrl);
    }

    return urls;
  }

  /// Thêm review mới (kèm images)
  Future<ReviewModel> addReview({
    required String hotelId,
    required int rating,
    String? comment,
    List<String>? images,
  }) async {
    final data =
        await _client
            .from('reviews')
            .insert({
              'hotel_id': hotelId,
              'user_id': _userId,
              'rating': rating,
              'comment': comment,
              'images': images,
            })
            .select(
              'id, hotel_id, user_id, rating, comment, images, created_at, '
              'profiles:profiles!reviews_user_id_profiles_fkey(full_name, avatar_url)',
            )
            .single();

    return ReviewModel.fromJson(data as Map<String, dynamic>);
  }
}
