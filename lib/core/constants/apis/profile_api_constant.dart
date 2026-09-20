/// The signed-in user's own profile. Both take a profile id — the employee's
/// or company's own — never the user id. See `CurrentUserEntity.profileId`.
library;

String apiEmployeeProfile(String employeeId) => '/user/employee/one/$employeeId';
String apiCompanyProfile(String companyId) => '/user/company/one/$companyId';
