import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repo;

  SignUpUseCase(this._repo);

  Future<UserEntity> call({
    required String email,
    required String password,
    String? fullName,
  }) {
    return _repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
