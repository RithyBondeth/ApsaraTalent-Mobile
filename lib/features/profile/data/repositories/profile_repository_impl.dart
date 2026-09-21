import 'package:apsaratalent_mobile/core/constants/apis/profile_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<UserProfile> updateProfile(
    FeedViewer viewer,
    Map<String, dynamic> changes,
  ) async {
    final employee = viewer.role == FeedViewerRole.employee;
    try {
      final response = await _client.patch(
        employee
            ? apiUpdateEmployee(viewer.profileId)
            : apiUpdateCompany(viewer.profileId),
        data: changes,
      );
      final data = response.data;
      // The update answers `{message, employee|company}` rather than the
      // record on its own.
      final record = data is Map
          ? (data[employee ? 'employee' : 'company'] ?? data)
          : null;
      if (record is! Map) {
        throw ApiException(message: 'Could not read the saved profile.');
      }
      final json = record.cast<String, dynamic>();
      return employee
          ? EmployeeProfile.fromJson(json)
          : CompanyProfile.fromJson(json);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Could not save your profile.');
    }
  }

  @override
  Future<UserProfile> fetchProfile(FeedViewer viewer) async {
    final employee = viewer.role == FeedViewerRole.employee;
    try {
      final response = await _client.get(
        employee
            ? apiEmployeeProfile(viewer.profileId)
            : apiCompanyProfile(viewer.profileId),
      );
      final data = response.data;
      if (data is! Map) {
        throw ApiException(message: 'Could not load your profile.');
      }
      final json = data.cast<String, dynamic>();
      return employee
          ? EmployeeProfile.fromJson(json)
          : CompanyProfile.fromJson(json);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Could not load your profile.');
    }
  }
}
