/// The signed-in user's own profile. Both take a profile id — the employee's
/// or company's own — never the user id. See `CurrentUserEntity.profileId`.
library;

String apiEmployeeProfile(String employeeId) => '/user/employee/one/$employeeId';
String apiCompanyProfile(String companyId) => '/user/company/one/$companyId';

/// A **partial** update: the service `Object.assign`s whatever keys arrive, so
/// an omitted field is left as it was rather than cleared.
String apiUpdateEmployee(String employeeId) =>
    '/user/employee/update-info/$employeeId';
String apiUpdateCompany(String companyId) =>
    '/user/company/update-info/$companyId';
