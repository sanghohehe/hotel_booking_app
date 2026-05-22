class ChatMessageEntity {
  final String role;
  final String content;
  final String?
  type; // Quan trọng: hotel_search, availability, booking_created...

  final List<dynamic>? hotels; // Danh sách khách sạn
  final List<dynamic>? availability; // Danh sách phòng trống
  final List<dynamic>? bookings; // Danh sách booking
  final dynamic booking; // Thông tin booking đơn lẻ

  ChatMessageEntity({
    required this.role,
    required this.content,
    this.type,
    this.hotels,
    this.availability,
    this.bookings,
    this.booking,
    
  });

  // Helper kiểm tra nhanh
  bool get isHotelSearch => type == 'hotel_search';
  bool get isAvailability => type == 'availability';
  bool get isBookingCreated => type == 'booking_created';
  bool get isBookingsList => type == 'bookings_list';
}
