import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/account_settings_repository.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/account_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountSettingsRepositoryProvider = Provider<AccountSettingsRepository>(
  (ref) => AccountSettingsRepository(ref.watch(apiClientProvider)),
);

class ProfilePrivacyNotifier
    extends AutoDisposeAsyncNotifier<ProfileAnalytics> {
  AccountSettingsRepository get _repository =>
      ref.read(accountSettingsRepositoryProvider);

  @override
  Future<ProfileAnalytics> build() => _repository.fetchProfileAnalytics();

  Future<void> refresh() async {
    state = AsyncData(await _repository.fetchProfileAnalytics());
  }

  Future<void> setPrivate(bool value) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(previous.withPrivacy(value));
    try {
      final resolved = await _repository.updatePrivacy(value);
      state = AsyncData(previous.withPrivacy(resolved));
    } on ApiException {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final profilePrivacyProvider =
    AsyncNotifierProvider.autoDispose<ProfilePrivacyNotifier, ProfileAnalytics>(
        ProfilePrivacyNotifier.new);
