import '../../data/models/booking_model.dart';
import '../../data/booking_api.dart';

class BookingUseCases {
  final BookingApi _api;
  BookingUseCases(this._api);

  Future<List<BookingModel>> getMyBookings() => _api.getMyBookings();

  Future<void> payBooking(String id, String method) =>
      _api.payMock(bookingId: id, method: method, success: true);

  Future<void> cancelBooking(String id) => _api.cancelBooking(id);

  Future<void> markDone(String id) => _api.markBookingDone(id);
}
