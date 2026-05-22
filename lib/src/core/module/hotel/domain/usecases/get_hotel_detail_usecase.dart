import '../entities/hotel_entity.dart';
import '../repositories/hotel_detail_repository.dart';

class GetHotelDetailUseCase {
  final HotelDetailRepository repository;

  GetHotelDetailUseCase(this.repository);

  Future<HotelEntity> execute(String hotelId) {
    return repository.getHotelDetail(hotelId);
  }
}