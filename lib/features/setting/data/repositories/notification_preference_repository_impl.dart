import 'package:apsaratalent_mobile/core/constants/apis/notification_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/notification_preferences.dart';
import 'package:apsaratalent_mobile/features/setting/domain/repositories/notification_preference_repository.dart';

class NotificationPreferenceRepositoryImpl
    implements NotificationPreferenceRepository {
  NotificationPreferenceRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<NotificationPreferences> fetch() =>
      _guard('Could not load your notification settings.', () async {
        final response = await _client.get(apiNotificationPreferences);
        return _parse(response.data);
      });

  @override
  Future<NotificationPreferences> setMaster(
    NotificationChannel channel,
    bool enabled,
  ) =>
      _patch({
        channel == NotificationChannel.email ? 'emailEnabled' : 'pushEnabled':
            enabled,
      });

  @override
  Future<NotificationPreferences> setCategory(
    NotificationCategory category,
    NotificationChannel channel,
    bool enabled,
  ) =>
      _patch({
        'categories': {
          category.key: {channel.key: enabled},
        },
      });

  Future<NotificationPreferences> _patch(Map<String, dynamic> body) =>
      _guard('Could not save that. Please try again.', () async {
        // The response is the resolved preferences, so the screen takes its
        // new state from the server rather than trusting what it sent.
        final response = await _client.patch(
          apiNotificationPreferences,
          data: body,
        );
        return _parse(response.data);
      });

  NotificationPreferences _parse(dynamic data) {
    if (data is! Map) {
      throw ApiException(
        message: 'Could not read your notification settings.',
      );
    }
    return NotificationPreferences.fromJson(data.cast<String, dynamic>());
  }

  Future<T> _guard<T>(String fallback, Future<T> Function() body) async {
    try {
      return await body();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: fallback);
    }
  }
}
