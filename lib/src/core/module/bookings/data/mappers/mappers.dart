import 'package:booking_app/src/core/module/bookings/domain/entities/bookingEntity%20.dart';

import '../models/booking_model.dart';

extension BookingMapper on BookingModel {
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      checkIn: checkIn,
      checkOut: checkOut,
      totalPrice: totalPrice,
      status: status,
      paymentStatus: paymentStatus,
      guestsAdults: guestsAdults,
      guestsChildren: guestsChildren,
      hotelId: hotelId,
      hotelName: hotelName,
      hotelCity: hotelCity,
      roomTypeName: roomTypeName,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
  }
}
