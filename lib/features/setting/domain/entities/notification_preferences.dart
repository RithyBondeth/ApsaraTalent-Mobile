/// What a user can be reached about.
///
/// These are categories, not the API's `Notification.type` strings: 'like' and
/// 'match' are both [match], because nobody wants to be asked about them
/// separately.
enum NotificationCategory {
  application('Applications', 'Submitted, moved along, rejected, hired'),
  interview('Interviews', 'Invitations, reschedules and cancellations'),
  match('Matches', 'A new mutual match, or someone liking your profile'),
  message('Messages', 'A chat message you were not online to receive'),

  /// Security and account lifecycle: verification, password reset, suspension.
  ///
  /// Present so the list is complete, **not** so it can be switched off. The
  /// API delivers these whatever the preferences say — a user who could opt
  /// out of their own password-reset email would have locked themselves out
  /// with a checkbox. The screen shows it as always on rather than offering a
  /// switch that does nothing.
  account('Security and account', 'Verification, password resets, suspensions');

  const NotificationCategory(this.label, this.description);

  final String label;
  final String description;

  /// The API's key, which is this enum's name.
  String get key => name;

  bool get isAlwaysOn => this == NotificationCategory.account;

  static NotificationCategory? fromKey(String key) {
    for (final category in NotificationCategory.values) {
      if (category.key == key) return category;
    }
    return null;
  }
}

/// How a notification reaches someone. In-app is absent by design: the feed is
/// the record of what happened, not a delivery channel.
enum NotificationChannel {
  email('Email'),
  push('Push');

  const NotificationChannel(this.label);

  final String label;

  String get key => name;
}

/// A user's preferences as the settings screen sees them, with the API's
/// defaults already merged in — whether a row was ever stored is invisible
/// here on purpose, so the switches render the same either way.
class NotificationPreferences {
  const NotificationPreferences({
    required this.emailEnabled,
    required this.pushEnabled,
    required this.categories,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final categories = <NotificationCategory, Map<NotificationChannel, bool>>{};
    final raw = json['categories'];
    for (final category in NotificationCategory.values) {
      final chosen = raw is Map ? raw[category.key] : null;
      categories[category] = {
        for (final channel in NotificationChannel.values)
          channel: chosen is Map ? chosen[channel.key] == true : false,
      };
    }
    return NotificationPreferences(
      // Absent means on: the API resolves a missing row to true.
      emailEnabled: json['emailEnabled'] != false,
      pushEnabled: json['pushEnabled'] != false,
      categories: categories,
    );
  }

  /// The master switch for a channel. Off suppresses every category on it.
  final bool emailEnabled;
  final bool pushEnabled;

  final Map<NotificationCategory, Map<NotificationChannel, bool>> categories;

  bool master(NotificationChannel channel) =>
      channel == NotificationChannel.email ? emailEnabled : pushEnabled;

  bool isOn(NotificationCategory category, NotificationChannel channel) =>
      categories[category]?[channel] ?? false;

  /// Whether this switch can change what is delivered.
  ///
  /// A category switch under a master that is off changes nothing, and account
  /// notifications are sent whatever it says. The screen dims these rather
  /// than hiding them, so the stored choice is still visible.
  bool isEffective(NotificationCategory category, NotificationChannel channel) =>
      !category.isAlwaysOn && master(channel);

  NotificationPreferences copyWithMaster(
    NotificationChannel channel,
    bool enabled,
  ) =>
      NotificationPreferences(
        emailEnabled:
            channel == NotificationChannel.email ? enabled : emailEnabled,
        pushEnabled:
            channel == NotificationChannel.push ? enabled : pushEnabled,
        categories: categories,
      );

  NotificationPreferences copyWithCategory(
    NotificationCategory category,
    NotificationChannel channel,
    bool enabled,
  ) =>
      NotificationPreferences(
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        categories: {
          for (final entry in categories.entries)
            entry.key: entry.key == category
                ? {...entry.value, channel: enabled}
                : entry.value,
        },
      );
}
