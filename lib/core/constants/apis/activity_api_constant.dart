/// Counts for the settings page's Activity rows.
///
/// The favourite and application *lists* are read elsewhere; these are the
/// cheap numbers the rows need.
library;


/// How many profiles the viewer has saved. The favourites screen loads the
/// list; the settings row only needs the number.
String apiEmployeeFavoriteCount(String employeeId) =>
    '/user/employee/count-favorite/$employeeId';
String apiCompanyFavoriteCount(String companyId) =>
    '/user/company/count-favorite/$companyId';

/// The viewer's own applications. There is no count route, so the list is
/// fetched and counted.
const String apiMyApplications = '/job/application/mine';
