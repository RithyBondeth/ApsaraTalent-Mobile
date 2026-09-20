import 'package:apsaratalent_mobile/features/setting/domain/entities/notification_preferences.dart';

/// Every write is a partial: one switch, not the whole object. The API merges
/// per category, so sending one toggle cannot clobber a choice made elsewhere
/// a second earlier, and each write answers with the resolved preferences.
abstract class NotificationPreferenceRepository {
  Future<NotificationPreferences> fetch();

  Future<NotificationPreferences> setMaster(
    NotificationChannel channel,
    bool enabled,
  );

  Future<NotificationPreferences> setCategory(
    NotificationCategory category,
    NotificationChannel channel,
    bool enabled,
  );
}
