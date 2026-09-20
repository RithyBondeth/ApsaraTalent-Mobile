/// The three numbers on the settings page's Activity rows.
///
/// Each is fetched on its own and each degrades on its own: a row whose count
/// could not load shows its label without a number, rather than a zero that
/// would read as "you have none".
class ActivityCounts {
  const ActivityCounts({this.applications, this.saved, this.unread});

  /// Null means "not known", which is not the same as zero.
  final int? applications;
  final int? saved;
  final int? unread;
}
