import 'package:image_picker/image_picker.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import '../repositories/i_hotel_repository.dart';

class SaveRoomTypeUseCase {
  final IHotelRepository repository;

  SaveRoomTypeUseCase(this.repository);

  Future<void> execute({
    required String hotelId,
    required RoomTypeModel room,
    required List<XFile> newImages,
  }) {
    return repository.saveRoomType(
      hotelId: hotelId,
      room: room,
      newImages: newImages,
    );
  }
}
