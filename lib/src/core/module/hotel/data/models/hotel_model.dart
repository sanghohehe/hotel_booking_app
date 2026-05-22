import 'dart:convert';

import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:booking_app/src/core/utils/clean_image_utils.dart';

/// ================= SAFE ARRAY PARSER =================
///
/// FIX TRIỆT ĐỂ:
/// - Không bao giờ crash vì array/string/null
/// - Tự clean newline
/// - Tự trim
/// - Không để malformed array
/// - Support Supabase text[], jsonb, string
///
List<String> _parseList(dynamic data) {
  try {
    if (data == null) return [];

    if (data is List) {
      return data
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty && e.length > 10 && e.startsWith('http'))
          .toList();
    }

    if (data is String) {
      String cleaned = data.trim();

      if (cleaned.isEmpty || cleaned == '[""]' || cleaned == '[]') return [];

      // Parse JSON string
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        try {
          final decoded = jsonDecode(cleaned);
          return _parseList(decoded);
        } catch (_) {}
      }

      // Single URL
      if (cleaned.startsWith('http')) {
        return [cleaned];
      }
    }

    return [];
  } catch (e) {
    print('PARSE LIST ERROR: $e');
    return [];
  }
}

class RoomTypeModel {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final String? bedType;
  final double pricePerNight;
  final bool isActive;
  final int inventory;

  /// Danh sách ảnh phòng
  final List<String> imageUrl;

  final List<String> amenities;

  RoomTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    this.bedType,
    required this.pricePerNight,
    required this.isActive,
    required this.inventory,
    this.imageUrl = const [],
    this.amenities = const [],
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    try {
      return RoomTypeModel(
        id: json['id']?.toString() ?? '',

        name: json['name']?.toString() ?? '',

        description: json['description']?.toString(),

        capacity: (json['capacity'] ?? 0) as int,

        bedType: json['bed_type']?.toString(),

        pricePerNight: ((json['price_per_night'] ?? 0) as num).toDouble(),

        isActive: (json['is_active'] as bool?) ?? true,

        inventory: (json['inventory'] as int?) ?? 1,

        /// FIX ARRAY IMAGE
        imageUrl: _parseList(json['image_url']),

        /// FIX ARRAY AMENITIES
        amenities: _parseList(json['amenities']),
      );
    } catch (e) {
      print('ROOM MODEL ERROR: $e');
      print('ROOM JSON: $json');

      return RoomTypeModel.empty();
    }
  }

  factory RoomTypeModel.empty() {
    return RoomTypeModel(
      id: '',
      name: '',
      description: '',
      capacity: 2,
      bedType: 'Double',
      pricePerNight: 0,
      isActive: true,
      inventory: 1,
      imageUrl: [],
      amenities: [],
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'name': name,
        'description': description?.trim(),
        'capacity': capacity,
        'bed_type': bedType?.trim(),
        'price_per_night': pricePerNight,
        'is_active': isActive,
        'inventory': inventory,

        /// FIX SUPABASE ARRAY
        'image_url':
            imageUrl
                .map((e) => e.replaceAll('\n', '').trim())
                .where((e) => e.isNotEmpty)
                .toList(),

        /// FIX SUPABASE ARRAY
        'amenities':
            amenities
                .map((e) => e.replaceAll('\n', '').trim())
                .where((e) => e.isNotEmpty)
                .toList(),
      };
    } catch (e) {
      print('ROOM TO JSON ERROR: $e');

      return {};
    }
  }
}

class HotelModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final String? description;
  final double starRating;

  /// Danh sách ảnh hotel
  final List<String> images;

  final List<RoomTypeModel> roomTypes;

  HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.description,
    required this.starRating,
    this.images = const [],
    this.roomTypes = const [],
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    try {
      final parsedImages = _parseList(json['images'] ?? json['thumbnail_url']);

      return HotelModel(
        id: json['id']?.toString() ?? '',

        name: json['name']?.toString() ?? '',

        city: json['city']?.toString() ?? '',

        address: json['address']?.toString() ?? '',

        description: json['description']?.toString(),

        starRating: ((json['star_rating'] ?? 0) as num).toDouble(),

        /// FIX TRIỆT ĐỂ ARRAY IMAGE
        images: parsedImages,

        roomTypes:
            ((json['room_types'] as List?) ?? [])
                .map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
    } catch (e) {
      print('HOTEL MODEL ERROR: $e');
      print('HOTEL JSON: $json');

      return HotelModel.empty();
    }
  }

  factory HotelModel.empty() {
    return HotelModel(
      id: '',
      name: '',
      city: '',
      address: '',
      description: '',
      starRating: 0,
      images: [],
      roomTypes: [],
    );
  }

  /// Thumbnail đầu tiên
  String? get thumbnailUrl {
    if (images.isEmpty) return null;

    final first = images.first.trim();

    if (!first.startsWith('http')) {
      return null;
    }

    return first;
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'name': name.trim(),
        'city': city.trim(),
        'address': address.trim(),
        'description': description?.trim(),
        'star_rating': starRating,

        /// FIX ARRAY SUPABASE
        'images':
            images
                .map((e) => e.replaceAll('\n', '').trim())
                .where((e) => e.isNotEmpty)
                .toList(),

        'thumbnail_url': images.isNotEmpty ? images.first : null,

        'room_types': roomTypes.map((e) => e.toJson()).toList(),
      };
    } catch (e) {
      print('HOTEL TO JSON ERROR: $e');

      return {};
    }
  }

  HotelEntity toEntity() {
    return HotelEntity(
      id: id,
      name: name,
      city: city,
      address: address,
      starRating: starRating,

      /// thumbnail cho card
      thumbnailUrl: images.isNotEmpty ? images.first : null,

      description: description,

      /// slider banner
      images: images,

      roomTypes: roomTypes,
    );
  }
}
