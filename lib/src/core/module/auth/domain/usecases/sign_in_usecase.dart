import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repo;

  SignInUseCase(this._repo);

  Future<UserEntity> call({required String email, required String password}) {
    return _repo.signIn(email: email, password: password);
  }
}
