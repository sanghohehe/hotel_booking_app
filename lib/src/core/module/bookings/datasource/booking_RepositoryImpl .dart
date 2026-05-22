import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/data/mappers/mappers.dart';
import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';
import 'package:booking_app/src/core/module/bookings/domain/repositories/booking_Repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingApi api;

  BookingRepositoryImpl(this.api);

  @override
  Future<BookingEntity> createBooking({
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required double pricePerNight,
    required DateTime checkOut,
    required int adults,
    required int children,
    String? note,
  }) async {
    try {
      /// 🔥 CALL API (trả về MODEL)
      final model = await api.createBooking(
        hotelId: hotelId,
        roomTypeId: roomId,
        pricePerNight: pricePerNight,
        checkIn: checkIn,
        checkOut: checkOut,
        guestsAdults: adults,
        guestsChildren: children,
        note: note,
      );

      return model.toEntity();
    } catch (e) {
      throw Exception('Create booking failed: $e');
    }
  }
}
