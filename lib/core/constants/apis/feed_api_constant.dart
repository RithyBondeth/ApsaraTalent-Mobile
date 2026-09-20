/// Endpoints behind the feed. Every id is a profile id (employee or company),
/// never the user id — see `CurrentUserEntity.profileId`.
const String apiCompaniesAll = '/user/company/all';
const String apiEmployeesAll = '/user/employee/all';
const String apiHiddenProfileIds = '/user/moderation/hidden-ids';
const String apiNotificationUnreadCount = '/notification/unread-count';

String apiEmployeeRecommendations(String employeeId) =>
    '/user/recommendation/employee/$employeeId';
String apiCompanyRecommendations(String companyId) =>
    '/user/recommendation/company/$companyId';

String apiEmployeeLiked(String employeeId) =>
    '/match/current-employee-liked/$employeeId';
String apiCompanyLiked(String companyId) =>
    '/match/current-company-liked/$companyId';

String apiEmployeeLikesCompany(String employeeId, String companyId) =>
    '/match/employee/$employeeId/like/$companyId';
String apiCompanyLikesEmployee(String companyId, String employeeId) =>
    '/match/company/$companyId/like/$employeeId';

String apiEmployeeFavorites(String employeeId) =>
    '/user/employee/all-favorites/$employeeId';
String apiCompanyFavorites(String companyId) =>
    '/user/company/all-favorites/$companyId';

String apiEmployeeFavoriteCompany(String employeeId, String companyId) =>
    '/user/employee/$employeeId/favorite/company/$companyId';
String apiCompanyFavoriteEmployee(String companyId, String employeeId) =>
    '/user/company/$companyId/favorite/employee/$employeeId';

// Unfavourite is a POST on the API, not a DELETE.
String apiEmployeeUnfavoriteCompany(
  String employeeId,
  String companyId,
  String favoriteId,
) =>
    '/user/employee/$employeeId/unfavorite/$favoriteId/company/$companyId';
String apiCompanyUnfavoriteEmployee(
  String companyId,
  String employeeId,
  String favoriteId,
) =>
    '/user/company/$companyId/unfavorite/$favoriteId/employee/$employeeId';
