/// The viewer's own job applications.
///
/// Employee-side only. The pipeline, status changes, notes and history routes
/// are company-only — `/job/application/:id/history` answers an employee with
/// 403 — and belong to a screen that does not exist here yet.
library;

const String apiMyApplications = '/job/application/mine';

/// Applying takes `{jobId, coverLetterNote?}`.
///
/// One application per (employee, job): applying while one is already active
/// answers 409, and applying after a withdrawal **revives that same row**
/// rather than inserting a second.
const String apiApplyToJob = '/job/application';

/// DELETE withdraws; it does not erase the application.
String apiWithdrawApplication(String applicationId) =>
    '/job/application/$applicationId';
