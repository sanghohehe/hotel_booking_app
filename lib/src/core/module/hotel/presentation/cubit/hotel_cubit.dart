import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotelState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelCubit extends Cubit<HotelState> {
  final HotelRepository _repository;

  HotelCubit(this._repository) : super(HotelInitial());

  int _page = 1;
  final int _limit = 10;

  // 👉 giả lập total page (vì không dùng count nữa)
  final int _totalPages = 5;

  Future<void> fetchHotels({
    double? minRating,
    String? city,
    String? keyword,
    int page = 1,
  }) async {
    emit(HotelLoading());

    try {
      _page = page;

      final hotels = await _repository.getHotels(
        minRating: minRating,
        city: city,
        keyword: keyword,
        page: _page,
        limit: _limit,
      );

      emit(
        HotelLoadedWithPagination(
          hotels: hotels,
          currentPage: _page,
          totalPages: _totalPages,
        ),
      );
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }
}
