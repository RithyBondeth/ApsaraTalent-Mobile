import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';

abstract class ApplicationRepository {
  /// The viewer's own applications, newest first as the API orders them.
  Future<List<JobApplication>> fetchMine();

  /// Withdraws — the application stays, with status `withdrawn`.
  Future<void> withdraw(String applicationId);

  /// Applies for [jobId]. Throws [ApiException] with the API's own message on
  /// a duplicate — the wording there ("You have already applied to this job")
  /// is better than anything this layer could invent.
  Future<JobApplication> apply(String jobId, {String? coverLetterNote});
}
