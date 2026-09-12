// Shared provider definitions for auth
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/validators/email_validator.dart';
import 'package:apsaratalent_mobile/core/validators/phone_validator.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:apsaratalent_mobile/features/auth/providers/login/login_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Input providers
final emailInputProvider = StateProvider<String>((ref) => '');
final passwordInputProvider = StateProvider<String>((ref) => '');
final rememberMeProvider = StateProvider<bool>((ref) => false);
final forgotPasswordInputProvider = StateProvider<String>((ref) => '');

// Forgot password prefix icon provider
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

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    sessionStore: ref.watch(sessionStoreProvider),
  );
});

// Login provider
final loginProvider =
    AsyncNotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);
