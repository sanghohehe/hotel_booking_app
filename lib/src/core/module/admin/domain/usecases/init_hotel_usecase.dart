import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';


class InitHotelUseCase {
  List<String> execute(HotelModel hotel) {
    return List<String>.from(hotel.images);
  }
}