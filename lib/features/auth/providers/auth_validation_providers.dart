// Validation providers for auth
import 'package:apsaratalent_mobile/core/validators/identifier_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

// Validation provider for forgot password
final forgotPasswordValidationProvider = Provider<String?>((ref) {
  final input = ref.watch(forgotPasswordInputProvider);
  // No error while the field is still empty; the button stays disabled instead.
  if (input.trim().isEmpty) return null;
  return IdentifierValidator.validate(input);
});

// Provider to check if forgot password form is valid
final forgotPasswordFormValidProvider = Provider<bool>((ref) {
  final input = ref.watch(forgotPasswordInputProvider);
  final validation = ref.watch(forgotPasswordValidationProvider);

  return input.isNotEmpty && validation == null;
});

// Login validation providers
final emailValidationProvider = Provider<String?>((ref) {
  final email = ref.watch(emailInputProvider);

  if (email.isEmpty) {
    return null; // No error when empty
  }

  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    return 'Please enter a valid email address';
  }

  return null; // Valid
});

final passwordValidationProvider = Provider<String?>((ref) {
  final password = ref.watch(passwordInputProvider);

  if (password.isEmpty) {
    return null; // No error when empty
  }

  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }

  return null; // Valid
});

final loginFormValidProvider = Provider<bool>((ref) {
  final email = ref.watch(emailInputProvider);
  final password = ref.watch(passwordInputProvider);
  final emailError = ref.watch(emailValidationProvider);
  final passwordError = ref.watch(passwordValidationProvider);

  return email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;
});
