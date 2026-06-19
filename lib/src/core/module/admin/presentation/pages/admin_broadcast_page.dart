import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../supabase/supabase_manager.dart';

class AdminBroadcastPage extends StatefulWidget {
  const AdminBroadcastPage({super.key});

  @override
  State<AdminBroadcastPage> createState() => _AdminBroadcastPageState();
}

class _AdminBroadcastPageState extends State<AdminBroadcastPage> {
  final _client = SupabaseManager.client;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'promotion';
  bool _sending = false;

  final _types = const [
    _NotifType(
      value: 'promotion',
      label: 'Khuyến mãi',
      icon: Icons.local_offer,
      color: Colors.orange,
    ),
    _NotifType(
      value: 'system',
      label: 'Hệ thống',
      icon: Icons.settings,
      color: Colors.blue,
    ),
    _NotifType(
      value: 'update',
      label: 'Cập nhật',
      icon: Icons.system_update,
      color: Colors.green,
    ),
  ];

  _NotifType get _selectedType => _types.firstWhere((t) => t.value == _type);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Xem trước thông báo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedType.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedType.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _selectedType.icon,
                          color: _selectedType.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleCtrl.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _bodyCtrl.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedType.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _selectedType.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _selectedType.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thông báo này sẽ được gửi đến TẤT CẢ người dùng trong hệ thống.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType.color,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Gửi ngay'),
              ),
            ],
          ),
    );

    if (confirmed == true) await _send();
  }

  Future<void> _send() async {
    setState(() => _sending = true);

    try {
      // Lấy tất cả user_id
      final usersRaw = await _client.from('user_profiles').select('user_id');

      final userIds =
          (usersRaw as List)
              .map((e) => (e as Map)['user_id']?.toString())
              .whereType<String>()
              .toList();

      if (userIds.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có user nào trong hệ thống.')),
        );
        return;
      }

      // Insert 1 row cho mỗi user
      final rows =
          userIds
              .map(
                (uid) => {
                  'user_id': uid,
                  'type': _type,
                  'title': _titleCtrl.text.trim(),
                  'body': _bodyCtrl.text.trim(),
                  'is_admin_notification': false,
                },
              )
              .toList();

      // Gửi theo batch 50 để tránh timeout
      const batchSize = 50;
      for (int i = 0; i < rows.length; i += batchSize) {
        final batch = rows.sublist(i, (i + batchSize).clamp(0, rows.length));
        await _client.from('notifications').insert(batch);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã gửi đến ${userIds.length} người dùng!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() => _type = 'promotion');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gửi thông báo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loại thông báo
              Text(
                'Loại thông báo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children:
                    _types.map((t) {
                      final selected = _type == t.value;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = t.value),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: t != _types.last ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? t.color : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? t.color : Colors.grey[300]!,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  t.icon,
                                  color: selected ? Colors.white : t.color,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        selected
                                            ? Colors.white
                                            : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Tiêu đề
              Text(
                'Tiêu đề',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề thông báo...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Vui lòng nhập tiêu đề'
                            : null,
              ),

              const SizedBox(height: 16),

              // Nội dung
              Text(
                'Nội dung',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung thông báo...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Vui lòng nhập nội dung'
                            : null,
              ),

              const SizedBox(height: 24),

              // Nút gửi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _sending ? null : _preview,
                  icon:
                      _sending
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Text(
                    _sending ? 'Đang gửi...' : 'Xem trước & Gửi',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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

class _NotifType {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _NotifType({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}
