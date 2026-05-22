import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/supabase/supabase_manager.dart';

class AuthTestPage extends StatefulWidget {
  const AuthTestPage({super.key});

  @override
  State<AuthTestPage> createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _status;

  SupabaseClient get _client => SupabaseManager.client;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Vui lòng nhập email & password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
    });

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        // nếu muốn lưu full_name luôn:
        // data: {'full_name': 'Tên test'},
      );

      final user = res.user;
      setState(() {
        _status = user != null
            ? 'Sign up OK: ${user.email}'
            : 'Sign up xong nhưng user null?';
      });
      debugPrint('SIGN UP USER: ${user?.toJson()}');
    } catch (e, s) {
      debugPrint('SIGN UP ERROR: $e\n$s');
      setState(() {
        _status = 'Sign up lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Vui lòng nhập email & password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
    });

    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      setState(() {
        _status = user != null
            ? 'Sign in OK: ${user.email}'
            : 'Sign in xong nhưng user null?';
      });
      debugPrint('SIGN IN USER: ${user?.toJson()}');

      final session = _client.auth.currentSession;
      debugPrint('CURRENT SESSION: ${session?.toJson()}');
    } catch (e, s) {
      debugPrint('SIGN IN ERROR: $e\n$s');
      setState(() {
        _status = 'Sign in lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _status = null;
    });
    try {
      await _client.auth.signOut();
      setState(() {
        _status = 'Đã sign out';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign out lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (currentUser != null)
              Text('Đang đăng nhập: ${currentUser.email}'),
            if (currentUser == null)
              const Text('Chưa đăng nhập'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Sign Out'),
              ),
            ],
            const SizedBox(height: 16),
            if (_status != null)
              Text(
                _status!,
                style: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
