class UserProfileModel {
  final String userId;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? avatarUrl;

  UserProfileModel({
    required this.userId,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.tryParse(json['date_of_birth'].toString())
              : null,
      address: json['address']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
