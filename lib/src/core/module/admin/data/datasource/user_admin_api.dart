import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:booking_app/src/core/supabase/supabase_manager.dart';
import 'package:booking_app/src/core/module/profile/data/user_profile_model.dart';
import 'package:booking_app/src/core/module/bookings/data/models/booking_model.dart';

class UserAdminApi {
  final SupabaseClient _client = SupabaseManager.client;

  Future<List<UserProfileModel>> getAllUsers() async {
    final data = await _client
        .from('user_profiles')
        .select('*')
        .order('updated_at', ascending: false);

    return (data as List)
        .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    final data = await _client
        .from('bookings')
        .select(
          'id, user_id, hotel_id, check_in, check_out, total_price, status, payment_status, '
          'guests_adults, guests_children, payment_method, paid_at, '
          'hotels(name, city), room_types(name, image_url)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String userId) async {
    await _client.from('user_profiles').delete().eq('user_id', userId);
  }
}