import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required double pricePerNight,
    String? note,
  });
}
