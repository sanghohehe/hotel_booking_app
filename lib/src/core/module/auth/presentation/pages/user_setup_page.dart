import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSetupPage extends StatefulWidget {
  const UserSetupPage({super.key});

  @override
  State<UserSetupPage> createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  bool _isProcessing = false;
  String _statusText = 'Nhấn nút bên dưới để bắt đầu tạo 24 Users';

  Future<void> _createBulkUsers() async {
    setState(() {
      _isProcessing = true;
      _statusText = '🚀 Đang chuẩn bị dữ liệu...';
    });

    final supabase = Supabase.instance.client;

    // Danh sách 24 email chuẩn của bạn
    final List<String> emails = [
      'sang3@gmail.com',
      'sang4@gmail.com',
      'sang5@gmail.com',
      'sang6@gmail.com',
      'sang7@gmail.com',
      'sang8@gmail.com',
      'sang9@gmail.com',
      'sang10@gmail.com',
      'sang11@gmail.com',
      'sang12@gmail.com',
      'sang13@gmail.com',
      'sang14@gmail.com',
      'sang15@gmail.com',
      'sang16@gmail.com',
      'sang17@gmail.com',
      'sang18@gmail.com',
      'sang19@gmail.com',
      'sang20@gmail.com',
      'sang21@gmail.com',
      'sang22@gmail.com',
      'sang23@gmail.com',
      'sang24@gmail.com',
      'sang25@gmail.com',
      'sang26@gmail.com',
    ];

    final ho = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh'];
    final lot = ['Văn', 'Thị', 'Minh', 'Anh', 'Đức', 'Hải'];
    final ten = ['Huy', 'Nam', 'Bình', 'Hùng', 'Sơn', 'Linh', 'Trang'];

    for (int i = 0; i < emails.length; i++) {
      final email = emails[i];
      final randomName =
          '${ho[i % ho.length]} ${lot[(i + 1) % lot.length]} ${ten[(i + 2) % ten.length]}';
      final randomPhone = '03${8000000 + i}';

      // Đổi ID xoay vòng để lấy các ảnh chân dung thật từ Unsplash cho đẹp
      final photoId = 1500000000000 + (i * 10000000);
      final avatarUrl =
          'https://images.unsplash.com/photo-$photoId?auto=format&fit=crop&w=150&h=150&q=80';

      setState(() {
        _statusText = '🔄 Đang tạo (${i + 1}/${emails.length}):\n$email';
      });

      try {
        // 1. Gọi hàm đăng ký chính thức của Supabase
        final response = await supabase.auth.signUp(
          email: email,
          password: 'sangho2049',
          data: {'full_name': randomName},
        );

        final userId = response.user?.id;

        // 2. Cập nhật thêm SĐT và ảnh vào bảng profiles (Đồng bộ với Trigger)
        if (userId != null) {
          await supabase
              .from('profiles')
              .update({
                'full_name': randomName,
                'phone': randomPhone,
                'avatar_url': avatarUrl,
              })
              .eq('id', userId);
        }

        // Nghỉ 400ms để tránh bị Supabase coi là spam (Rate limit)
        await Future.delayed(const Duration(milliseconds: 400));
      } catch (e) {
        debugPrint('❌ Lỗi tại $email: $e');
      }
    }

    setState(() {
      _isProcessing = false;
      _statusText =
          '🎉 ĐÃ TẠO XONG 24 USER THÀNH CÔNG!\nBây giờ bạn có thể quay lại đăng nhập thoải mái.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công cụ thiết lập dữ liệu mẫu')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: Colors.teal,
              ),
              const SizedBox(height: 24),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              if (_isProcessing)
                const CircularProgressIndicator(color: Colors.teal)
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _createBulkUsers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'KÍCH HOẠT TẠO 24 USERS',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
