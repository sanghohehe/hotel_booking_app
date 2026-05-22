class BookingEntity {
  final String id;
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

  final String? paymentMethod;
  final DateTime? paidAt;

  final int? nights;

  BookingEntity({
    required this.id,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.guestsAdults,
    required this.guestsChildren,
    this.hotelId,
    this.hotelName,
    this.hotelCity,
    this.roomTypeName,
    this.paymentMethod,
    this.paidAt,
    this.nights,
  });

  BookingEntity copyWith({
    String? id,
    DateTime? checkIn,
    DateTime? checkOut,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    int? guestsAdults,
    int? guestsChildren,
    String? hotelId,
    String? hotelName,
    String? hotelCity,
    String? roomTypeName,
    String? paymentMethod,
    DateTime? paidAt,
    int? nights,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      guestsAdults: guestsAdults ?? this.guestsAdults,
      guestsChildren: guestsChildren ?? this.guestsChildren,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      hotelCity: hotelCity ?? this.hotelCity,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      nights: nights ?? this.nights,
    );
  }
}
