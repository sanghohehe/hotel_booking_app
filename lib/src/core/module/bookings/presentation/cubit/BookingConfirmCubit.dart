import 'package:booking_app/src/core/module/bookings/presentation/cubit/booking_confirm_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/booking_Repository.dart';

class BookingConfirmCubit extends Cubit<BookingConfirmState> {
  final BookingRepository _repository;

  BookingConfirmCubit(this._repository)
    : super(
        BookingConfirmState(
          checkIn: DateTime.now().add(const Duration(days: 1)),
          checkOut: DateTime.now().add(const Duration(days: 2)),
        ),
      );

  void updateDates(DateTime start, DateTime end) {
    emit(state.copyWith(checkIn: start, checkOut: end, error: null));
  }

  void updateGuests(int adults, int children) {
    emit(state.copyWith(adults: adults, children: children));
  }

  void resetStatus() {
    emit(state.copyWith(successBooking: null, error: null));
  }

  Future<void> confirmBooking({
    required String hotelId,
    required String roomId,
    required double pricePerNight,
    required String note,
  }) async {
    if (state.checkOut.difference(state.checkIn).inDays <= 0) {
      emit(state.copyWith(error: "Ngày trả phòng phải sau ngày nhận phòng"));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final booking = await _repository.createBooking(
        hotelId: hotelId,
        roomId: roomId,
        pricePerNight: pricePerNight,
        checkIn: state.checkIn,
        checkOut: state.checkOut,
        adults: state.adults,
        children: state.children,
        note: note,
      );
      emit(state.copyWith(isLoading: false, successBooking: booking));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
