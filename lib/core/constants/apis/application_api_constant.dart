/// The viewer's own job applications.
///
/// Employee-side only. The pipeline, status changes, notes and history routes
/// are company-only — `/job/application/:id/history` answers an employee with
/// 403 — and belong to a screen that does not exist here yet.
library;

const String apiMyApplications = '/job/application/mine';

/// DELETE withdraws; it does not erase the application.
String apiWithdrawApplication(String applicationId) =>
    '/job/application/$applicationId';
