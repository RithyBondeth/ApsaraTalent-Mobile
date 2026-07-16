import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final AuthEntity? data;
  final bool isLoading;
  final String? error;

  AuthState({this.data, this.isLoading = false, this.error});

  AuthState copyWith({AuthEntity? data, bool? isLoading, String? error}) {
    return AuthState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final AuthRepository _repository;

  @override
  Future<AuthState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    _loginUseCase = LoginUseCase(_repository);
    return AuthState();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final auth = await _loginUseCase(email, password);
      ApiClient().setToken(auth.accessToken);
      return AuthState(data: auth);
    });

    if (state.hasError) {
      final error = state.error;
      final message = error is ApiException
          ? error.message
          : 'Login failed. Please try again.';
      state = AsyncValue.data(AuthState(error: message));
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      ApiClient().setToken(null);
      return AuthState();
    });
  }

  void clearError() {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(error: null));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );
});

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
