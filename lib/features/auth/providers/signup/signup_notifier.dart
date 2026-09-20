import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/common/flow_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ESignupRole { employee, company }

/// Signup across three screens: role, account, profile.
///
/// Only what the first two screens collect is held here; the profile screen
/// owns its own form and hands a complete registration to [submitEmployee] or
/// [submitCompany]. The password lives in memory for the length of the flow
/// only — the provider is not auto-disposed mid-flow, and [reset] clears it
/// once the account exists or the user backs out.
class SignupState {
  const SignupState({
    this.role,
    this.email = '',
    this.password = '',
    this.phone,
    this.flow = const FlowState.idle(),
  });

  final ESignupRole? role;
  final String email;
  final String password;
  final String? phone;
  final FlowState flow;

  SignupState copyWith({
    ESignupRole? role,
    String? email,
    String? password,
    String? phone,
    FlowState? flow,
  }) =>
      SignupState(
        role: role ?? this.role,
        email: email ?? this.email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
        flow: flow ?? this.flow,
      );
}

class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void chooseRole(ESignupRole role) =>
      state = SignupState(role: role, email: state.email);

  void setAccount({
    required String email,
    required String password,
    String? phone,
  }) {
    state = state.copyWith(
      email: email.trim(),
      password: password,
      phone: (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
      flow: const FlowState.idle(),
    );
  }

  Future<bool> submitEmployee(EmployeeRegistration request) =>
      _submit(() => ref.read(authRepositoryProvider).registerEmployee(request));

  Future<bool> submitCompany(CompanyRegistration request) =>
      _submit(() => ref.read(authRepositoryProvider).registerCompany(request));

  Future<bool> _submit(Future<LoginResponse> Function() register) async {
    final response = await runFlow(
      (s) => state = state.copyWith(flow: s),
      register,
      message: (r) => r.message,
    );
    if (response == null) return false;
    await ref.read(authSessionProvider.notifier).establish();
    return true;
  }

  /// Forget everything entered, the password included.
  void reset() => state = const SignupState();
}

final signupProvider = NotifierProvider<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
