import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/notification_preference_repository_impl.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/notification_preferences.dart';
import 'package:apsaratalent_mobile/features/setting/domain/repositories/notification_preference_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationPreferenceRepositoryProvider =
    Provider<NotificationPreferenceRepository>(
  (ref) => NotificationPreferenceRepositoryImpl(ref.watch(apiClientProvider)),
);

/// Identifies one switch on the screen, so the row that is saving can be the
/// only one disabled.
typedef PreferenceKey = String;

PreferenceKey masterKey(NotificationChannel channel) => 'master.${channel.key}';
PreferenceKey categoryKey(
  NotificationCategory category,
  NotificationChannel channel,
) =>
    '${category.key}.${channel.key}';

class PreferencesState {
  const PreferencesState({required this.preferences, this.saving = const {}});

  final NotificationPreferences preferences;

  /// The switches with a write in flight.
  final Set<PreferenceKey> saving;

  bool isSaving(PreferenceKey key) => saving.contains(key);

  PreferencesState copyWith({
    NotificationPreferences? preferences,
    Set<PreferenceKey>? saving,
  }) =>
      PreferencesState(
        preferences: preferences ?? this.preferences,
        saving: saving ?? this.saving,
      );
}

class NotificationPreferencesNotifier
    extends AutoDisposeAsyncNotifier<PreferencesState> {
  NotificationPreferenceRepository get _repository =>
      ref.read(notificationPreferenceRepositoryProvider);

  @override
  Future<PreferencesState> build() async =>
      PreferencesState(preferences: await _repository.fetch());

  Future<void> refresh() async {
    state = AsyncData(
      PreferencesState(preferences: await _repository.fetch()),
    );
  }

  Future<void> setMaster(NotificationChannel channel, bool enabled) =>
      _write(
        masterKey(channel),
        optimistic: (p) => p.copyWithMaster(channel, enabled),
        write: () => _repository.setMaster(channel, enabled),
      );

  Future<void> setCategory(
    NotificationCategory category,
    NotificationChannel channel,
    bool enabled,
  ) =>
      _write(
        categoryKey(category, channel),
        optimistic: (p) => p.copyWithCategory(category, channel, enabled),
        write: () => _repository.setCategory(category, channel, enabled),
      );

  /// Moves the switch at once, then replaces the whole object with what the
  /// API resolved — it is the authority on what the switches now read, and it
  /// merges rather than replaces, so another device's change survives.
  ///
  /// A failure puts the switch back exactly where it was and rethrows for the
  /// screen to report. Throws [ApiException].
  Future<void> _write(
    PreferenceKey key, {
    required NotificationPreferences Function(NotificationPreferences) optimistic,
    required Future<NotificationPreferences> Function() write,
  }) async {
    final current = state.value;
    if (current == null || current.isSaving(key)) return;

    state = AsyncData(current.copyWith(
      preferences: optimistic(current.preferences),
      saving: {...current.saving, key},
    ));

    try {
      final resolved = await write();
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        preferences: resolved,
        saving: {...latest.saving}..remove(key),
      ));
    } on ApiException {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        preferences: current.preferences,
        saving: {...latest.saving}..remove(key),
      ));
      rethrow;
    }
  }
}

final notificationPreferencesProvider = AsyncNotifierProvider.autoDispose<
    NotificationPreferencesNotifier, PreferencesState>(
  NotificationPreferencesNotifier.new,
);
