import 'dart:async';

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

  /// ✅ CHECK ROOM AVAILABILITY
  /// Trả về true nếu phòng CÒN TRỐNG (chưa có booking pending/confirmed)
  Future<bool> isRoomAvailable(
    String hotelId,
    String roomTypeId, {
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final ci = checkIn.toIso8601String().split('T').first;
      final co = checkOut.toIso8601String().split('T').first;

      final data = await _client
          .from('bookings')
          .select('id')
          .eq('hotel_id', hotelId)
          .eq('room_type_id', roomTypeId)
          .or('status.eq.pending,status.eq.confirmed')
          .lt('check_in', co) // check_in < check_out mới
          .gt('check_out', ci) // check_out > check_in mới
          .limit(1);

      return (data as List).isEmpty;
    } catch (e) {
      return true;
    }
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

    // ✅ CHECK TRƯỚC KHI INSERT
    final available = await isRoomAvailable(
      hotelId,
      roomTypeId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    if (!available) {
      throw Exception('Phòng này đã được đặt. Vui lòng chọn phòng khác.');
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

    final booking = BookingModel.fromJson(data as Map<String, dynamic>);

    unawaited(
      _notifyAdmin(
        type: 'new_booking',
        title: '🆕 Booking mới',
        body:
            'Có booking mới tại ${booking.hotelName ?? hotelId} cần xác nhận.',
      ),
    );

    return booking;
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
  Future<void> cancelBooking(String bookingId, {String? hotelName}) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .eq('user_id', _userId)
        .or('status.eq.pending,status.eq.confirmed');

    unawaited(
      _notifyAdmin(
        type: 'booking_cancelled',
        title: '❌ Booking bị hủy',
        body: 'Booking tại ${hotelName ?? bookingId} đã bị user hủy.',
      ),
    );
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

  Future<void> _notifyAdmin({
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': _userId,
        'type': type,
        'title': title,
        'body': body,
        'is_admin_notification': true,
      });
    } catch (e) {}
  }

  Future<bool> hasBookingForHotel(String hotelId) async {
    final data = await _client
        .from('bookings')
        .select('id')
        .eq('user_id', _userId)
        .eq('hotel_id', hotelId)
        .eq('status', 'done')
        .limit(1);
    print('HAS BOOKING: $data, userId: $_userId, hotelId: $hotelId');
    return (data as List).isNotEmpty;
  }

  Future<void> payMock({
    required String bookingId,
    required String method,
    required double finalPrice,
    bool success = true,
  }) async {
    if (success) {
      await _client
          .from('bookings')
          .update({
            'payment_status': 'paid',
            'payment_method': method,
            'paid_at': DateTime.now().toIso8601String(),
            'total_price': finalPrice,
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
