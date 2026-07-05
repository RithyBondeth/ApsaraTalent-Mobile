import 'package:apsaratalent_mobile/core/validators/email_validator.dart';
import 'package:apsaratalent_mobile/core/validators/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Remember me checkbox state provider
final rememberMeProvider = StateProvider<bool>((ref) => false);

final emailInputProvider = StateProvider<String>((ref) => '');
final passwordInputProvider = StateProvider<String>((ref) => '');

// Forgot password input provider
final forgotPasswordInputProvider = StateProvider<String>((ref) => '');

// Prefix icon provider for forgot password screen
final forgotPasswordPrefixIconProvider = Provider<IconData?>((ref) {
  final input = ref.watch(forgotPasswordInputProvider);

  if (input.isEmpty) {
    return null;
  } else if (EmailValidator.validate(input) != null) {
    return LucideIcons.mail;
  } else if (PhoneValidator.validate(input) != null) {
    return LucideIcons.phone;
  } else {
    return null;
  }
});
