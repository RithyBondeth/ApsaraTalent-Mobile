/// Saved job searches. **Employee-only**: the gateway answers anyone else
/// with 403 "Only candidates can manage saved searches."
///
/// These routes answered 500 everywhere until ApsaraTalent-Api#184 registered
/// the SavedSearch entity on the DataSource.
library;

const String apiSavedSearches = '/job/saved-search';

/// PATCH to update, DELETE to remove.
String apiSavedSearch(String id) => '/job/saved-search/$id';

/// `{totalMatches, newMatchCount}` — new since the digest last ran.
String apiSavedSearchPreview(String id) => '/job/saved-search/$id/preview';
