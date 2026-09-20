import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';

/// The viewer's own profile. [FeedViewer] is reused because the split is the
/// same one the feed makes: an employee record or a company record, addressed
/// by profile id.
abstract class ProfileRepository {
  Future<UserProfile> fetchProfile(FeedViewer viewer);
}
