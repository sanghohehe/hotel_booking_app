import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app/src/core/module/admin/data/datasource/user_admin_api.dart';
import 'admin_user_state.dart';

class AdminUserCubit extends Cubit<AdminUserState> {
  final UserAdminApi _api;

  AdminUserCubit(this._api) : super(AdminUserState());

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await _api.getAllUsers();
      emit(state.copyWith(
        users: users,
        filtered: users,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void search(String query) {
    final q = query.toLowerCase().trim();
    final filtered = state.users.where((u) {
      return (u.fullName?.toLowerCase().contains(q) ?? false) ||
          (u.phoneNumber?.contains(q) ?? false);
    }).toList();
    emit(state.copyWith(filtered: filtered, searchQuery: query));
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _api.deleteUser(userId);
      final updated = state.users.where((u) => u.userId != userId).toList();
      final filteredUpdated =
          state.filtered.where((u) => u.userId != userId).toList();
      emit(state.copyWith(users: updated, filtered: filteredUpdated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}