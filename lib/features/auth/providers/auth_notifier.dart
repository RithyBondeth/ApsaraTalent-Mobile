// Auth state management with Riverpod
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state with login response, loading, and error
class AuthState {
  final LoginResponse? loginResponse; // API response
  final bool isLoading; // Loading state
  final String? error; // Error message

  AuthState({
    this.loginResponse,
    this.isLoading = false,
    this.error,
  });

  bool get requiresTwoFactor => loginResponse?.requiresTwoFactor ?? false;
  bool get isLoggedIn => loginResponse?.user != null;

  AuthState copyWith({
    LoginResponse? loginResponse,
    bool? isLoading,
    String? error,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return AuthState(
      loginResponse: clearResponse ? null : (loginResponse ?? this.loginResponse),
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
      final response = await _loginUseCase(email, password);
      return AuthState(loginResponse: response);
    });

    if (state.hasError) {
      final error = state.error;
      final message = error is ApiException
          ? error.message
          : 'Login failed. Please try again.';
      state = AsyncValue.data(AuthState(error: message));
    }
  }

  // Clear response state
  void clearResponse() {
    state = AsyncValue.data(state.value?.copyWith(clearResponse: true) ?? AuthState());
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
