class ProfileEntity {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;

  ProfileEntity({
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
  });
}