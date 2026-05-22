import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_api.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;

  AuthRepositoryImpl(this._api);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _api.currentUser;
    if (user == null) return null;

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _api.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign up failed: user is null');
    }

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? fullName,
    );
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _api.signInWithEmail(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign in failed: user is null');
    }

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }

  @override
  Future<void> signOut() async {
    await _api.signOut();
  }
}
