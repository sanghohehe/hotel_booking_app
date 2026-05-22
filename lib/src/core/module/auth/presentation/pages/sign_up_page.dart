import 'package:booking_app/src/core/module/auth/presentation/pages/widget/textFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_manager.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  SupabaseClient get _client => SupabaseManager.client;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final res = await _client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _fullNameController.text.trim()},
      );

      if (res.user == null) throw Exception('Đăng ký thất bại');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng kiểm tra email.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.teal;

    return Scaffold(
      body: Stack(
        children: [
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
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
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
                          'Tạo tài khoản mới',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bắt đầu hành trình trải nghiệm nghỉ dưỡng tuyệt vời.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 32),

                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Họ và tên',
                          hint: 'Nguyễn Văn A',
                          icon: Icons.person_outline,
                          validator:
                              (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'example@gmail.com',
                          icon: Icons.email_outlined,
                          validator:
                              (v) =>
                                  !v!.contains('@')
                                      ? 'Email không hợp lệ'
                                      : null,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscure,
                          onSuffixIconPressed:
                              () => setState(() => _obscure = !_obscure),
                          validator:
                              (v) =>
                                  v!.length < 6
                                      ? 'Mật khẩu tối thiểu 6 ký tự'
                                      : null,
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'ĐĂNG KÝ NGAY',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
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
