import 'package:booking_app/src/core/module/admin/domain/repositories/i_hotel_repository.dart';

class DeleteRoomUseCase {
  final IHotelRepository repository;
  DeleteRoomUseCase(this.repository);

  Future<void> execute(String roomId) async =>
      await repository.deleteRoomType(roomId);
}
