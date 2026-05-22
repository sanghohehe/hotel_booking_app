import '../../domain/entities/hotel_entity.dart';
import '../../../reviews/data/models/review_model.dart';

enum HotelDetailStatus { initial, loading, success, failure }

class HotelDetailState {
  final HotelDetailStatus status;
  final HotelEntity? hotel;
  final List<ReviewModel> reviews;

  final bool isFavorite;
  final bool favLoading;
  final bool canReview; 
  final bool checkingCanReview; 
  final bool loadingReviews; 

  final String? errorMessage;

  const HotelDetailState({
    this.status = HotelDetailStatus.initial,
    this.hotel,
    this.reviews = const [],
    this.isFavorite = false,
    this.favLoading = false,
    this.canReview = false,
    this.checkingCanReview = true,
    this.loadingReviews = true,
    this.errorMessage,
  });

  // Helper getters
  bool get isLoading => status == HotelDetailStatus.loading;
  double get avgRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (prev, e) => prev + e.rating);
    return sum / reviews.length;
  }

  HotelDetailState copyWith({
    HotelDetailStatus? status,
    HotelEntity? hotel,
    List<ReviewModel>? reviews,
    bool? isFavorite,
    bool? favLoading,
    bool? canReview,
    bool? checkingCanReview,
    bool? loadingReviews,
    String? errorMessage,
  }) {
    return HotelDetailState(
      status: status ?? this.status,
      hotel: hotel ?? this.hotel,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      favLoading: favLoading ?? this.favLoading,
      canReview: canReview ?? this.canReview,
      checkingCanReview: checkingCanReview ?? this.checkingCanReview,
      loadingReviews: loadingReviews ?? this.loadingReviews,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
