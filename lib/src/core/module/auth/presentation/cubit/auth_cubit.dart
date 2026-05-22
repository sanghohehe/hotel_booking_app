import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final AuthRepository _repo;

  AuthCubit({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required AuthRepository repo,
  }) : _signIn = signIn,
       _signUp = signUp,
       _signOut = signOut,
       _repo = repo,
       super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _signIn(email: email, password: password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp(String email, String password, String? fullName) async {
    emit(AuthLoading());
    try {
      final user = await _signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
