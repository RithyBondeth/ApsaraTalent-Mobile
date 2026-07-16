enum EUserRole {
  employee('employee'),
  company('company'),
  admin('admin'),
  none('none');

  final String value;
  const EUserRole(this.value);

  factory EUserRole.fromString(String value) {
    return EUserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EUserRole.none,
    );
  }
}
