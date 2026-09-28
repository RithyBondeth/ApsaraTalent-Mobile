/// The signed-in user's own profile. Both take a profile id — the employee's
/// or company's own — never the user id. See `CurrentUserEntity.profileId`.
library;

String apiEmployeeProfile(String employeeId) =>
    '/user/employee/one/$employeeId';
String apiCompanyProfile(String companyId) => '/user/company/one/$companyId';

/// A **partial** update: the service `Object.assign`s whatever keys arrive, so
/// an omitted field is left as it was rather than cleared.
String apiUpdateEmployee(String employeeId) =>
    '/user/employee/update-info/$employeeId';
String apiUpdateCompany(String companyId) =>
    '/user/company/update-info/$companyId';

String apiUploadEmployeeAvatar(String id) => '/user/employee/upload-avatar/$id';
String apiRemoveEmployeeAvatar(String id) => '/user/employee/remove-avatar/$id';
String apiUploadEmployeeResume(String id) => '/user/employee/upload-resume/$id';
String apiRemoveEmployeeResume(String id) => '/user/employee/remove-resume/$id';
String apiUploadEmployeeCoverLetter(String id) =>
    '/user/employee/upload-cover-letter/$id';
String apiRemoveEmployeeCoverLetter(String id) =>
    '/user/employee/remove-cover-letter/$id';
String apiEmployeeDocument(String id, String type) =>
    '/user/employee/$id/document/$type';

String apiUploadCompanyAvatar(String id) => '/user/company/upload-avatar/$id';
String apiRemoveCompanyAvatar(String id) => '/user/company/remove-avatar/$id';
String apiUploadCompanyCover(String id) => '/user/company/upload-cover/$id';
String apiRemoveCompanyCover(String id) => '/user/company/remove-cover/$id';
String apiUploadCompanyImages(String id) => '/user/company/upload-images/$id';
String apiRemoveCompanyImage(String companyId, String imageId) =>
    '/user/company/remove-images/$companyId/$imageId';
