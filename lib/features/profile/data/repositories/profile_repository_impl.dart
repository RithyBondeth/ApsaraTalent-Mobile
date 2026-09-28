import 'dart:typed_data';

import 'package:apsaratalent_mobile/core/constants/apis/profile_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final ApiClient _client;

  static const _mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  MultipartFile _part(ProfileUpload file) {
    final extension = file.filename.split('.').last.toLowerCase();
    final mime = _mimeTypes[extension];
    if (mime == null) {
      throw ApiException(message: 'This file type is not supported.');
    }
    return MultipartFile.fromBytes(
      file.bytes,
      filename: file.filename,
      contentType: MediaType.parse(mime),
    );
  }

  Future<void> _upload(String path, Map<String, dynamic> fields) async {
    // Refresh before creating FormData because a consumed multipart body
    // cannot be replayed after an expired access token is refreshed.
    await _client.get('/user/current-user');
    await _client.post(
      path,
      data: FormData.fromMap(fields),
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  Future<void> uploadAvatar(FeedViewer viewer, ProfileUpload file) => _upload(
        viewer.role == FeedViewerRole.employee
            ? apiUploadEmployeeAvatar(viewer.profileId)
            : apiUploadCompanyAvatar(viewer.profileId),
        {'avatar': _part(file)},
      );

  @override
  Future<void> removeAvatar(FeedViewer viewer) => _client
      .post(viewer.role == FeedViewerRole.employee
          ? apiRemoveEmployeeAvatar(viewer.profileId)
          : apiRemoveCompanyAvatar(viewer.profileId))
      .then((_) {});

  @override
  Future<void> uploadEmployeeDocument(
          String id, EmployeeDocumentType type, ProfileUpload file) =>
      _upload(
        type == EmployeeDocumentType.resume
            ? apiUploadEmployeeResume(id)
            : apiUploadEmployeeCoverLetter(id),
        {
          type == EmployeeDocumentType.resume ? 'resume' : 'coverLetter':
              _part(file)
        },
      );

  @override
  Future<void> removeEmployeeDocument(String id, EmployeeDocumentType type) =>
      _client
          .post(type == EmployeeDocumentType.resume
              ? apiRemoveEmployeeResume(id)
              : apiRemoveEmployeeCoverLetter(id))
          .then((_) {});

  @override
  Future<Uint8List> downloadEmployeeDocument(
      String id, EmployeeDocumentType type) async {
    final response = await _client.get(
      apiEmployeeDocument(id, type.apiValue),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(List<int>.from(response.data));
  }

  @override
  Future<void> uploadCompanyCover(String id, ProfileUpload file) =>
      _upload(apiUploadCompanyCover(id), {'cover': _part(file)});

  @override
  Future<void> removeCompanyCover(String id) =>
      _client.post(apiRemoveCompanyCover(id)).then((_) {});

  @override
  Future<void> uploadCompanyImages(String id, List<ProfileUpload> files) =>
      _upload(apiUploadCompanyImages(id), {
        'images': [for (final file in files) _part(file)],
      });

  @override
  Future<void> removeCompanyImage(String id, String imageId) =>
      _client.delete(apiRemoveCompanyImage(id, imageId)).then((_) {});

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
