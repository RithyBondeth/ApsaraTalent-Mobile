import 'package:apsaratalent_mobile/core/constants/app_constant.dart';

/// One requirement of a new password, with whether a value meets it.
class PasswordRule {
  const PasswordRule(this.label, this.test);

  final String label;
  final bool Function(String value) test;
}

class PasswordValidator {
  PasswordValidator._();

  /// For signing in to an existing account. Deliberately loose: an account
  /// created before a rule existed must still be able to sign in.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    return null;
  }

  /// The rules a *new* password must meet — signup and password reset.
  ///
  /// These mirror class-validator's `@IsStrongPassword()` defaults, which is
  /// what the API enforces on both endpoints: 8+ characters with a lowercase
  /// letter, an uppercase letter, a number and a symbol. Checking a weaker rule
  /// here would let the form submit and then fail on the server with a message
  /// the user can't act on.
  static final List<PasswordRule> strongRules = [
    PasswordRule(
      'At least ${AppConstants.minPasswordLength} characters',
      (v) => v.length >= AppConstants.minPasswordLength,
    ),
    PasswordRule('A lowercase letter', (v) => RegExp('[a-z]').hasMatch(v)),
    PasswordRule('An uppercase letter', (v) => RegExp('[A-Z]').hasMatch(v)),
    PasswordRule('A number', (v) => RegExp('[0-9]').hasMatch(v)),
    // validator.js counts any character outside letters and digits as a symbol.
    PasswordRule('A symbol', (v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v)),
  ];

  /// Null when [value] meets every [strongRules] entry and fits the length cap.
  static String? validateStrong(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }
    for (final rule in strongRules) {
      if (!rule.test(v)) return 'Password needs ${rule.label.toLowerCase()}';
    }
    return null;
  }
}
