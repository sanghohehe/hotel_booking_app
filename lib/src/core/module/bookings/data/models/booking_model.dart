class BookingModel {
  final String id;
  final String? userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final int guestsAdults;
  final int guestsChildren;

  final String? hotelId;
  final String? hotelName;
  final String? hotelCity;
  final String? roomTypeName;
  final String? roomImage;
  final List<String> roomAmenities;
  final String? paymentMethod;
  final DateTime? paidAt;

  BookingModel({
    required this.id,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.guestsAdults,
    required this.roomAmenities,
    required this.guestsChildren,
    this.userId,
    this.hotelId,
    this.hotelName,
    this.hotelCity,
    this.roomTypeName,
    this.roomImage,
    this.paymentMethod,
    this.paidAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final hotelsData = json['hotels'];
    Map<String, dynamic>? hotelJson;
    if (hotelsData is Map<String, dynamic>) {
      hotelJson = hotelsData;
    } else if (hotelsData is List && hotelsData.isNotEmpty) {
      hotelJson = hotelsData.first as Map<String, dynamic>;
    }

    final roomsData = json['room_types'];
    Map<String, dynamic>? roomJson;
    if (roomsData is Map<String, dynamic>) {
      roomJson = roomsData;
    } else if (roomsData is List && roomsData.isNotEmpty) {
      roomJson = roomsData.first as Map<String, dynamic>;
    }

    List<String> amenities = [];
    final roomData = json['room_types'];
    final Map<String, dynamic>? roomMap =
        roomData is List ? roomData.firstOrNull : roomData;

    if (roomMap != null && roomMap['room_type_amenities'] != null) {
      final midTable = roomMap['room_type_amenities'] as List;
      amenities =
          midTable
              .map((item) {
                // Lấy tên từ bảng amenities lồng bên trong
                final amenityObj = item['amenities'];
                return amenityObj?['name']?.toString() ?? '';
              })
              .where((name) => name.isNotEmpty)
              .toList();
    }

    String? parseImage(dynamic data) {
      if (data == null) return null;
      if (data is List && data.isNotEmpty) return data.first.toString();
      if (data is String && data.isNotEmpty) return data;
      return null;
    }

    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      guestsAdults: (json['guests_adults'] as int?) ?? 1,
      guestsChildren: (json['guests_children'] as int?) ?? 0,
      hotelId: json['hotel_id'] as String?,
      hotelName: hotelJson?['name'] as String?,
      hotelCity: hotelJson?['city'] as String?,
      roomTypeName: roomJson?['name'] as String?,
      roomAmenities: amenities,
      roomImage: parseImage(roomJson?['image_url'] ?? roomJson?['image']),
      paymentMethod: json['payment_method'] as String?,
      paidAt:
          json['paid_at'] != null
              ? DateTime.parse(json['paid_at'] as String)
              : null,
    );
  }
}
