import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Remember me checkbox state provider
final rememberMeProvider = StateProvider<bool>((ref) => false);

// Forgot password input provider
final forgotPasswordInputProvider = StateProvider<String>((ref) => '');

// Prefix icon provider for forgot password screen
final forgotPasswordPrefixIconProvider = Provider<IconData>((ref) {
  final input = ref.watch(forgotPasswordInputProvider);

  if (input.isEmpty) {
    return LucideIcons.mail;
  } else if (_isEmail(input)) {
    return LucideIcons.mail;
  } else if (_isPhoneNumber(input)) {
    return LucideIcons.phone;
  } else {
    return LucideIcons.mail;
  }
});

bool _isEmail(String text) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);
}

bool _isPhoneNumber(String text) {
  return RegExp(r'^\+?[\d\s\-\(\)]{7,}$').hasMatch(text);
}
