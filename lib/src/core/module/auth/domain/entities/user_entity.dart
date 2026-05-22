class UserEntity {
  final String id;
  final String email;
  final String? fullName;

  UserEntity({
    required this.id,
    required this.email,
    this.fullName,
  });
}
