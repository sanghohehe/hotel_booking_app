import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../supabase/supabase_manager.dart';
import 'models/booking_model.dart';

class BookingApi {
  final SupabaseClient _client = SupabaseManager.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not logged in');
    return id;
  }

  /// 🔥 CREATE BOOKING (CLEAN VERSION)
  Future<BookingModel> createBooking({
    required String hotelId,
    required String roomTypeId,
    required double pricePerNight,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestsAdults,
    required int guestsChildren,
    String? note,
  }) async {
    final nights = checkOut.difference(checkIn).inDays;
    if (nights <= 0) {
      throw Exception('Check-out phải sau check-in ít nhất 1 ngày');
    }

    final totalPrice = pricePerNight * nights;

    final data =
        await _client
            .from('bookings')
            .insert({
              'user_id': _userId,
              'hotel_id': hotelId,
              'room_type_id': roomTypeId,
              'check_in': checkIn.toIso8601String().split('T').first,
              'check_out': checkOut.toIso8601String().split('T').first,
              'total_price': totalPrice,
              'status': 'pending',
              'payment_status': 'pending',
              'guests_adults': guestsAdults,
              'guests_children': guestsChildren,
              if (note != null && note.isNotEmpty) 'note': note,
            })
            .select(
              'id, user_id, hotel_id, check_in, check_out, total_price, status, payment_status, '
              'guests_adults, guests_children, payment_method, paid_at, '
              'hotels(name, city), room_types(name)',
            )
            .single();

    return BookingModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET BOOKINGS
  Future<List<BookingModel>> getMyBookings() async {
    final data = await _client
        .from('bookings')
        .select(
          'id, user_id, hotel_id, check_in, check_out, total_price, status, payment_status, '
          'guests_adults, guests_children, payment_method, paid_at, '
          'hotels(name, city), room_types(name,image_url,room_type_amenities(amenities(name)))',
        )
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// CANCEL
  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .eq('user_id', _userId)
        .or('status.eq.pending,status.eq.confirmed');
  }

  /// DONE
  Future<void> markBookingDone(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'done'})
        .eq('id', bookingId)
        .eq('user_id', _userId)
        .eq('status', 'confirmed');
  }

  /// ADMIN CONFIRM
  Future<void> adminConfirmBooking({required String bookingId}) async {
    await _client
        .from('bookings')
        .update({'status': 'confirmed'})
        .eq('id', bookingId)
        .eq('status', 'pending');
  }

  Future<int> getMyBookingCount() async {
    final data = await _client
        .from('bookings')
        .select('id')
        .eq('user_id', _userId);
    return (data as List).length;
  }

  Future<bool> hasBookingForHotel(String hotelId) async {
    final data = await _client
        .from('bookings')
        .select('id')
        .eq('user_id', _userId)
        .eq('hotel_id', hotelId)
        .eq('status', 'done')
        .limit(1);

    return (data as List).isNotEmpty;
  }

  Future<void> payMock({
    required String bookingId,
    required String method,
    bool success = true,
  }) async {
    if (success) {
      await _client
          .from('bookings')
          .update({
            'payment_status': 'paid',
            'payment_method': method,
            'paid_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .eq('user_id', _userId);
    } else {
      await _client
          .from('bookings')
          .update({'payment_status': 'failed', 'payment_method': method})
          .eq('id', bookingId)
          .eq('user_id', _userId);
    }
  }
}
