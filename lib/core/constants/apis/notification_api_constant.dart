/// Notification endpoints.
///
/// `/notification/unread-count` is declared in `feed_api_constant.dart`, where
/// the feed's badge first needed it. Left there rather than moved, so this
/// change stays one feature wide.
library;

/// GET returns every category with defaults merged in; PATCH takes a partial
/// and returns the same resolved shape back.
const String apiNotificationPreferences = '/notification/preferences';

/// The notification feed itself. Paged with `page`/`limit` — not the
/// `skip`/`limit` the profile lists use — and answered with an envelope
/// rather than a bare array.
const String apiNotifications = '/notification';
const String apiNotificationsReadAll = '/notification/read-all';

String apiNotificationRead(String id) => '/notification/$id/read';
String apiNotification(String id) => '/notification/$id';
