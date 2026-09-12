import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/login_use_case.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/login/login_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginNotifier extends AsyncNotifier<LoginState> {
  late LoginUseCase _loginUseCase;

  @override
  Future<LoginState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    return LoginState();
  }

  /// [identifier] is the email or phone number the user typed.
  Future<void> login(String identifier, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _loginUseCase(
        identifier,
        password,
        remember: ref.read(rememberMeProvider),
      );
      // Establish before reporting success, so the screen that navigates on
      // `isLoggedIn` lands on a feed that already knows who is signed in.
      if (!response.requiresTwoFactor) {
        await ref.read(authSessionProvider.notifier).establish();
      }
      return LoginState(loginResponse: response);
    });

    if (state.hasError) {
      final error = state.error;
      final message = error is ApiException
          ? error.message
          : 'Login failed. Please try again.';
      state = AsyncValue.data(LoginState(error: message));
    }
  }

  // Clear response state
  void clearResponse() {
    state = AsyncValue.data(
        state.value?.copyWith(clearResponse: true) ?? LoginState());
  }

  // Clear error state
  void clearError() {
    state = AsyncValue.data(
        state.value?.copyWith(clearError: true) ?? LoginState());
  }
}
