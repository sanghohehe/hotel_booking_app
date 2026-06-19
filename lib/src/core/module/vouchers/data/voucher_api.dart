import 'package:booking_app/src/core/supabase/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'voucher_model.dart';

class VoucherApi {
  final SupabaseClient _client = SupabaseManager.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not logged in');
    return id;
  }

  /// Kiểm tra voucher hợp lệ và user chưa dùng
  Future<VoucherModel?> validateVoucher(String code) async {
    final data =
        await _client
            .from('vouchers')
            .select()
            .eq('code', code.toUpperCase().trim())
            .eq('is_active', true)
            .maybeSingle();

    if (data == null) return null;

    final voucher = VoucherModel.fromJson(data as Map<String, dynamic>);

    if (!voucher.isValid) return null;

    // Kiểm tra user đã dùng chưa
    final usage =
        await _client
            .from('voucher_usages')
            .select('id')
            .eq('voucher_id', voucher.id)
            .eq('user_id', _userId)
            .maybeSingle();

    if (usage != null) return null; // đã dùng rồi

    return voucher;
  }

  /// Ghi lại lượt dùng voucher sau khi thanh toán thành công
  Future<void> useVoucher({
    required String voucherId,
    required String bookingId,
  }) async {
    await _client.from('voucher_usages').insert({
      'voucher_id': voucherId,
      'user_id': _userId,
      'booking_id': bookingId,
    });

    // Tăng used_count
    await _client.rpc(
      'increment_voucher_used_count',
      params: {'voucher_id_param': voucherId},
    );
  }

  // ── ADMIN ──

  Future<List<VoucherModel>> getAllVouchers() async {
    final data = await _client
        .from('vouchers')
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => VoucherModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    final data =
        await _client
            .from('vouchers')
            .insert(voucher.toJson())
            .select()
            .single();

    return VoucherModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateVoucher({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    await _client.from('vouchers').update(updates).eq('id', id);
  }

  Future<void> deleteVoucher(String id) async {
    await _client.from('vouchers').delete().eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client.from('vouchers').update({'is_active': isActive}).eq('id', id);
  }
}
