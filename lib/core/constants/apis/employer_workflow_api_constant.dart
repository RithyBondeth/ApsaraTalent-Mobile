library;

String apiJobPipeline(String jobId, String companyId) =>
    '/job/application/pipeline/job/$jobId/company/$companyId';
const String apiUpdateApplicationStatus = '/job/application/status';
const String apiBulkUpdateApplicationStatus = '/job/application/bulk-status';
String apiApplicationNotes(String applicationId) =>
    '/job/application/$applicationId/notes';
String apiApplicationNote(String applicationId, String noteId) =>
    '/job/application/$applicationId/notes/$noteId';
String apiApplicationHistory(String applicationId) =>
    '/job/application/$applicationId/history';
const String apiEmployerAnalytics = '/job/employer-analytics';
String apiCompanyInterviews(String companyId) =>
    '/match/interview/company/$companyId';
const String apiInterview = '/match/interview';
const String apiInterviewStatus = '/match/interview/status';
