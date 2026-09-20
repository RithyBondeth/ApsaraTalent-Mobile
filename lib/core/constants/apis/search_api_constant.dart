/// Search, and the one job route that reads a single posting.
///
/// There is **no company search**: `/user/company/all` takes pagination only,
/// and nothing else in the gateway searches companies. An employee searches
/// jobs and a company searches talent, which is what these two cover.
library;

/// Paged with `page`/`pageSize`, answered as `{data, total, page, pageSize,
/// isUsingFallback}`.
const String apiJobSearch = '/job/search';
const String apiEmployeeSearch = '/user/employee/search-employee';

/// Public — no auth. The only route that reads one job by id.
String apiPublicJob(String jobId) => '/public/job/$jobId';
