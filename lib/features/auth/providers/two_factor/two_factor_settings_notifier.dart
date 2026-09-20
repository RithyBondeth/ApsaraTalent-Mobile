import 'package:apsaratalent_mobile/features/auth/data/models/two_factor_setup.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/common/flow_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TwoFactorSettingsState {
  const TwoFactorSettingsState({
    this.flow = const FlowState.idle(),
    this.setup,
  });

  final FlowState flow;

  /// Present between starting setup and confirming it with a code.
  final TwoFactorSetup? setup;
}

class TwoFactorSettingsNotifier
    extends AutoDisposeNotifier<TwoFactorSettingsState> {
  @override
  TwoFactorSettingsState build() => const TwoFactorSettingsState();

  void _emit(FlowState flow, {TwoFactorSetup? setup, bool keepSetup = true}) {
    state = TwoFactorSettingsState(
      flow: flow,
      setup: setup ?? (keepSetup ? state.setup : null),
    );
  }

  Future<void> startSetup() async {
    final setup = await runFlow(
      (s) => _emit(s),
      () => ref.read(authRepositoryProvider).setupTwoFactor(),
    );
    if (setup != null) _emit(const FlowState.idle(), setup: setup);
  }

  Future<bool> enable(String otp) => _toggle(
        () => ref.read(authRepositoryProvider).enableTwoFactor(otp),
      );

  Future<bool> disable(String otp) => _toggle(
        () => ref.read(authRepositoryProvider).disableTwoFactor(otp),
      );

  Future<bool> _toggle(Future<String> Function() action) async {
    final message = await runFlow((s) => _emit(s), action, message: (m) => m);
    if (message == null) return false;
    _emit(FlowState(message: message), keepSetup: false);
    await ref.read(authSessionProvider.notifier).refreshUser();
    return true;
  }

  void cancelSetup() => _emit(const FlowState.idle(), keepSetup: false);
}

final twoFactorSettingsProvider = NotifierProvider.autoDispose<
    TwoFactorSettingsNotifier, TwoFactorSettingsState>(
  TwoFactorSettingsNotifier.new,
);
