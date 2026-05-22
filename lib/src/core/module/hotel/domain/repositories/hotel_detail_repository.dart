import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/reviews/data/models/review_model.dart';

abstract class HotelDetailRepository {
  Future<HotelEntity> getHotelDetail(String id);
  Future<bool> isFavorite(String hotelId);
  Future<void> toggleFavorite(String hotelId, bool isFavorite);
  Future<List<ReviewModel>> getReviews(String hotelId);
  Future<bool> checkCanReview(String hotelId);
}
