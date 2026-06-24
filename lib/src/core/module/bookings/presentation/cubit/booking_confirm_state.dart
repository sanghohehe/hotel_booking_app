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

    /// ✅ null = đang loading check, true = còn phòng, false = hết phòng
    bool? isRoomAvailable,
  }) = _BookingConfirmState;

  int get nights => checkOut.difference(checkIn).inDays;
  double totalPrice(double pricePerNight) =>
      (nights > 0 ? nights : 0) * pricePerNight;
  int get totalGuests => adults + children;

  /// ✅ Đang kiểm tra availability (chưa có kết quả)
  bool get isCheckingAvailability => isRoomAvailable == null;

  /// ✅ Phòng đã bị đặt
  bool get isUnavailable => isRoomAvailable == false;
}
