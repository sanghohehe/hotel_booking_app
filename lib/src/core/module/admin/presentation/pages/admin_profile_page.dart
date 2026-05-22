// lib/src/core/module/admin/presentation/pages/admin_profile_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../supabase/supabase_manager.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';

class AdminProfilePage extends StatelessWidget {
  final String email;

  const AdminProfilePage({super.key, required this.email});

  Future<void> _logout(BuildContext context) async {
  await SupabaseManager.client.auth.signOut();
  
  // Xóa thông tin đã lưu
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('remember_me');
  await prefs.remove('user_email');
  await prefs.remove('user_password');
  await prefs.remove('user_session');
  
  // Chuyển về màn hình đăng nhập
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const SignInPage()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 12),
          Text(
            'Admin',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 20),
                const SizedBox(width: 8),
                Text('Role: Admin', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
