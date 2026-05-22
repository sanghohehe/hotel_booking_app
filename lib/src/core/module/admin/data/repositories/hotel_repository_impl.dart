import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_detail_repository.dart';
import 'package:booking_app/src/core/module/admin/domain/repositories/i_hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/data/hotel_api.dart';
import 'package:booking_app/src/core/module/reviews/data/models/review_model.dart'; // Đảm bảo đúng path
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HotelRepositoryImpl
    implements HotelRepository, HotelDetailRepository, IHotelRepository {
  final HotelApi _api;
  final _supabase = Supabase.instance.client;

  HotelRepositoryImpl(this._api);

  @override
  Future<List<HotelEntity>> getHotels({
    double? minRating,
    String? city,
    String? keyword,
    int page = 1,
    int limit = 10,
  }) async {
    final models = await _api.getHotels(
      minRating: minRating,
      city: city,
      keyword: keyword,
      page: page,
      limit: limit,
    );

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<HotelEntity> getHotelDetail(String id) async {
    final model = await _api.getHotelDetail(id);
    print("HOTEL IMAGES: ${model.images}");

    return model.toEntity();
  }

  @override
  Future<bool> isFavorite(String hotelId) async {
    return false;
  }

  @override
  Future<void> toggleFavorite(String hotelId, bool isFavorite) async {}

  @override
  Future<List<ReviewModel>> getReviews(String hotelId) async {
    return [];
  }

  @override
  Future<bool> checkCanReview(String hotelId) async {
    return true;
  }

  @override
  Future<List<String>> saveHotel({
    required HotelModel? existingHotel,
    required String name,
    required String city,
    required String address,
    String? description,
    required double starRating,
    required List<XFile> multipleImages,
    required List<String> existingImages,
  }) async {
    List<String> finalImageUrls = List<String>.from(existingImages);

    // Upload các ảnh mới chọn thêm
    for (var file in multipleImages) {
      final bytes = await file.readAsBytes();
      final fileName = 'hotel_${DateTime.now().microsecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('hotel-images')
          .uploadBinary(fileName, bytes);

      final url = _supabase.storage.from('hotel-images').getPublicUrl(fileName);

      finalImageUrls.add(url.trim().replaceAll('\n', ''));
    }

    if (existingHotel == null) {
      await _api.createHotel(
        name: name,
        city: city,
        address: address,
        description: description,
        starRating: starRating,
        images: finalImageUrls,
      );
    } else {
      await _api.updateHotel(
        id: existingHotel.id,
        name: name,
        city: city,
        address: address,
        description: description,
        starRating: starRating,
        images: finalImageUrls,
      );
    }

    return finalImageUrls;
  }

  @override
  Future<List<RoomTypeModel>> getRoomTypes(String hotelId) async {
    return await _api.getRoomTypesForHotel(hotelId);
  }

  @override
  Future<void> deleteRoomType(String roomId) async {
    await _api.deleteRoomType(roomId);
  }

  @override
  Future<void> saveRoomType({
    required String hotelId,
    required RoomTypeModel room,
    required List<XFile> newImages,
  }) async {
    List<String> imageUrls = List<String>.from(room.imageUrl);

    for (var image in newImages) {
      final bytes = await image.readAsBytes();
      final fileName = 'room_${DateTime.now().microsecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('hotel-images')
          .uploadBinary(fileName, bytes);

      imageUrls.add(
        _supabase.storage.from('hotel-images').getPublicUrl(fileName),
      );
    }

    await _api.updateRoomType(
      id: room.id,
      name: room.name,
      pricePerNight: room.pricePerNight,
      capacity: room.capacity,
      bedType: room.bedType,
      description: room.description,
      imageUrl: imageUrls,
      amenities: room.amenities,
    );
  }
}
