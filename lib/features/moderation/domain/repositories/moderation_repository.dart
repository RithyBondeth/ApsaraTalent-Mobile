import 'package:apsaratalent_mobile/features/moderation/domain/entities/moderation.dart';

/// Every id here is a **user** id.
abstract class ModerationRepository {
  Future<List<BlockedUser>> fetchBlocked();

  Future<void> block(String userId);

  Future<void> unblock(String userId);

  /// Reporting does not block. The two are separate on the API and separate
  /// here, so someone can report without cutting contact, or both.
  Future<void> report(
    String userId, {
    required ReportReason reason,
    String? details,
  });
}
