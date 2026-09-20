import 'package:apsaratalent_mobile/core/utils/json_parse.dart';

/// What a notification is about.
///
/// These are the `type` strings the API writes, not the five preference
/// categories — several types collapse into one category there, and mapping
/// them together here would lose the distinction the row is meant to show.
/// Anything unrecognised is [other], which still renders.
enum NotificationKind {
  application('Application'),
  offer('Offer'),
  interview('Interview'),
  match('Match'),
  like('Like'),
  chat('Message'),
  call('Call'),
  info('Update'),
  other('Update');

  const NotificationKind(this.label);

  /// Shown as the row's eyebrow.
  final String label;

  static NotificationKind fromKey(String? key) {
    for (final kind in NotificationKind.values) {
      if (kind.name == key) return kind;
    }
    return NotificationKind.other;
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.kind,
    required this.isRead,
    this.message,
    this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // `data` carries whatever the sending path attached. Only the sender is
    // read here; the ids in it are for a deep link that does not exist yet.
    final data = json['data'];
    final sender = data is Map ? data.cast<String, dynamic>() : null;
    return AppNotification(
      id: '${json['id']}',
      title: jsonText(json['title']) ?? 'Notification',
      message: jsonText(json['message']),
      kind: NotificationKind.fromKey(jsonText(json['type'])),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(jsonText(json['createdAt']) ?? ''),
      senderName: sender == null ? null : jsonText(sender['senderName']),
      senderAvatarUrl: sender == null ? null : jsonText(sender['senderAvatar']),
    );
  }

  final String id;
  final String title;
  final String? message;
  final NotificationKind kind;
  final bool isRead;
  final DateTime? createdAt;
  final String? senderName;
  final String? senderAvatarUrl;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        kind: kind,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
      );

  /// "3h", "2d", "just now". Coarse on purpose: the exact minute a match
  /// happened is never what someone is reading this list for.
  String get age {
    final createdAt = this.createdAt;
    if (createdAt == null) return '';
    final elapsed = DateTime.now().difference(createdAt);
    if (elapsed.inMinutes < 1) return 'just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d';
    return '${(elapsed.inDays / 7).floor()}w';
  }
}

/// One page of the notification feed.
///
/// The API answers `{items, total, page, limit}` rather than a bare array, so
/// whether more pages exist is known without guessing from a short page.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: jsonMaps(json['items']).map(AppNotification.fromJson).toList(),
        total: jsonInt(json['total']) ?? 0,
        page: jsonInt(json['page']) ?? 1,
        limit: jsonInt(json['limit']) ?? 0,
      );

  final List<AppNotification> items;
  final int total;
  final int page;
  final int limit;
}
