class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatar;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatar,
  });
}
