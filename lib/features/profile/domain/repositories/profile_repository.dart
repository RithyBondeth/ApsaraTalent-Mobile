import 'dart:typed_data';

import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';

class ProfileUpload {
  const ProfileUpload({required this.filename, required this.bytes});
  final String filename;
  final Uint8List bytes;
}

enum EmployeeDocumentType {
  resume('resume'),
  coverLetter('cover-letter');

  const EmployeeDocumentType(this.apiValue);
  final String apiValue;
}

/// The viewer's own profile. [FeedViewer] is reused because the split is the
/// same one the feed makes: an employee record or a company record, addressed
/// by profile id.
abstract class ProfileRepository {
  Future<UserProfile> fetchProfile(FeedViewer viewer);

  /// Sends only [changes] — the API applies the keys it receives and leaves
  /// the rest alone, so this must never restate unchanged fields. Answers with
  /// the profile as saved.
  Future<UserProfile> updateProfile(
    FeedViewer viewer,
    Map<String, dynamic> changes,
  );

  Future<void> uploadAvatar(FeedViewer viewer, ProfileUpload file);
  Future<void> removeAvatar(FeedViewer viewer);
  Future<void> uploadEmployeeDocument(
    String employeeId,
    EmployeeDocumentType type,
    ProfileUpload file,
  );
  Future<void> removeEmployeeDocument(
    String employeeId,
    EmployeeDocumentType type,
  );
  Future<Uint8List> downloadEmployeeDocument(
    String employeeId,
    EmployeeDocumentType type,
  );
  Future<void> uploadCompanyCover(String companyId, ProfileUpload file);
  Future<void> removeCompanyCover(String companyId);
  Future<void> uploadCompanyImages(
    String companyId,
    List<ProfileUpload> files,
  );
  Future<void> removeCompanyImage(String companyId, String imageId);
}
