import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_detail_repository.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_state.dart';
import 'package:booking_app/src/core/module/reviews/data/models/review_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelDetailCubit extends Cubit<HotelDetailState> {
  final HotelDetailRepository repository;

  HotelDetailCubit(this.repository) : super(const HotelDetailState());

  Future<void> loadHotelDetail(String hotelId) async {
    emit(state.copyWith(status: HotelDetailStatus.loading));

    try {
      final results = await Future.wait([
        repository.getHotelDetail(hotelId), // results[0] -> HotelEntity
        repository.isFavorite(hotelId), // results[1] -> bool
        repository.getReviews(hotelId), // results[2] -> List<ReviewModel>
        repository.checkCanReview(hotelId), // results[3] -> bool
      ]);

      emit(
        state.copyWith(
          status: HotelDetailStatus.success,
          // Ép kiểu cụ thể cho từng vị trí trong List
          hotel: results[0] as HotelEntity?,
          isFavorite: results[1] as bool,
          reviews: results[2] as List<ReviewModel>,
          canReview: results[3] as bool,
          loadingReviews: false,
          checkingCanReview: false,
        ),
      );
    } catch (e) {
      // 3. Thất bại
      emit(
        state.copyWith(
          status: HotelDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> toggleFavorite(String hotelId) async {
    if (state.hotel == null) return;

    final oldFavStatus = state.isFavorite;
    final newFavStatus = !oldFavStatus;

    emit(state.copyWith(isFavorite: newFavStatus, favLoading: true));

    try {
      await repository.toggleFavorite(hotelId, newFavStatus);
      emit(state.copyWith(favLoading: false));
    } catch (e) {
      emit(state.copyWith(isFavorite: oldFavStatus, favLoading: false));
    }
  }
}
