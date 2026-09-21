/// Blocking and reporting.
///
/// Addressed by **user** id, not profile id — moderation acts on the account,
/// not on the employee or company row hanging off it. `hidden-ids` is declared
/// in `feed_api_constant.dart`, where the feed needed it first.
library;

const String apiBlockedUsers = '/user/moderation/blocked';
const String apiReportUser = '/user/moderation/report';

/// POST to block, DELETE to unblock — the same path.
String apiBlockUser(String userId) => '/user/moderation/block/$userId';
String apiBlockStatus(String userId) => '/user/moderation/block-status/$userId';
