class ReviewModel {
  final String id;
  final String hotelId;
  final String userId;
  final int rating;
  final String? comment;
  final List<String> images;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.images,
    this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final fullName = profile?['full_name'] as String?;
    final avatarUrl = profile?['avatar_url'] as String?;

    return ReviewModel(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      username: profile?['username'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
