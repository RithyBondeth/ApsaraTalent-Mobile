// User role enum
enum EUserRole {
  employee('employee'), // Regular employee
  company('company'), // Company account
  admin('admin'), // Admin account
  none('none'); // No role

  final String value;
  const EUserRole(this.value);

  // Convert string to enum
  factory EUserRole.fromString(String value) {
    return EUserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EUserRole.none,
    );
  }
}
