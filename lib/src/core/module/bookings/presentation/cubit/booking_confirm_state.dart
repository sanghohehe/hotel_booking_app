import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/bookingEntity .dart';

part 'booking_confirm_state.freezed.dart';

@freezed
class BookingConfirmState with _$BookingConfirmState {
  const BookingConfirmState._(); // Bắt buộc có để sử dụng getter

  const factory BookingConfirmState({
    @Default(false) bool isLoading,
    required DateTime checkIn,
    required DateTime checkOut,
    @Default(2) int adults,
    @Default(0) int children,
    String? error,
    BookingEntity? successBooking,
  }) = _BookingConfirmState;

  // Đưa logic tính toán vào State để UI không phải xử lý
  int get nights => checkOut.difference(checkIn).inDays;
  double totalPrice(double pricePerNight) =>
      (nights > 0 ? nights : 0) * pricePerNight;
  int get totalGuests => adults + children;
}
