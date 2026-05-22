import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? fullName,
  });
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}
