class HotelEntity {
  final String id;
  final String name;
  final String address;
  final String city;
  final double starRating;
  final String? thumbnailUrl;
  final String? description;
  final List<dynamic> roomTypes;
  final List<String> images;
  HotelEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.starRating,
    required this.roomTypes, 
    this.thumbnailUrl,
    this.description,
    this.images = const [],
  });
}
