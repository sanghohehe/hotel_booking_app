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

  /// ✅ Kiểm tra phòng còn trống không
  /// true = còn phòng, false = đã có người đặt
  Future<bool> isRoomAvailable(
    String hotelId,
    String roomTypeId, {
    required DateTime checkIn,
    required DateTime checkOut,
  });
}
