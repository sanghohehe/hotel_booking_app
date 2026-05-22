import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';

import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> call({
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int maxCapacity,
    required double pricePerNight,
    String? note,
  }) async {
    if (!checkOut.isAfter(checkIn)) {
      throw Exception('Check-out phải sau check-in ít nhất 1 đêm');
    }

    final nights = checkOut.difference(checkIn).inDays;

    if (nights <= 0) {
      throw Exception('Số đêm không hợp lệ');
    }

    if (adults <= 0) {
      throw Exception('Phải có ít nhất 1 người lớn');
    }

    final totalGuests = adults + children;

    if (totalGuests > maxCapacity) {
      throw Exception('Vượt quá số khách cho phép ($maxCapacity)');
    }

    final totalPrice = nights * pricePerNight;

    final booking = await repository.createBooking(
      hotelId: hotelId,
      roomId: roomId,
      pricePerNight: pricePerNight,
      checkIn: checkIn,
      checkOut: checkOut,
      adults: adults,
      children: children,
      note: note,
    );

    return booking.copyWith(totalPrice: totalPrice, nights: nights);
  }
}
