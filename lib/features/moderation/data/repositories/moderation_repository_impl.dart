import 'package:apsaratalent_mobile/core/constants/apis/moderation_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/entities/moderation.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/repositories/moderation_repository.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<BlockedUser>> fetchBlocked() =>
      _guard('Could not load the accounts you blocked.', () async {
        final response = await _client.get(apiBlockedUsers);
        final data = response.data;
        if (data is! List) return const <BlockedUser>[];
        return data
            .whereType<Map>()
            .map((m) => BlockedUser.fromJson(m.cast<String, dynamic>()))
            .toList();
      });

  @override
  Future<void> block(String userId) =>
      _guard('Could not block that account.', () async {
        await _client.post(apiBlockUser(userId));
      });

  @override
  Future<void> unblock(String userId) =>
      _guard('Could not unblock that account.', () async {
        await _client.delete(apiBlockUser(userId));
      });

  @override
  Future<void> report(
    String userId, {
    required ReportReason reason,
    String? details,
  }) =>
      _guard('Could not send that report.', () async {
        final note = details?.trim();
        await _client.post(apiReportUser, data: {
          'reportedId': userId,
          'reason': reason.key,
          if (note != null && note.isNotEmpty) 'details': note,
        });
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
