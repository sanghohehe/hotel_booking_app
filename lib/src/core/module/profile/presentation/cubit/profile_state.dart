import 'package:booking_app/src/core/module/profile/domain/entities/profile_entity.dart';


abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final int bookingCount;
  final int favoriteCount;

  ProfileLoaded({
    required this.profile,
    required this.bookingCount,
    required this.favoriteCount,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}