import 'package:flutter_bloc/flutter_bloc.dart';
import 'bookings_state.dart';
import '../../domain/usecases/booking_usecases.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final BookingUseCases _useCases;

  BookingsCubit(this._useCases) : super(BookingsInitial());

  // Tải danh sách booking
  Future<void> loadBookings() async {
    // Nếu đang có dữ liệu rồi thì không hiện màn hình loading trắng xóa
    if (state is! BookingsLoaded) {
      emit(BookingsLoading());
    }

    try {
      final data = await _useCases.getMyBookings();
      emit(BookingsLoaded(data));
    } catch (e) {
      emit(BookingsError(e.toString()));
    }
  }

  // Xử lý thanh toán
  Future<void> payBooking(String bookingId, String method) async {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      // Thêm ID vào danh sách đang xử lý để hiện hiệu ứng loading trên nút
      _updateProcessingStatus(bookingId, add: true);

      try {
        await _useCases.payBooking(bookingId, method);
        await loadBookings(); // Reload để lấy trạng thái mới từ Server
      } catch (e) {
        // Có thể emit một Failure state hoặc giữ nguyên list kèm thông báo lỗi
      } finally {
        _updateProcessingStatus(bookingId, add: false);
      }
    }
  }

  // Hủy đặt phòng
  Future<void> cancelBooking(String bookingId) async {
    _updateProcessingStatus(bookingId, add: true);
    try {
      await _useCases.cancelBooking(bookingId);
      await loadBookings();
    } finally {
      _updateProcessingStatus(bookingId, add: false);
    }
  }

  // Đánh dấu hoàn tất
  Future<void> markDone(String bookingId) async {
    _updateProcessingStatus(bookingId, add: true);
    try {
      await _useCases.markDone(bookingId);
      await loadBookings();
    } finally {
      _updateProcessingStatus(bookingId, add: false);
    }
  }

  // Hàm helper để cập nhật trạng thái loading của từng item
  void _updateProcessingStatus(String id, {required bool add}) {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      final newIds = Set<String>.from(currentState.processingIds);
      if (add)
        newIds.add(id);
      else
        newIds.remove(id);
      emit(BookingsLoaded(currentState.bookings, processingIds: newIds));
    }
  }
}
