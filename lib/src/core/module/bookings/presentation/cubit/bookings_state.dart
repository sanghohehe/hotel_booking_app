import '../../data/models/booking_model.dart';

abstract class BookingsState {}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsLoaded extends BookingsState {
  final List<BookingModel> bookings;
  final Set<String> processingIds;

  BookingsLoaded(this.bookings, {this.processingIds = const {}});
}

class BookingsError extends BookingsState {
  final String message;
  BookingsError(this.message);
}
