import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';
import 'package:booking_app/src/core/module/profile/domain/entities/profile_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';
import '../../data/profile_api.dart'; 
import '../../../bookings/data/booking_api.dart';
import '../../../favorites/data/favorite_api.dart';
import '../../../../supabase/supabase_manager.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileApi _profileApi = ProfileApi();
  final BookingApi _bookingApi = BookingApi();
  final _favoriteApi = FavoriteApi();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile(String email) async {
    emit(ProfileLoading());
    try {
      // Chạy song song các API để tối ưu tốc độ
      final results = await Future.wait([
        _profileApi.getMyProfile(),
        _bookingApi.getMyBookingCount(),
        _favoriteApi.getMyFavoriteCount(),
      ]);

      final profileModel = results[0] as UserProfileModel?;
      final bookingCount = results[1] as int;
      final favoriteCount = results[2] as int;

      // Map từ Model sang Entity
      final user = SupabaseManager.client.auth.currentUser;
      final fullName = profileModel?.fullName ?? 
                       (user?.userMetadata?['full_name'] as String?) ?? 'Guest';

      final entity = ProfileEntity(
        fullName: fullName,
        email: email,
        avatarUrl: profileModel?.avatarUrl,
        phoneNumber: profileModel?.phoneNumber,
        dateOfBirth: profileModel?.dateOfBirth,
        address: profileModel?.address,
      );

      emit(ProfileLoaded(
        profile: entity,
        bookingCount: bookingCount,
        favoriteCount: favoriteCount,
      ));
    } catch (e) {
      emit(ProfileError("Không thể tải thông tin cá nhân"));
    }
  }
}