import '../../domain/entities/hotel_entity.dart';
import '../../domain/repositories/hotel_detail_repository.dart';
import '../../data/hotel_api.dart';
import '../../../favorites/data/favorite_api.dart';
import '../../../reviews/data/review_api.dart';
import '../../../bookings/data/booking_api.dart';
import '../../../reviews/data/models/review_model.dart';

class HotelDetailRepositoryImpl implements HotelDetailRepository {
  final _hotelApi = HotelApi();
  final _favoriteApi = FavoriteApi();
  final _reviewApi = ReviewApi();
  final _bookingApi = BookingApi();

  @override
  Future<HotelEntity> getHotelDetail(String hotelId) async {
    final model = await _hotelApi.getHotelDetail(hotelId);

    return HotelEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      address: model.address,
      city: model.city,
      starRating: model.starRating,
      thumbnailUrl: model.thumbnailUrl,
      roomTypes: model.roomTypes, 
    );
  }

  @override
  Future<bool> isFavorite(String hotelId) async {
    return await _favoriteApi.isFavorite(hotelId);
  }

  @override
  Future<void> toggleFavorite(String hotelId, bool isCurrentlyFavorite) async {
    if (isCurrentlyFavorite) {
      await _favoriteApi.addFavorite(hotelId);
    } else {
      await _favoriteApi.removeFavorite(hotelId);
    }
  }

  @override
  Future<List<ReviewModel>> getReviews(String hotelId) async {
    return await _reviewApi.getReviewsForHotel(hotelId);
  }

  @override
  Future<bool> checkCanReview(String hotelId) async {
    return await _bookingApi.hasBookingForHotel(hotelId);
  }
}
