// Auth state management with Riverpod
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/login_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state with login result, 2FA flag, loading, and error
class AuthState {
  final LoginSuccessEntity? loginSuccess; // Login success data
  final LoginTwoFactorEntity? twoFactorRequired; // 2FA required data
  final bool isLoading; // Loading state
  final String? error; // Error message

  AuthState({
    this.loginSuccess,
    this.twoFactorRequired,
    this.isLoading = false,
    this.error,
  });

  bool get requiresTwoFactor => twoFactorRequired != null;
  bool get isLoggedIn => loginSuccess != null;

  AuthState copyWith({
    LoginSuccessEntity? loginSuccess,
    LoginTwoFactorEntity? twoFactorRequired,
    bool? isLoading,
    String? error,
    bool clearTwoFactor = false,
    bool clearLogin = false,
    bool clearError = false,
  }) {
    return AuthState(
      loginSuccess: clearLogin ? null : (loginSuccess ?? this.loginSuccess),
      twoFactorRequired:
          clearTwoFactor ? null : (twoFactorRequired ?? this.twoFactorRequired),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Auth notifier for managing auth state
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final LoginUseCase _loginUseCase;

  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    return AuthState();
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _loginUseCase(email, password);

      if (result is LoginTwoFactorEntity) {
        return AuthState(twoFactorRequired: result);
      }

      final success = result as LoginSuccessEntity;
      return AuthState(loginSuccess: success);
    });

    if (state.hasError) {
      final error = state.error;
      final message = error is ApiException
          ? error.message
          : 'Login failed. Please try again.';
      state = AsyncValue.data(AuthState(error: message));
    }
  }

  // Clear 2FA state
  void clearTwoFactor() {
    state = AsyncValue.data(state.value?.copyWith(clearTwoFactor: true) ?? AuthState());
  }

  // Clear error state
  void clearError() {
    state = AsyncValue.data(state.value?.copyWith(clearError: true) ?? AuthState());
  }
}

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );
});

// Auth provider
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
