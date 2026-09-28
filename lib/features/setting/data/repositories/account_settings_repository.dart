import 'dart:typed_data';

import 'package:apsaratalent_mobile/core/constants/apis/account_settings_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/account_settings.dart';
import 'package:dio/dio.dart';

class AccountSettingsRepository {
  AccountSettingsRepository(this._client);
  final ApiClient _client;

  Future<ProfileAnalytics> fetchProfileAnalytics() async {
    final response = await _client.get(apiProfileAnalytics);
    return ProfileAnalytics.fromJson(_object(response.data));
  }

  Future<bool> updatePrivacy(bool browsePrivately) async {
    final response = await _client.patch(
      apiProfilePrivacy,
      data: {'browsePrivately': browsePrivately},
    );
    return _object(response.data)['browsePrivately'] == true;
  }

  Future<String> reportProblem({
    required ProblemCategory category,
    required String details,
    String? pageUrl,
    String? userAgent,
  }) async {
    final response = await _client.post(apiSupportReport, data: {
      'category': category.key,
      'details': details.trim(),
      if (pageUrl != null) 'pageUrl': pageUrl,
      if (userAgent != null) 'userAgent': userAgent,
    });
    return ApiClient.messageFrom(response.data) ?? 'Report sent. Thank you.';
  }

  Future<AccountExport> exportData() async {
    final response = await _client.get(
      apiAccountExport,
      options: Options(responseType: ResponseType.bytes),
    );
    final values = response.headers['content-disposition'];
    final disposition = values?.isNotEmpty == true ? values!.first : '';
    final match = RegExp(r'filename="?([^";]+)').firstMatch(disposition);
    final fallback = 'apsara-talent-export.json';
    final rawName = match?.group(1)?.trim() ?? fallback;
    final fileName = rawName.replaceAll(RegExp(r'[/\\]'), '_');
    final data = response.data;
    if (data is! List<int>) {
      throw ApiException(message: 'The export file could not be read.');
    }
    return AccountExport(
      fileName: fileName,
      bytes: Uint8List.fromList(data),
    );
  }

  Future<AccountDeletionResult> requestDeletion() async {
    final response = await _client.post(apiAccountDeletion);
    final data = _object(response.data);
    final scheduledFor = DateTime.tryParse('${data['scheduledFor'] ?? ''}');
    if (scheduledFor == null) {
      throw ApiException(message: 'The deletion schedule could not be read.');
    }
    return AccountDeletionResult(
      message: ApiClient.messageFrom(data) ?? 'Account deletion scheduled.',
      scheduledFor: scheduledFor,
    );
  }

  Future<String> cancelDeletion() async {
    final response = await _client.post(apiCancelAccountDeletion);
    return ApiClient.messageFrom(response.data) ??
        'Account deletion cancelled.';
  }

  Map<String, dynamic> _object(dynamic data) {
    if (data is Map) return data.cast<String, dynamic>();
    throw ApiException(message: 'The server returned an unreadable response.');
  }
}
