import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';

import '../repositories/i_hotel_repository.dart';

class LoadRoomsUseCase {
  final IHotelRepository repository;

  LoadRoomsUseCase(this.repository);

  Future<List<RoomTypeModel>> execute(String hotelId) {
    return repository.getRoomTypes(hotelId);
  }
}