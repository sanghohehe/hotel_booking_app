import 'package:booking_app/src/core/module/auth/presentation/pages/widget/textFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../../../supabase/supabase_manager.dart';
import '../../../home/presentation/pages/main_shell_page.dart';
import '../../../admin/presentation/pages/admin_home_page.dart';
import '../../../admin/admin_config.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;
  bool _rememberMe = false; // Thêm biến này

  @override
  void initState() {
    super.initState();
    _checkRememberMe(); // Kiểm tra trạng thái lưu khi mở app
  }

  // Hàm kiểm tra xem đã lưu thông tin đăng nhập chưa
  Future<void> _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      // Nếu đã bật "Ghi nhớ", tự động đăng nhập
      final email = prefs.getString('user_email') ?? '';
      final password = prefs.getString('user_password') ?? '';

      if (email.isNotEmpty && password.isNotEmpty) {
        _emailController.text = email;
        _passwordController.text = password;
        _rememberMe = true;
        // Tự động đăng nhập
        await _onSignIn(autoLogin: true);
      }
    }
  }

  // --- LOGIC ĐĂNG NHẬP CẬP NHẬT ---
  Future<void> _onSignIn({bool autoLogin = false}) async {
    if (!autoLogin && !_formKey.currentState!.validate()) return;

    if (!autoLogin) setState(() => _loading = true);

    try {
      final client = SupabaseManager.client;
      final response = await client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;
      if (user == null) throw Exception('Không nhận được thông tin user');

      final email = user.email ?? '';

      // LƯU THÔNG TIN NẾU BẬT REMEMBER ME
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_password', _passwordController.text);
      } else {
        // Xóa thông tin nếu không bật remember me
        await prefs.remove('remember_me');
        await prefs.remove('user_email');
        await prefs.remove('user_password');
      }

      // LƯU SESSION ID (cách khác: dùng supabase tự động lưu session)
      await prefs.setString(
        'user_session',
        response.session?.accessToken ?? '',
      );

      if (!mounted) return;

      final admin = isAdminEmail(email);
      if (admin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AdminHomePage(email: email)),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainShellPage(email: email)),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!autoLogin && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!autoLogin && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đăng nhập: $e')));
      }
    } finally {
      if (!autoLogin && mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.teal;

    return Scaffold(
      body: Stack(
        children: [
          // ... (phần background giữ nguyên) ...
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hotel_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.hotel_class_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Luxury Stay Awaits',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đăng nhập 👋',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'example@gmail.com',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Vui lòng nhập email';
                            if (!value.contains('@'))
                              return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscureText,
                          onSuffixIconPressed:
                              () =>
                                  setState(() => _obscureText = !_obscureText),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Vui lòng nhập mật khẩu';
                            return null;
                          },
                        ),

                        // THÊM CHECKBOX REMEMBER ME
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text(
                              'Ghi nhớ đăng nhập',
                              style: TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _loading
                                    ? null
                                    : () => _onSignIn(autoLogin: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _loading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'ĐĂNG NHẬP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Chưa có tài khoản?",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  ),
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
