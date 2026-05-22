import 'package:booking_app/src/core/module/hotel/data/hotel_api.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_detail_repository.dart';
import 'package:booking_app/src/core/module/admin/domain/repositories/i_hotel_repository.dart';

import '../../../favorites/data/favorite_api.dart';
import '../../../reviews/data/review_api.dart';
import '../../../bookings/data/booking_api.dart';
import '../../../reviews/data/models/review_model.dart';

// ================= CLEAN HELPERS =================
class _ImageCleaner {
  static String clean(String url) {
    return url.trim().replaceAll('\n', '').replaceAll(' ', '');
  }

  static List<String> cleanList(List<String>? list) {
    if (list == null) return [];
    return list.map(clean).where((e) => e.isNotEmpty).toList();
  }
}

class HotelRepositoryImpl
    implements HotelRepository, HotelDetailRepository, IHotelRepository {
  final HotelApi _api;
  final _supabase = Supabase.instance.client;

  final FavoriteApi _favoriteApi = FavoriteApi();
  final ReviewApi _reviewApi = ReviewApi();
  final BookingApi _bookingApi = BookingApi();

  HotelRepositoryImpl(this._api);

  // ================= USER =================

  @override
  Future<List<HotelEntity>> getHotels({
    double? minRating,
    String? city,
    String? keyword,
    int page = 1,
    int limit = 10,
  }) async {
    final isSearching = keyword != null && keyword.trim().isNotEmpty;

    final models = await _api.getHotels(
      minRating: minRating,
      city: city,
      keyword: null,
      page: isSearching ? 1 : page,
      limit: isSearching ? 200 : limit,
    );

    if (!isSearching) {
      return models.map((m) => m.toEntity()).toList();
    }

    final keywordNormalized = removeDiacritics(keyword!).toLowerCase().trim();

    return models
        .where((hotel) {
          final name = removeDiacritics(hotel.name).toLowerCase();
          final cityName = removeDiacritics(hotel.city).toLowerCase();

          return name.contains(keywordNormalized) ||
              cityName.contains(keywordNormalized);
        })
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<HotelEntity> getHotelDetail(String id) async {
    final model = await _api.getHotelDetail(id);

    return HotelEntity(
      id: model.id,
      name: model.name,
      address: model.address,
      city: model.city,
      starRating: model.starRating,
      description: model.description,
      thumbnailUrl: model.thumbnailUrl,
      images: model.images,
      roomTypes: model.roomTypes,
    );
  }

  @override
  Future<List<ReviewModel>> getReviews(String hotelId) async {
    return await _reviewApi.getReviewsForHotel(hotelId);
  }

  // ================= ADMIN =================

  @override
  Future<List<RoomTypeModel>> getRoomTypes(String hotelId) =>
      _api.getRoomTypesForHotel(hotelId);

  @override
  Future<void> deleteRoomType(String roomId) => _api.deleteRoomType(roomId);

  // ================= SAVE HOTEL =================

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
    List<String> finalImageUrls = _ImageCleaner.cleanList(existingImages);

    for (var file in multipleImages) {
      try {
        final bytes = await file.readAsBytes();
        final fileName = 'hotel_${DateTime.now().microsecondsSinceEpoch}.jpg';

        await _supabase.storage
            .from('hotel-images')
            .uploadBinary(fileName, bytes);

        final rawUrl = _supabase.storage
            .from('hotel-images')
            .getPublicUrl(fileName);

        final cleanUrl = _ImageCleaner.clean(rawUrl);

        finalImageUrls.add(cleanUrl);
      } catch (e) {
        debugPrint('Upload error: $e');
      }
    }

    finalImageUrls = _ImageCleaner.cleanList(finalImageUrls);

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

  // ================= SAVE ROOM =================

  @override
  Future<void> saveRoomType({
    required String hotelId,
    required RoomTypeModel room,
    required List<XFile> newImages,
  }) async {
    List<String> imageUrls = _ImageCleaner.cleanList(room.imageUrl);

    for (var image in newImages) {
      final bytes = await image.readAsBytes();
      final fileName = 'room_${DateTime.now().microsecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('hotel-images')
          .uploadBinary(fileName, bytes);

      final rawUrl = _supabase.storage
          .from('hotel-images')
          .getPublicUrl(fileName);

      imageUrls.add(_ImageCleaner.clean(rawUrl));
    }

    imageUrls = _ImageCleaner.cleanList(imageUrls);

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

  // ================= FAVORITE =================

  @override
  Future<bool> isFavorite(String hotelId) => _favoriteApi.isFavorite(hotelId);

  @override
  Future<void> toggleFavorite(String hotelId, bool isFavorite) async {
    isFavorite
        ? await _favoriteApi.addFavorite(hotelId)
        : await _favoriteApi.removeFavorite(hotelId);
  }

  // ================= REVIEW CHECK =================

  @override
  Future<bool> checkCanReview(String hotelId) =>
      _bookingApi.hasBookingForHotel(hotelId);
}
