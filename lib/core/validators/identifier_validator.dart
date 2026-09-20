import 'package:apsaratalent_mobile/core/validators/email_validator.dart';

enum EIdentifierKind { email, phone }

/// An email address or a phone number typed into one field — what the API's
/// forgot-password endpoint takes as `identifier`.
class IdentifierValidator {
  IdentifierValidator._();

  /// Cambodian and international numbers, with or without the leading `+`.
  static final _phone = RegExp(r'^\+?[0-9]{8,15}$');

  static String _compact(String value) =>
      value.trim().replaceAll(RegExp(r'[\s\-()]'), '');

  /// What [value] is, or null if it is neither.
  ///
  /// Note the comparison: every validator here returns an error *message* for
  /// bad input and null for good input, so "is an email" is `== null`. The
  /// provider this replaces used `!= null`, which read as "is not an email" and
  /// meant a valid phone number could never pass.
  static EIdentifierKind? kindOf(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (EmailValidator.validate(trimmed) == null) return EIdentifierKind.email;
    if (_phone.hasMatch(_compact(trimmed))) return EIdentifierKind.phone;
    return null;
  }

  static String? validate(String value) {
    if (value.trim().isEmpty) return 'Enter your email or phone number';
    return kindOf(value) == null
        ? 'Enter a valid email address or phone number'
        : null;
  }

  /// The value to send: an address trimmed, a number without spaces or dashes.
  static String normalize(String value) =>
      kindOf(value) == EIdentifierKind.phone ? _compact(value) : value.trim();
}
