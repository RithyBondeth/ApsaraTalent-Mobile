import 'package:apsaratalent_mobile/core/constants/apis/notification_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:apsaratalent_mobile/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<NotificationPage> fetchPage({
    required int page,
    required int limit,
  }) =>
      _guard('Could not load your notifications.', () async {
        final response = await _client.get(
          apiNotifications,
          queryParameters: {'page': page, 'limit': limit},
        );
        final data = response.data;
        if (data is! Map) {
          throw ApiException(message: 'Could not read your notifications.');
        }
        return NotificationPage.fromJson(data.cast<String, dynamic>());
      });

  @override
  Future<void> markRead(String id) =>
      _guard('Could not mark that read.', () async {
        await _client.patch(apiNotificationRead(id));
      });

  @override
  Future<void> markAllRead() =>
      _guard('Could not mark everything read.', () async {
        await _client.patch(apiNotificationsReadAll);
      });

  @override
  Future<void> remove(String id) =>
      _guard('Could not delete that notification.', () async {
        await _client.delete(apiNotification(id));
      });

  @override
  Future<void> clearAll() =>
      _guard('Could not clear your notifications.', () async {
        await _client.delete(apiNotifications);
      });

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
