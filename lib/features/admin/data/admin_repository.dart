import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';

enum AdminSection {
  overview('Overview'),
  users('Users'),
  jobs('Job moderation'),
  reports('User reports'),
  problems('Support reports'),
  audit('Audit history');

  const AdminSection(this.label);
  final String label;
}

class AdminPage {
  const AdminPage(
      {required this.items,
      required this.total,
      required this.page,
      required this.limit});
  factory AdminPage.fromJson(Map<String, dynamic> json) => AdminPage(
      items: (json['items'] as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt());
  final List<Map<String, dynamic>> items;
  final int total, page, limit;
  bool get hasNext => page * limit < total;
}

/// All administrative requests use the same generated contract as web.
/// Authorization is enforced by AuthGuard + AdminGuard on the gateway.
class AdminRepository {
  AdminRepository(ApiClient client) : api = GatewayApi(client);
  final GatewayApi api;
  Map<String, dynamic> _object(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ApiException(message: 'Administrative data could not be read.');
  }

  Future<Map<String, dynamic>> overview() async =>
      _object((await api.adminUserControllerGetOverview()).data);
  Future<AdminPage> list(AdminSection section,
      {int page = 1,
      String search = '',
      String? role,
      String? status,
      String? visibility,
      String? category,
      String? targetUserId}) async {
    final query = <String, dynamic>{'page': page, 'limit': 25};
    void add(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) query[key] = value.trim();
    }

    switch (section) {
      case AdminSection.users:
        add('search', search);
        add('role', role);
        add('status', status);
        return AdminPage.fromJson(ApiAdminPagedUsersDTO.fromJson(_object(
                (await api.adminUserControllerListUsers(query: query)).data))
            .toJson());
      case AdminSection.jobs:
        add('search', search);
        add('visibility', visibility);
        return AdminPage.fromJson(ApiAdminPagedJobsDTO.fromJson(_object(
                (await api.adminJobControllerListJobs(query: query)).data))
            .toJson());
      case AdminSection.reports:
        add('status', status);
        return AdminPage.fromJson(ApiAdminPagedReportsDTO.fromJson(_object(
                (await api.adminReportControllerListReports(query: query))
                    .data))
            .toJson());
      case AdminSection.problems:
        add('status', status);
        add('category', category);
        return AdminPage.fromJson(ApiAdminPagedProblemReportsDTO.fromJson(
                _object((await api.adminProblemReportControllerListReports(
                        query: query))
                    .data))
            .toJson());
      case AdminSection.audit:
        add('targetUserId', targetUserId);
        return AdminPage.fromJson(ApiAdminPagedAuditDTO.fromJson(_object(
                (await api.adminReportControllerListAudit(query: query)).data))
            .toJson());
      case AdminSection.overview:
        throw ArgumentError('Overview is not a paged queue');
    }
  }

  Future<ApiAdminUserDetailDTO> user(String id) async =>
      ApiAdminUserDetailDTO.fromJson(
          _object((await api.adminUserControllerGetUser(userId: id)).data));
  Future<void> updateUser(String id,
      {required String status,
      required String reason,
      DateTime? suspendedUntil}) async {
    _reason(reason);
    if (!const ['active', 'suspended', 'banned'].contains(status) ||
        (suspendedUntil != null && status != 'suspended') ||
        (suspendedUntil != null && !suspendedUntil.isAfter(DateTime.now()))) {
      throw ApiException(
          message: 'Choose a valid account status and future suspension date.');
    }
    await api.adminUserControllerUpdateUserStatus(
        userId: id,
        body: ApiAdminUpdateUserStatusBodyDTO(
            status: status,
            reason: reason.trim(),
            suspendedUntil: suspendedUntil?.toUtc().toIso8601String()));
  }

  Future<void> hideJob(String id, String reason) async {
    _reason(reason);
    await api.adminJobControllerHideJob(
        jobId: id, body: ApiAdminHideJobBodyDTO(reason: reason.trim()));
  }

  Future<void> restoreJob(String id) async =>
      api.adminJobControllerRestoreJob(jobId: id);
  Future<void> updateReport(String id,
      {required bool problem, required String status, String? note}) async {
    if (!const ['pending', 'reviewed', 'resolved', 'dismissed']
            .contains(status) ||
        (note?.trim().length ?? 0) > 500) {
      throw ApiException(
          message:
              'Choose a valid report status and a note of at most 500 characters.');
    }
    final trimmed = note?.trim();
    if (problem) {
      await api.adminProblemReportControllerUpdateStatus(
          reportId: id,
          body: ApiAdminUpdateProblemReportStatusBodyDTO(
              status: status, note: trimmed));
    } else {
      await api.adminReportControllerUpdateReportStatus(
          reportId: id,
          body:
              ApiAdminUpdateReportStatusBodyDTO(status: status, note: trimmed));
    }
  }

  void _reason(String reason) {
    if (reason.trim().length < 10 || reason.trim().length > 500) {
      throw ApiException(
          message: 'Give a reason between 10 and 500 characters.');
    }
  }
}
