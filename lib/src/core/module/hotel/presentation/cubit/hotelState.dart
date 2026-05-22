import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';

abstract class HotelState {}

// INIT
class HotelInitial extends HotelState {}

// LOADING
class HotelLoading extends HotelState {}

// LOAD THƯỜNG (có thể giữ nếu bạn dùng chỗ khác)
class HotelLoaded extends HotelState {
  final List<HotelEntity> hotels;

  HotelLoaded(this.hotels);
}

// ERROR
class HotelError extends HotelState {
  final String message;

  HotelError(this.message);
}

// ✅ PAGINATION (DÙNG CHÍNH)
class HotelLoadedWithPagination extends HotelState {
  final List<HotelEntity> hotels;
  final int currentPage;
  final int totalPages;

  HotelLoadedWithPagination({
    required this.hotels,
    required this.currentPage,
    required this.totalPages,
  });
}
