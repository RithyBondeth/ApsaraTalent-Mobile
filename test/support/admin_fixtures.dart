Map<String, dynamic> adminUser({String id = 'candidate-1'}) => {
      'id': id,
      'name': 'Candidate One',
      'email': 'candidate@example.test',
      'phone': null,
      'avatar': null,
      'role': 'employee',
      'status': 'active',
      'storedStatus': 'active',
      'suspendedUntil': null,
      'statusReason': null,
      'isEmailVerified': true,
      'profileCompleted': true,
      'lastLoginAt': null,
      'createdAt': '2026-10-08T00:00:00Z',
      'openReportCount': 1,
    };
Map<String, dynamic> adminUserDetail() => {
      ...adminUser(),
      'employeeId': 'employee-1',
      'companyId': null,
      'lastLoginMethod': 'email',
      'reportsAgainst': <dynamic>[],
      'statusHistory': <dynamic>[],
    };
Map<String, dynamic> adminJob() => {
      'id': 'job-1',
      'title': 'Software Engineer',
      'companyId': 'company-1',
      'companyName': 'Company One',
      'location': 'Phnom Penh',
      'type': 'full_time',
      'createdAt': '2026-10-08T00:00:00Z',
      'expireDate': null,
      'hiddenAt': null,
      'hiddenReason': null,
      'companyOpenReportCount': 0,
    };
Map<String, dynamic> adminReport() => {
      'id': 'report-1',
      'reason': 'spam',
      'details': 'Repeated unsolicited messages',
      'status': 'pending',
      'createdAt': '2026-10-08T00:00:00Z',
      'reporter': null,
      'reported': null,
    };
Map<String, dynamic> adminProblem() => {
      'id': 'problem-1',
      'category': 'bug',
      'details': 'The upload failed.',
      'status': 'pending',
      'createdAt': '2026-10-08T00:00:00Z',
      'reporter': null,
      'pageUrl': '/resume-builder',
      'userAgent': 'Flutter',
      'resolutionNote': null,
    };
Map<String, dynamic> adminAudit() => {
      'id': 'audit-1',
      'action': 'job_hidden',
      'actorEmail': 'admin@example.test',
      'targetUserId': null,
      'targetReportId': null,
      'reason': 'A detailed moderation reason',
      'metadata': {'jobId': 'job-1'},
      'createdAt': '2026-10-08T00:00:00Z',
    };
Map<String, dynamic> adminPage(List<Map<String, dynamic>> items,
        {int page = 1, int total = 1}) =>
    {'items': items, 'total': total, 'page': page, 'limit': 25};
