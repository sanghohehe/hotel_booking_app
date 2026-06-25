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
          // isRoomAvailable = null → đang loading
        ),
      );

  /// ✅ Gọi ngay khi mở trang BookingConfirmPage
  Future<void> checkAvailability({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    emit(state.copyWith(isRoomAvailable: null));

    try {
      final available = await _repository.isRoomAvailable(
        hotelId,
        roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      emit(state.copyWith(isRoomAvailable: available));
    } catch (e) {
      emit(state.copyWith(isRoomAvailable: true));
    }
  }

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

    // ✅ Guard thêm lần nữa ở cubit trước khi gọi API
    if (state.isUnavailable) {
      emit(
        state.copyWith(
          error: "Phòng này đã được đặt. Vui lòng chọn phòng khác.",
        ),
      );
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
      // ✅ Nếu server trả về lỗi hết phòng, cập nhật state luôn
      final errMsg = e.toString();
      final isRoomTaken = errMsg.contains('đã được đặt');
      emit(
        state.copyWith(
          isLoading: false,
          error: errMsg,
          isRoomAvailable: isRoomTaken ? false : state.isRoomAvailable,
        ),
      );
    }
  }
}
