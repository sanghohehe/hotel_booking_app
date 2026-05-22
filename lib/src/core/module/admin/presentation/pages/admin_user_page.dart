import 'package:booking_app/src/core/module/admin/presentation/pages/admin_user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app/src/core/module/admin/data/datasource/user_admin_api.dart';
import 'package:booking_app/src/core/module/admin/presentation/cubit/admin_user_cubit.dart';
import 'package:booking_app/src/core/module/admin/presentation/cubit/admin_user_state.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';

class AdminUserPage extends StatelessWidget {
  const AdminUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUserCubit(UserAdminApi())..loadUsers(),
      child: const _AdminUserView(),
    );
  }
}

class _AdminUserView extends StatefulWidget {
  const _AdminUserView();

  @override
  State<_AdminUserView> createState() => _AdminUserViewState();
}

class _AdminUserViewState extends State<_AdminUserView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AdminUserCubit, AdminUserState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng số người dùng',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.users.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => context.read<AdminUserCubit>().search(val),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên hoặc số điện thoại...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchCtrl.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      context.read<AdminUserCubit>().search('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AdminUserCubit, AdminUserState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<AdminUserCubit>().loadUsers(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  state.searchQuery.isEmpty
                      ? 'Chưa có người dùng nào'
                      : 'Không tìm thấy kết quả',
                  style: TextStyle(color: Colors.grey[500], fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<AdminUserCubit>().loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.filtered.length,
            itemBuilder:
                (context, index) =>
                    _buildUserCard(context, state.filtered[index]),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfileModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap:
            () => Navigator.push(
              
              context,
              MaterialPageRoute(
                builder: (_) => AdminUserDetailPage(user: user),
              ),
            ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue[50],
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child:
              user.avatarUrl == null
                  ? Text(
                    (user.fullName?.isNotEmpty == true)
                        ? user.fullName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  )
                  : null,
        ),
        title: Text(
          user.fullName ?? 'Chưa cập nhật tên',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (user.phoneNumber != null)
              Row(
                children: [
                  Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    user.phoneNumber!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            if (user.address != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user.address!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, user),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserProfileModel user) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xóa người dùng'),
            content: Text(
              'Bạn có chắc muốn xóa "${user.fullName ?? 'người dùng này'}" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminUserCubit>().deleteUser(user.userId);
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
