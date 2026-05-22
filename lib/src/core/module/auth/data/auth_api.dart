import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_manager.dart';

class AuthApi {
  final SupabaseClient _client = SupabaseManager.client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null) 'full_name': fullName,
      },
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
