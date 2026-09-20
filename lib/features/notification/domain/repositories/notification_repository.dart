import 'package:apsaratalent_mobile/features/notification/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  /// One page, 1-indexed — the API pages with `page`/`limit`, not `skip`.
  Future<NotificationPage> fetchPage({required int page, required int limit});

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> remove(String id);

  /// Deletes every notification for the viewer. Irreversible.
  Future<void> clearAll();
}
