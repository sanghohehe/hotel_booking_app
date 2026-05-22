import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';

abstract class HotelRepository {
  Future<List<HotelEntity>> getHotels({
    double? minRating,
    String? city,
    String? keyword,
    int page,
    int limit,
  });
}
