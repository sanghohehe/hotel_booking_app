import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class IHotelRepository {
  Future<List<RoomTypeModel>> getRoomTypes(String hotelId);

  Future<List<String>> saveHotel({
    required HotelModel? existingHotel,
    required String name,
    required String city,
    required String address,
    String? description,
    required double starRating,
    required List<XFile> multipleImages,
    required List<String> existingImages,
  });

  Future<void> deleteRoomType(String roomId);

  Future<void> saveRoomType({
    required String hotelId,
    required RoomTypeModel room,
    required List<XFile> newImages,
  });
}
