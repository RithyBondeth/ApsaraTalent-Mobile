import 'package:apsaratalent_mobile/shared/functions/check_email_function.dart';
import 'package:apsaratalent_mobile/shared/functions/check_phonenumber_function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

// Validation provider for forgot password
final forgotPasswordValidationProvider = Provider<String?>((ref) {
  final input = ref.watch(forgotPasswordInputProvider);

  if (input.isEmpty) return null;

  if (isEmail(input)) {
    // Validate email format
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      return 'Please enter a valid email address';
    }
  } else if (isPhoneNumber(input)) {
    // Validate phone format
    final cleanPhone = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < 8) {
      return 'Phone number must be at least 8 digits';
    }
  } else {
    return 'Please enter a valid email or phone number';
  }

  return null;
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
