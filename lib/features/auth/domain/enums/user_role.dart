enum UserRole {
  employee('employee'),
  company('company'),
  admin('admin'),
  none('none');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.none,
    );
  }
}
