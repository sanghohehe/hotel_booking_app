import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';

class AdminUserState {
  final List<UserProfileModel> users;
  final List<UserProfileModel> filtered;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  AdminUserState({
    this.users = const [],
    this.filtered = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  AdminUserState copyWith({
    List<UserProfileModel>? users,
    List<UserProfileModel>? filtered,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return AdminUserState(
      users: users ?? this.users,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}