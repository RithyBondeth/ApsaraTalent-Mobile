import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';

abstract class ApplicationRepository {
  /// The viewer's own applications, newest first as the API orders them.
  Future<List<JobApplication>> fetchMine();

  /// Withdraws — the application stays, with status `withdrawn`.
  Future<void> withdraw(String applicationId);
}
