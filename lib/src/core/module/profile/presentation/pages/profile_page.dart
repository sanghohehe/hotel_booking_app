import 'package:booking_app/src/core/module/auth/presentation/pages/sign_in_page.dart';
import 'package:booking_app/src/core/module/bookings/presentation/pages/bookings_page.dart';
import 'package:booking_app/src/core/module/favorites/presentation/pages/favorites_page.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';
import 'package:booking_app/src/core/module/profile/domain/entities/profile_entity.dart';
import 'package:booking_app/src/core/module/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';
import '../../../../supabase/supabase_manager.dart';

class ProfilePage extends StatelessWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..loadProfile(email),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Stack(
            children: [
              _buildBackgroundImage(),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh:
                      () => context.read<ProfileCubit>().loadProfile(
                        (state is ProfileLoaded) ? state.profile.email : "",
                      ),
                  child: _buildBody(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProfileLoaded) {
      final profile = state.profile;
      final dateFormat = DateFormat('dd/MM/yyyy');

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            ProfileHeader(
              fullName: profile.fullName,
              email: profile.email,
              avatarUrl: profile.avatarUrl,
              initials: _getInitials(profile.fullName, profile.email),
              onEditTap: () => _onEdit(context, profile),
            ),
            const SizedBox(height: 30),
            ProfileStats(
              bookingCount: state.bookingCount,
              favoriteCount: state.favoriteCount,
              onBookingTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingsPage()),
                );
              },
              onFavoriteTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ProfileInfoCard(
              phoneNumber: profile.phoneNumber ?? 'Not set',
              dob:
                  profile.dateOfBirth != null
                      ? dateFormat.format(profile.dateOfBirth!)
                      : 'Not set',
              address: profile.address ?? 'Not set',
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(context, profile.email),
            const SizedBox(height: 40),
          ],
        ),
      );
    } else if (state is ProfileError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  Widget _buildBackgroundImage() {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hotel_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String email) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.email_outlined,
          title: 'Email',
          trailing: email,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          isDestructive: true,
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  // --- Logic Helpers ---

  String _getInitials(String name, String email) {
    final source = name.isNotEmpty ? name : email;
    final parts = source.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

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

  void _onEdit(BuildContext context, ProfileEntity profile) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => EditProfilePage(
              initialEmail: profile.email,
              initialFullName: profile.fullName,

              initialProfile: UserProfileModel(
                fullName: profile.fullName,
                phoneNumber: profile.phoneNumber,
                address: profile.address,
                avatarUrl: profile.avatarUrl,
                dateOfBirth: profile.dateOfBirth,
                userId: '',
              ),
            ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ProfileCubit>().loadProfile(profile.email);
    }
  }
}
