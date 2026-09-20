/// Mutual matches: the other half of the feed's like.
///
/// The like and liked-id routes live in `feed_api_constant.dart`, where the
/// feed needed them first. Every id here is a profile id — the employee's or
/// company's own — never the user id.
library;

String apiEmployeeMatches(String employeeId) =>
    '/match/current-employee-matching/$employeeId';
String apiCompanyMatches(String companyId) =>
    '/match/current-company-matching/$companyId';

String apiEmployeeMatchCount(String employeeId) =>
    '/match/current-employee-matching-count/$employeeId';
String apiCompanyMatchCount(String companyId) =>
    '/match/current-company-matching-count/$companyId';

/// Marks every match seen at once; there is no per-match variant.
String apiEmployeeMatchesSeen(String employeeId) =>
    '/match/employee/$employeeId/matching-seen';
String apiCompanyMatchesSeen(String companyId) =>
    '/match/company/$companyId/matching-seen';

/// Always employee id then company id, whichever side is asking.
String apiUnmatch(String employeeId, String companyId) =>
    '/match/unmatch/$employeeId/$companyId';
