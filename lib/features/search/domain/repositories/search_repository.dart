import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';

/// What the viewer searches depends on which side they are on: an employee
/// looks for jobs, a company looks for talent. There is no company search in
/// the gateway, so browsing companies stays the feed's job.
abstract class SearchRepository {
  /// [careerScopes] narrows to postings from companies in those scopes, by
  /// **name**. Empty means no narrowing — the filter is not applied at all,
  /// which also keeps the API's scope fallback from firing.
  Future<SearchResults<JobPosting>> searchJobs({
    required String keyword,
    List<String> careerScopes,
    int page,
  });

  Future<SearchResults<FeedEmployee>> searchTalent({
    required String keyword,
    List<String> careerScopes,
    int page,
  });

  /// One posting, by id. Public — this is the only route that reads a single
  /// job.
  Future<JobPosting> fetchJob(String jobId);
}
