// Generated from contracts/openapi.json. Do not edit.
// SHA256: 0f7d2dd52bfa8eea914a601d5b0f99631f2957eb36ce2842a8cf6dc693c9ef54
import 'package:dio/dio.dart';
import '../api_client.dart';

class ApiAdminActionResponseDTO {
  const ApiAdminActionResponseDTO({required this.message});
  final String message;
  factory ApiAdminActionResponseDTO.fromJson(Map<String, dynamic> json) => ApiAdminActionResponseDTO(
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
  };
}

class ApiAdminAuditEntryDTO {
  const ApiAdminAuditEntryDTO({required this.action, required this.actorEmail, required this.createdAt, required this.id, required this.metadata, required this.reason, required this.targetReportId, required this.targetUserId});
  final String action;
  final String? actorEmail;
  final String createdAt;
  final String id;
  final Map<String, dynamic>? metadata;
  final String? reason;
  final String? targetReportId;
  final String? targetUserId;
  factory ApiAdminAuditEntryDTO.fromJson(Map<String, dynamic> json) => ApiAdminAuditEntryDTO(
    action: json["action"] as String,
    actorEmail: json["actorEmail"] == null ? null : json["actorEmail"] as String,
    createdAt: json["createdAt"] as String,
    id: json["id"] as String,
    metadata: json["metadata"] == null ? null : Map<String, dynamic>.from(json["metadata"] as Map),
    reason: json["reason"] == null ? null : json["reason"] as String,
    targetReportId: json["targetReportId"] == null ? null : json["targetReportId"] as String,
    targetUserId: json["targetUserId"] == null ? null : json["targetUserId"] as String,
  );
  Map<String, dynamic> toJson() => {
    "action": action,
    if (actorEmail != null) "actorEmail": actorEmail!,
    "createdAt": createdAt,
    "id": id,
    if (metadata != null) "metadata": metadata!,
    if (reason != null) "reason": reason!,
    if (targetReportId != null) "targetReportId": targetReportId!,
    if (targetUserId != null) "targetUserId": targetUserId!,
  };
}

class ApiAdminHideJobBodyDTO {
  const ApiAdminHideJobBodyDTO({required this.reason});
  final String reason;
  factory ApiAdminHideJobBodyDTO.fromJson(Map<String, dynamic> json) => ApiAdminHideJobBodyDTO(
    reason: json["reason"] as String,
  );
  Map<String, dynamic> toJson() => {
    "reason": reason,
  };
}

class ApiAdminJobListItemDTO {
  const ApiAdminJobListItemDTO({required this.companyId, required this.companyName, required this.companyOpenReportCount, required this.createdAt, required this.expireDate, required this.hiddenAt, required this.hiddenReason, required this.id, required this.location, required this.title, required this.type});
  final String? companyId;
  final String companyName;
  final num companyOpenReportCount;
  final String createdAt;
  final String? expireDate;
  final String? hiddenAt;
  final String? hiddenReason;
  final String id;
  final String? location;
  final String title;
  final String type;
  factory ApiAdminJobListItemDTO.fromJson(Map<String, dynamic> json) => ApiAdminJobListItemDTO(
    companyId: json["companyId"] == null ? null : json["companyId"] as String,
    companyName: json["companyName"] as String,
    companyOpenReportCount: json["companyOpenReportCount"] as num,
    createdAt: json["createdAt"] as String,
    expireDate: json["expireDate"] == null ? null : json["expireDate"] as String,
    hiddenAt: json["hiddenAt"] == null ? null : json["hiddenAt"] as String,
    hiddenReason: json["hiddenReason"] == null ? null : json["hiddenReason"] as String,
    id: json["id"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    title: json["title"] as String,
    type: json["type"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (companyId != null) "companyId": companyId!,
    "companyName": companyName,
    "companyOpenReportCount": companyOpenReportCount,
    "createdAt": createdAt,
    if (expireDate != null) "expireDate": expireDate!,
    if (hiddenAt != null) "hiddenAt": hiddenAt!,
    if (hiddenReason != null) "hiddenReason": hiddenReason!,
    "id": id,
    if (location != null) "location": location!,
    "title": title,
    "type": type,
  };
}

class ApiAdminOverviewDTO {
  const ApiAdminOverviewDTO({required this.bannedUsers, required this.companies, required this.employees, required this.hiddenJobs, required this.liveJobs, required this.newUsersLast7Days, required this.pendingReports, required this.suspendedUsers, required this.totalUsers});
  final num bannedUsers;
  final num companies;
  final num employees;
  final num hiddenJobs;
  final num liveJobs;
  final num newUsersLast7Days;
  final num pendingReports;
  final num suspendedUsers;
  final num totalUsers;
  factory ApiAdminOverviewDTO.fromJson(Map<String, dynamic> json) => ApiAdminOverviewDTO(
    bannedUsers: json["bannedUsers"] as num,
    companies: json["companies"] as num,
    employees: json["employees"] as num,
    hiddenJobs: json["hiddenJobs"] as num,
    liveJobs: json["liveJobs"] as num,
    newUsersLast7Days: json["newUsersLast7Days"] as num,
    pendingReports: json["pendingReports"] as num,
    suspendedUsers: json["suspendedUsers"] as num,
    totalUsers: json["totalUsers"] as num,
  );
  Map<String, dynamic> toJson() => {
    "bannedUsers": bannedUsers,
    "companies": companies,
    "employees": employees,
    "hiddenJobs": hiddenJobs,
    "liveJobs": liveJobs,
    "newUsersLast7Days": newUsersLast7Days,
    "pendingReports": pendingReports,
    "suspendedUsers": suspendedUsers,
    "totalUsers": totalUsers,
  };
}

class ApiAdminPagedAuditDTO {
  const ApiAdminPagedAuditDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiAdminAuditEntryDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiAdminPagedAuditDTO.fromJson(Map<String, dynamic> json) => ApiAdminPagedAuditDTO(
    items: (json["items"] as List).map((v) => ApiAdminAuditEntryDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiAdminPagedJobsDTO {
  const ApiAdminPagedJobsDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiAdminJobListItemDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiAdminPagedJobsDTO.fromJson(Map<String, dynamic> json) => ApiAdminPagedJobsDTO(
    items: (json["items"] as List).map((v) => ApiAdminJobListItemDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiAdminPagedProblemReportsDTO {
  const ApiAdminPagedProblemReportsDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiAdminProblemReportDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiAdminPagedProblemReportsDTO.fromJson(Map<String, dynamic> json) => ApiAdminPagedProblemReportsDTO(
    items: (json["items"] as List).map((v) => ApiAdminProblemReportDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiAdminPagedReportsDTO {
  const ApiAdminPagedReportsDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiAdminReportDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiAdminPagedReportsDTO.fromJson(Map<String, dynamic> json) => ApiAdminPagedReportsDTO(
    items: (json["items"] as List).map((v) => ApiAdminReportDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiAdminPagedUsersDTO {
  const ApiAdminPagedUsersDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiAdminUserListItemDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiAdminPagedUsersDTO.fromJson(Map<String, dynamic> json) => ApiAdminPagedUsersDTO(
    items: (json["items"] as List).map((v) => ApiAdminUserListItemDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiAdminProblemReportDTO {
  const ApiAdminProblemReportDTO({required this.category, required this.createdAt, required this.details, required this.id, required this.pageUrl, required this.reporter, required this.resolutionNote, required this.status, required this.userAgent});
  final String category;
  final String createdAt;
  final String details;
  final String id;
  final String? pageUrl;
  final Map<String, dynamic>? reporter;
  final String? resolutionNote;
  final String status;
  final String? userAgent;
  factory ApiAdminProblemReportDTO.fromJson(Map<String, dynamic> json) => ApiAdminProblemReportDTO(
    category: json["category"] as String,
    createdAt: json["createdAt"] as String,
    details: json["details"] as String,
    id: json["id"] as String,
    pageUrl: json["pageUrl"] == null ? null : json["pageUrl"] as String,
    reporter: json["reporter"] == null ? null : Map<String, dynamic>.from(json["reporter"] as Map),
    resolutionNote: json["resolutionNote"] == null ? null : json["resolutionNote"] as String,
    status: json["status"] as String,
    userAgent: json["userAgent"] == null ? null : json["userAgent"] as String,
  );
  Map<String, dynamic> toJson() => {
    "category": category,
    "createdAt": createdAt,
    "details": details,
    "id": id,
    if (pageUrl != null) "pageUrl": pageUrl!,
    if (reporter != null) "reporter": reporter!,
    if (resolutionNote != null) "resolutionNote": resolutionNote!,
    "status": status,
    if (userAgent != null) "userAgent": userAgent!,
  };
}

class ApiAdminProblemReportReporterDTO {
  const ApiAdminProblemReportReporterDTO({required this.email, required this.id, required this.role});
  final String email;
  final String id;
  final String role;
  factory ApiAdminProblemReportReporterDTO.fromJson(Map<String, dynamic> json) => ApiAdminProblemReportReporterDTO(
    email: json["email"] as String,
    id: json["id"] as String,
    role: json["role"] as String,
  );
  Map<String, dynamic> toJson() => {
    "email": email,
    "id": id,
    "role": role,
  };
}

class ApiAdminReportDTO {
  const ApiAdminReportDTO({required this.createdAt, required this.details, required this.id, required this.reason, required this.reported, required this.reporter, required this.status});
  final String createdAt;
  final String? details;
  final String id;
  final String reason;
  final Map<String, dynamic>? reported;
  final Map<String, dynamic>? reporter;
  final String status;
  factory ApiAdminReportDTO.fromJson(Map<String, dynamic> json) => ApiAdminReportDTO(
    createdAt: json["createdAt"] as String,
    details: json["details"] == null ? null : json["details"] as String,
    id: json["id"] as String,
    reason: json["reason"] as String,
    reported: json["reported"] == null ? null : Map<String, dynamic>.from(json["reported"] as Map),
    reporter: json["reporter"] == null ? null : Map<String, dynamic>.from(json["reporter"] as Map),
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    if (details != null) "details": details!,
    "id": id,
    "reason": reason,
    if (reported != null) "reported": reported!,
    if (reporter != null) "reporter": reporter!,
    "status": status,
  };
}

class ApiAdminReportPartyDTO {
  const ApiAdminReportPartyDTO({required this.email, required this.id, required this.name, required this.role});
  final String? email;
  final String id;
  final String name;
  final String role;
  factory ApiAdminReportPartyDTO.fromJson(Map<String, dynamic> json) => ApiAdminReportPartyDTO(
    email: json["email"] == null ? null : json["email"] as String,
    id: json["id"] as String,
    name: json["name"] as String,
    role: json["role"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (email != null) "email": email!,
    "id": id,
    "name": name,
    "role": role,
  };
}

class ApiAdminUpdateProblemReportStatusBodyDTO {
  const ApiAdminUpdateProblemReportStatusBodyDTO({this.note, required this.status});
  final String? note;
  final String status;
  factory ApiAdminUpdateProblemReportStatusBodyDTO.fromJson(Map<String, dynamic> json) => ApiAdminUpdateProblemReportStatusBodyDTO(
    note: json["note"] == null ? null : json["note"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (note != null) "note": note!,
    "status": status,
  };
}

class ApiAdminUpdateReportStatusBodyDTO {
  const ApiAdminUpdateReportStatusBodyDTO({this.note, required this.status});
  final String? note;
  final String status;
  factory ApiAdminUpdateReportStatusBodyDTO.fromJson(Map<String, dynamic> json) => ApiAdminUpdateReportStatusBodyDTO(
    note: json["note"] == null ? null : json["note"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (note != null) "note": note!,
    "status": status,
  };
}

class ApiAdminUpdateUserStatusBodyDTO {
  const ApiAdminUpdateUserStatusBodyDTO({required this.reason, required this.status, this.suspendedUntil});
  final String reason;
  final String status;
  final String? suspendedUntil;
  factory ApiAdminUpdateUserStatusBodyDTO.fromJson(Map<String, dynamic> json) => ApiAdminUpdateUserStatusBodyDTO(
    reason: json["reason"] as String,
    status: json["status"] as String,
    suspendedUntil: json["suspendedUntil"] == null ? null : json["suspendedUntil"] as String,
  );
  Map<String, dynamic> toJson() => {
    "reason": reason,
    "status": status,
    if (suspendedUntil != null) "suspendedUntil": suspendedUntil!,
  };
}

class ApiAdminUserDetailDTO {
  const ApiAdminUserDetailDTO({required this.avatar, required this.companyId, required this.createdAt, required this.email, required this.employeeId, required this.id, required this.isEmailVerified, required this.lastLoginAt, required this.lastLoginMethod, required this.name, required this.openReportCount, required this.phone, required this.profileCompleted, required this.reportsAgainst, required this.role, required this.status, required this.statusHistory, required this.statusReason, required this.storedStatus, required this.suspendedUntil});
  final String? avatar;
  final String? companyId;
  final String createdAt;
  final String? email;
  final String? employeeId;
  final String id;
  final bool isEmailVerified;
  final String? lastLoginAt;
  final String? lastLoginMethod;
  final String name;
  final num openReportCount;
  final String? phone;
  final bool profileCompleted;
  final List<ApiAdminReportDTO> reportsAgainst;
  final String role;
  final String status;
  final List<ApiAdminAuditEntryDTO> statusHistory;
  final String? statusReason;
  final String storedStatus;
  final String? suspendedUntil;
  factory ApiAdminUserDetailDTO.fromJson(Map<String, dynamic> json) => ApiAdminUserDetailDTO(
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    companyId: json["companyId"] == null ? null : json["companyId"] as String,
    createdAt: json["createdAt"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    employeeId: json["employeeId"] == null ? null : json["employeeId"] as String,
    id: json["id"] as String,
    isEmailVerified: json["isEmailVerified"] as bool,
    lastLoginAt: json["lastLoginAt"] == null ? null : json["lastLoginAt"] as String,
    lastLoginMethod: json["lastLoginMethod"] == null ? null : json["lastLoginMethod"] as String,
    name: json["name"] as String,
    openReportCount: json["openReportCount"] as num,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profileCompleted: json["profileCompleted"] as bool,
    reportsAgainst: (json["reportsAgainst"] as List).map((v) => ApiAdminReportDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    role: json["role"] as String,
    status: json["status"] as String,
    statusHistory: (json["statusHistory"] as List).map((v) => ApiAdminAuditEntryDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    statusReason: json["statusReason"] == null ? null : json["statusReason"] as String,
    storedStatus: json["storedStatus"] as String,
    suspendedUntil: json["suspendedUntil"] == null ? null : json["suspendedUntil"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    if (companyId != null) "companyId": companyId!,
    "createdAt": createdAt,
    if (email != null) "email": email!,
    if (employeeId != null) "employeeId": employeeId!,
    "id": id,
    "isEmailVerified": isEmailVerified,
    if (lastLoginAt != null) "lastLoginAt": lastLoginAt!,
    if (lastLoginMethod != null) "lastLoginMethod": lastLoginMethod!,
    "name": name,
    "openReportCount": openReportCount,
    if (phone != null) "phone": phone!,
    "profileCompleted": profileCompleted,
    "reportsAgainst": reportsAgainst.map((v) => v.toJson()).toList(),
    "role": role,
    "status": status,
    "statusHistory": statusHistory.map((v) => v.toJson()).toList(),
    if (statusReason != null) "statusReason": statusReason!,
    "storedStatus": storedStatus,
    if (suspendedUntil != null) "suspendedUntil": suspendedUntil!,
  };
}

class ApiAdminUserListItemDTO {
  const ApiAdminUserListItemDTO({required this.avatar, required this.createdAt, required this.email, required this.id, required this.isEmailVerified, required this.lastLoginAt, required this.name, required this.openReportCount, required this.phone, required this.profileCompleted, required this.role, required this.status, required this.statusReason, required this.storedStatus, required this.suspendedUntil});
  final String? avatar;
  final String createdAt;
  final String? email;
  final String id;
  final bool isEmailVerified;
  final String? lastLoginAt;
  final String name;
  final num openReportCount;
  final String? phone;
  final bool profileCompleted;
  final String role;
  final String status;
  final String? statusReason;
  final String storedStatus;
  final String? suspendedUntil;
  factory ApiAdminUserListItemDTO.fromJson(Map<String, dynamic> json) => ApiAdminUserListItemDTO(
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    createdAt: json["createdAt"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    id: json["id"] as String,
    isEmailVerified: json["isEmailVerified"] as bool,
    lastLoginAt: json["lastLoginAt"] == null ? null : json["lastLoginAt"] as String,
    name: json["name"] as String,
    openReportCount: json["openReportCount"] as num,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profileCompleted: json["profileCompleted"] as bool,
    role: json["role"] as String,
    status: json["status"] as String,
    statusReason: json["statusReason"] == null ? null : json["statusReason"] as String,
    storedStatus: json["storedStatus"] as String,
    suspendedUntil: json["suspendedUntil"] == null ? null : json["suspendedUntil"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    "createdAt": createdAt,
    if (email != null) "email": email!,
    "id": id,
    "isEmailVerified": isEmailVerified,
    if (lastLoginAt != null) "lastLoginAt": lastLoginAt!,
    "name": name,
    "openReportCount": openReportCount,
    if (phone != null) "phone": phone!,
    "profileCompleted": profileCompleted,
    "role": role,
    "status": status,
    if (statusReason != null) "statusReason": statusReason!,
    "storedStatus": storedStatus,
    if (suspendedUntil != null) "suspendedUntil": suspendedUntil!,
  };
}

class ApiAiInterviewPrepQuestion {
  const ApiAiInterviewPrepQuestion({required this.category, required this.question, required this.questionKm, required this.tip, required this.tipKm});
  final String category;
  final String question;
  final String questionKm;
  final String tip;
  final String tipKm;
  factory ApiAiInterviewPrepQuestion.fromJson(Map<String, dynamic> json) => ApiAiInterviewPrepQuestion(
    category: json["category"] as String,
    question: json["question"] as String,
    questionKm: json["questionKm"] as String,
    tip: json["tip"] as String,
    tipKm: json["tipKm"] as String,
  );
  Map<String, dynamic> toJson() => {
    "category": category,
    "question": question,
    "questionKm": questionKm,
    "tip": tip,
    "tipKm": tipKm,
  };
}

class ApiAiInterviewPrepResponseDTO {
  const ApiAiInterviewPrepResponseDTO({required this.questions});
  final List<ApiAiInterviewPrepQuestion> questions;
  factory ApiAiInterviewPrepResponseDTO.fromJson(Map<String, dynamic> json) => ApiAiInterviewPrepResponseDTO(
    questions: (json["questions"] as List).map((v) => ApiAiInterviewPrepQuestion.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
  );
  Map<String, dynamic> toJson() => {
    "questions": questions.map((v) => v.toJson()).toList(),
  };
}

class ApiAiMatchExplanationResponseDTO {
  const ApiAiMatchExplanationResponseDTO({required this.explanation, required this.gaps, required this.score, required this.strengths, required this.verdict});
  final String explanation;
  final List<String> gaps;
  final num score;
  final List<String> strengths;
  final String verdict;
  factory ApiAiMatchExplanationResponseDTO.fromJson(Map<String, dynamic> json) => ApiAiMatchExplanationResponseDTO(
    explanation: json["explanation"] as String,
    gaps: (json["gaps"] as List).map((v) => v as String).toList(),
    score: json["score"] as num,
    strengths: (json["strengths"] as List).map((v) => v as String).toList(),
    verdict: json["verdict"] as String,
  );
  Map<String, dynamic> toJson() => {
    "explanation": explanation,
    "gaps": gaps.map((v) => v).toList(),
    "score": score,
    "strengths": strengths.map((v) => v).toList(),
    "verdict": verdict,
  };
}

class ApiApplicationNoteResponseDTO {
  const ApiApplicationNoteResponseDTO({required this.applicationId, required this.authorId, required this.authorName, required this.body, required this.createdAt, required this.id});
  final String applicationId;
  final String? authorId;
  final String? authorName;
  final String body;
  final String createdAt;
  final String id;
  factory ApiApplicationNoteResponseDTO.fromJson(Map<String, dynamic> json) => ApiApplicationNoteResponseDTO(
    applicationId: json["applicationId"] as String,
    authorId: json["authorId"] == null ? null : json["authorId"] as String,
    authorName: json["authorName"] == null ? null : json["authorName"] as String,
    body: json["body"] as String,
    createdAt: json["createdAt"] as String,
    id: json["id"] as String,
  );
  Map<String, dynamic> toJson() => {
    "applicationId": applicationId,
    if (authorId != null) "authorId": authorId!,
    if (authorName != null) "authorName": authorName!,
    "body": body,
    "createdAt": createdAt,
    "id": id,
  };
}

class ApiApplicationStatusHistoryEntryDTO {
  const ApiApplicationStatusHistoryEntryDTO({required this.actorId, required this.actorName, required this.applicationId, required this.createdAt, required this.from, required this.id, required this.note, required this.to});
  final String? actorId;
  final String? actorName;
  final String applicationId;
  final String createdAt;
  final String? from;
  final String id;
  final String? note;
  final String to;
  factory ApiApplicationStatusHistoryEntryDTO.fromJson(Map<String, dynamic> json) => ApiApplicationStatusHistoryEntryDTO(
    actorId: json["actorId"] == null ? null : json["actorId"] as String,
    actorName: json["actorName"] == null ? null : json["actorName"] as String,
    applicationId: json["applicationId"] as String,
    createdAt: json["createdAt"] as String,
    from: json["from"] == null ? null : json["from"] as String,
    id: json["id"] as String,
    note: json["note"] == null ? null : json["note"] as String,
    to: json["to"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (actorId != null) "actorId": actorId!,
    if (actorName != null) "actorName": actorName!,
    "applicationId": applicationId,
    "createdAt": createdAt,
    if (from != null) "from": from!,
    "id": id,
    if (note != null) "note": note!,
    "to": to,
  };
}

class ApiApplyApplicationDTO {
  const ApiApplyApplicationDTO({this.coverLetterNote, required this.jobId});
  final String? coverLetterNote;
  final String jobId;
  factory ApiApplyApplicationDTO.fromJson(Map<String, dynamic> json) => ApiApplyApplicationDTO(
    coverLetterNote: json["coverLetterNote"] == null ? null : json["coverLetterNote"] as String,
    jobId: json["jobId"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (coverLetterNote != null) "coverLetterNote": coverLetterNote!,
    "jobId": jobId,
  };
}

class ApiApplyApplicationResponseDTO {
  const ApiApplyApplicationResponseDTO({required this.appliedAt, this.coverLetterNote, this.employeeId, this.employeeName, required this.id, this.jobId, this.jobTitle, this.matchScore, this.rejectionReason, this.reviewedAt, required this.status, this.statusChangedAt});
  final String appliedAt;
  final String? coverLetterNote;
  final String? employeeId;
  final String? employeeName;
  final String id;
  final String? jobId;
  final String? jobTitle;
  final num? matchScore;
  final String? rejectionReason;
  final String? reviewedAt;
  final String status;
  final String? statusChangedAt;
  factory ApiApplyApplicationResponseDTO.fromJson(Map<String, dynamic> json) => ApiApplyApplicationResponseDTO(
    appliedAt: json["appliedAt"] as String,
    coverLetterNote: json["coverLetterNote"] == null ? null : json["coverLetterNote"] as String,
    employeeId: json["employeeId"] == null ? null : json["employeeId"] as String,
    employeeName: json["employeeName"] == null ? null : json["employeeName"] as String,
    id: json["id"] as String,
    jobId: json["jobId"] == null ? null : json["jobId"] as String,
    jobTitle: json["jobTitle"] == null ? null : json["jobTitle"] as String,
    matchScore: json["matchScore"] == null ? null : json["matchScore"] as num,
    rejectionReason: json["rejectionReason"] == null ? null : json["rejectionReason"] as String,
    reviewedAt: json["reviewedAt"] == null ? null : json["reviewedAt"] as String,
    status: json["status"] as String,
    statusChangedAt: json["statusChangedAt"] == null ? null : json["statusChangedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "appliedAt": appliedAt,
    if (coverLetterNote != null) "coverLetterNote": coverLetterNote!,
    if (employeeId != null) "employeeId": employeeId!,
    if (employeeName != null) "employeeName": employeeName!,
    "id": id,
    if (jobId != null) "jobId": jobId!,
    if (jobTitle != null) "jobTitle": jobTitle!,
    if (matchScore != null) "matchScore": matchScore!,
    if (rejectionReason != null) "rejectionReason": rejectionReason!,
    if (reviewedAt != null) "reviewedAt": reviewedAt!,
    "status": status,
    if (statusChangedAt != null) "statusChangedAt": statusChangedAt!,
  };
}

class ApiBlockActionResponseDTO {
  const ApiBlockActionResponseDTO({required this.blocked, required this.message});
  final bool blocked;
  final String message;
  factory ApiBlockActionResponseDTO.fromJson(Map<String, dynamic> json) => ApiBlockActionResponseDTO(
    blocked: json["blocked"] as bool,
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "blocked": blocked,
    "message": message,
  };
}

class ApiBlockStatusResponseDTO {
  const ApiBlockStatusResponseDTO({required this.blockedByMe, required this.blockedMe, required this.isBlocked});
  final bool blockedByMe;
  final bool blockedMe;
  final bool isBlocked;
  factory ApiBlockStatusResponseDTO.fromJson(Map<String, dynamic> json) => ApiBlockStatusResponseDTO(
    blockedByMe: json["blockedByMe"] as bool,
    blockedMe: json["blockedMe"] as bool,
    isBlocked: json["isBlocked"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "blockedByMe": blockedByMe,
    "blockedMe": blockedMe,
    "isBlocked": isBlocked,
  };
}

class ApiBlockedUserResponseDTO {
  const ApiBlockedUserResponseDTO({required this.avatar, required this.blockedAt, required this.companyId, required this.employeeId, required this.id, required this.name, required this.role});
  final String? avatar;
  final String blockedAt;
  final String? companyId;
  final String? employeeId;
  final String id;
  final String name;
  final String role;
  factory ApiBlockedUserResponseDTO.fromJson(Map<String, dynamic> json) => ApiBlockedUserResponseDTO(
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    blockedAt: json["blockedAt"] as String,
    companyId: json["companyId"] == null ? null : json["companyId"] as String,
    employeeId: json["employeeId"] == null ? null : json["employeeId"] as String,
    id: json["id"] as String,
    name: json["name"] as String,
    role: json["role"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    "blockedAt": blockedAt,
    if (companyId != null) "companyId": companyId!,
    if (employeeId != null) "employeeId": employeeId!,
    "id": id,
    "name": name,
    "role": role,
  };
}

class ApiBuildResumeDTO {
  const ApiBuildResumeDTO({this.availability, this.careerScopes, this.design, this.education, required this.experience, required this.personalInfo, this.sectionOrder, required this.skills, this.summary, required this.template, this.yearsOfExperience});
  final String? availability;
  final List<String>? careerScopes;
  final ApiResumeDesignDTO? design;
  final String? education;
  final List<ApiResumeExperienceDTO> experience;
  final ApiPersonalInfoDTO personalInfo;
  final List<String>? sectionOrder;
  final List<String> skills;
  final String? summary;
  final String template;
  final String? yearsOfExperience;
  factory ApiBuildResumeDTO.fromJson(Map<String, dynamic> json) => ApiBuildResumeDTO(
    availability: json["availability"] == null ? null : json["availability"] as String,
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => v as String).toList(),
    design: json["design"] == null ? null : ApiResumeDesignDTO.fromJson(Map<String, dynamic>.from(json["design"] as Map)),
    education: json["education"] == null ? null : json["education"] as String,
    experience: (json["experience"] as List).map((v) => ApiResumeExperienceDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    personalInfo: ApiPersonalInfoDTO.fromJson(Map<String, dynamic>.from(json["personalInfo"] as Map)),
    sectionOrder: json["sectionOrder"] == null ? null : (json["sectionOrder"] as List).map((v) => v as String).toList(),
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    summary: json["summary"] == null ? null : json["summary"] as String,
    template: json["template"] as String,
    yearsOfExperience: json["yearsOfExperience"] == null ? null : json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (availability != null) "availability": availability!,
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v).toList(),
    if (design != null) "design": design!.toJson(),
    if (education != null) "education": education!,
    "experience": experience.map((v) => v.toJson()).toList(),
    "personalInfo": personalInfo.toJson(),
    if (sectionOrder != null) "sectionOrder": sectionOrder!.map((v) => v).toList(),
    "skills": skills.map((v) => v).toList(),
    if (summary != null) "summary": summary!,
    "template": template,
    if (yearsOfExperience != null) "yearsOfExperience": yearsOfExperience!,
  };
}

class ApiBuildResumeResponseDTO {
  const ApiBuildResumeResponseDTO({required this.data, required this.filename, required this.mimeType});
  final String data;
  final String filename;
  final String mimeType;
  factory ApiBuildResumeResponseDTO.fromJson(Map<String, dynamic> json) => ApiBuildResumeResponseDTO(
    data: json["data"] as String,
    filename: json["filename"] as String,
    mimeType: json["mimeType"] as String,
  );
  Map<String, dynamic> toJson() => {
    "data": data,
    "filename": filename,
    "mimeType": mimeType,
  };
}

class ApiBulkUpdateApplicationStatusDTO {
  const ApiBulkUpdateApplicationStatusDTO({required this.applicationIds, this.rejectionReason, required this.status});
  final List<String> applicationIds;
  final String? rejectionReason;
  final String status;
  factory ApiBulkUpdateApplicationStatusDTO.fromJson(Map<String, dynamic> json) => ApiBulkUpdateApplicationStatusDTO(
    applicationIds: (json["applicationIds"] as List).map((v) => v as String).toList(),
    rejectionReason: json["rejectionReason"] == null ? null : json["rejectionReason"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "applicationIds": applicationIds.map((v) => v).toList(),
    if (rejectionReason != null) "rejectionReason": rejectionReason!,
    "status": status,
  };
}

class ApiBulkUpdateApplicationStatusItemResultDTO {
  const ApiBulkUpdateApplicationStatusItemResultDTO({required this.applicationId, required this.ok, required this.reason, required this.status});
  final String applicationId;
  final bool ok;
  final String? reason;
  final String status;
  factory ApiBulkUpdateApplicationStatusItemResultDTO.fromJson(Map<String, dynamic> json) => ApiBulkUpdateApplicationStatusItemResultDTO(
    applicationId: json["applicationId"] as String,
    ok: json["ok"] as bool,
    reason: json["reason"] == null ? null : json["reason"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "applicationId": applicationId,
    "ok": ok,
    if (reason != null) "reason": reason!,
    "status": status,
  };
}

class ApiBulkUpdateApplicationStatusResponseDTO {
  const ApiBulkUpdateApplicationStatusResponseDTO({required this.failedCount, required this.results, required this.updatedCount});
  final num failedCount;
  final List<ApiBulkUpdateApplicationStatusItemResultDTO> results;
  final num updatedCount;
  factory ApiBulkUpdateApplicationStatusResponseDTO.fromJson(Map<String, dynamic> json) => ApiBulkUpdateApplicationStatusResponseDTO(
    failedCount: json["failedCount"] as num,
    results: (json["results"] as List).map((v) => ApiBulkUpdateApplicationStatusItemResultDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    updatedCount: json["updatedCount"] as num,
  );
  Map<String, dynamic> toJson() => {
    "failedCount": failedCount,
    "results": results.map((v) => v.toJson()).toList(),
    "updatedCount": updatedCount,
  };
}

class ApiCancelAccountDeletionResponseDTO {
  const ApiCancelAccountDeletionResponseDTO({required this.message});
  final String message;
  factory ApiCancelAccountDeletionResponseDTO.fromJson(Map<String, dynamic> json) => ApiCancelAccountDeletionResponseDTO(
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
  };
}

class ApiCareerScopesResponseDTO {
  const ApiCareerScopesResponseDTO({this.description, this.id, required this.name});
  final String? description;
  final String? id;
  final String name;
  factory ApiCareerScopesResponseDTO.fromJson(Map<String, dynamic> json) => ApiCareerScopesResponseDTO(
    description: json["description"] == null ? null : json["description"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (id != null) "id": id!,
    "name": name,
  };
}

class ApiCompanyFavoriteEmployeeResponseDTO {
  const ApiCompanyFavoriteEmployeeResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiCompanyFavoriteEmployeeResponseDTO.fromJson(Map<String, dynamic> json) => ApiCompanyFavoriteEmployeeResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiCompanyFavoritesListItemDTO {
  const ApiCompanyFavoritesListItemDTO({required this.createdAt, required this.employee, required this.id, required this.userId});
  final String createdAt;
  final ApiEmployeeResponseDTO employee;
  final String id;
  final String userId;
  factory ApiCompanyFavoritesListItemDTO.fromJson(Map<String, dynamic> json) => ApiCompanyFavoritesListItemDTO(
    createdAt: json["createdAt"] as String,
    employee: ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    userId: json["userId"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "employee": employee.toJson(),
    "id": id,
    "userId": userId,
  };
}

class ApiCompanyInJobResponseDTO {
  const ApiCompanyInJobResponseDTO({required this.avatar, required this.companySize, required this.id, required this.industry, required this.location, required this.name, required this.user});
  final String avatar;
  final num companySize;
  final String id;
  final String industry;
  final String location;
  final String name;
  final ApiUserInJobResponseDTO user;
  factory ApiCompanyInJobResponseDTO.fromJson(Map<String, dynamic> json) => ApiCompanyInJobResponseDTO(
    avatar: json["avatar"] as String,
    companySize: json["companySize"] as num,
    id: json["id"] as String,
    industry: json["industry"] as String,
    location: json["location"] as String,
    name: json["name"] as String,
    user: ApiUserInJobResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    "avatar": avatar,
    "companySize": companySize,
    "id": id,
    "industry": industry,
    "location": location,
    "name": name,
    "user": user.toJson(),
  };
}

class ApiCompanyRegisterDTO {
  const ApiCompanyRegisterDTO({this.authEmail, this.avatar, this.benefits, this.careerScopes, required this.companySize, this.companyType, this.cover, required this.description, required this.email, required this.foundedYear, this.images, required this.industry, this.jobs, required this.location, required this.name, required this.password, required this.phone, this.socials, this.values, this.websiteUrl});
  final bool? authEmail;
  final Map<String, dynamic>? avatar;
  final List<ApiRegisterCompanyBenefitDTO>? benefits;
  final List<ApiRegisterCompanyCareerScopeDTO>? careerScopes;
  final num companySize;
  final String? companyType;
  final Map<String, dynamic>? cover;
  final String description;
  final String email;
  final num foundedYear;
  final List<Map<String, dynamic>>? images;
  final String industry;
  final List<ApiRegisterCompanyJobDTO>? jobs;
  final String location;
  final String name;
  final String password;
  final String phone;
  final List<ApiRegisterCompanySocialDTO>? socials;
  final List<ApiRegisterCompanyValueDTO>? values;
  final String? websiteUrl;
  factory ApiCompanyRegisterDTO.fromJson(Map<String, dynamic> json) => ApiCompanyRegisterDTO(
    authEmail: json["authEmail"] == null ? null : json["authEmail"] as bool,
    avatar: json["avatar"] == null ? null : Map<String, dynamic>.from(json["avatar"] as Map),
    benefits: json["benefits"] == null ? null : (json["benefits"] as List).map((v) => ApiRegisterCompanyBenefitDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiRegisterCompanyCareerScopeDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    companySize: json["companySize"] as num,
    companyType: json["companyType"] == null ? null : json["companyType"] as String,
    cover: json["cover"] == null ? null : Map<String, dynamic>.from(json["cover"] as Map),
    description: json["description"] as String,
    email: json["email"] as String,
    foundedYear: json["foundedYear"] as num,
    images: json["images"] == null ? null : (json["images"] as List).map((v) => Map<String, dynamic>.from(v as Map)).toList(),
    industry: json["industry"] as String,
    jobs: json["jobs"] == null ? null : (json["jobs"] as List).map((v) => ApiRegisterCompanyJobDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    location: json["location"] as String,
    name: json["name"] as String,
    password: json["password"] as String,
    phone: json["phone"] as String,
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiRegisterCompanySocialDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    values: json["values"] == null ? null : (json["values"] as List).map((v) => ApiRegisterCompanyValueDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    websiteUrl: json["websiteUrl"] == null ? null : json["websiteUrl"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (authEmail != null) "authEmail": authEmail!,
    if (avatar != null) "avatar": avatar!,
    if (benefits != null) "benefits": benefits!.map((v) => v.toJson()).toList(),
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    "companySize": companySize,
    if (companyType != null) "companyType": companyType!,
    if (cover != null) "cover": cover!,
    "description": description,
    "email": email,
    "foundedYear": foundedYear,
    if (images != null) "images": images!.map((v) => v).toList(),
    "industry": industry,
    if (jobs != null) "jobs": jobs!.map((v) => v.toJson()).toList(),
    "location": location,
    "name": name,
    "password": password,
    "phone": phone,
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (values != null) "values": values!.map((v) => v.toJson()).toList(),
    if (websiteUrl != null) "websiteUrl": websiteUrl!,
  };
}

class ApiCompanyRegisterResponseDTO {
  const ApiCompanyRegisterResponseDTO({this.accessToken, required this.message, this.refreshToken, this.requiresTwoFactor, this.success, this.twoFactorToken, this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? requiresTwoFactor;
  final bool? success;
  final String? twoFactorToken;
  final ApiUserResponseDTO? user;
  factory ApiCompanyRegisterResponseDTO.fromJson(Map<String, dynamic> json) => ApiCompanyRegisterResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    requiresTwoFactor: json["requiresTwoFactor"] == null ? null : json["requiresTwoFactor"] as bool,
    success: json["success"] == null ? null : json["success"] as bool,
    twoFactorToken: json["twoFactorToken"] == null ? null : json["twoFactorToken"] as String,
    user: json["user"] == null ? null : ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (requiresTwoFactor != null) "requiresTwoFactor": requiresTwoFactor!,
    if (success != null) "success": success!,
    if (twoFactorToken != null) "twoFactorToken": twoFactorToken!,
    if (user != null) "user": user!.toJson(),
  };
}

class ApiCompanyResponseDTO {
  const ApiCompanyResponseDTO({required this.availableTimes, this.avatar, this.benefits, this.careerScopes, required this.companySize, this.companyType, this.cover, required this.createdAt, required this.description, this.email, required this.foundedYear, required this.id, this.images, required this.industry, required this.location, required this.name, this.openPositions, this.phone, required this.socials, this.values, this.websiteUrl});
  final List<String> availableTimes;
  final String? avatar;
  final List<ApiValuesAndBenefitsResponseDTO>? benefits;
  final List<ApiCareerScopesResponseDTO>? careerScopes;
  final num companySize;
  final String? companyType;
  final String? cover;
  final String createdAt;
  final String description;
  final String? email;
  final num foundedYear;
  final String id;
  final List<ApiImageResponseDTO>? images;
  final String industry;
  final String location;
  final String name;
  final List<ApiJobPositionResponseDTO>? openPositions;
  final String? phone;
  final List<ApiSocialResponseDTO> socials;
  final List<ApiValuesAndBenefitsResponseDTO>? values;
  final String? websiteUrl;
  factory ApiCompanyResponseDTO.fromJson(Map<String, dynamic> json) => ApiCompanyResponseDTO(
    availableTimes: (json["availableTimes"] as List).map((v) => v as String).toList(),
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    benefits: json["benefits"] == null ? null : (json["benefits"] as List).map((v) => ApiValuesAndBenefitsResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiCareerScopesResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    companySize: json["companySize"] as num,
    companyType: json["companyType"] == null ? null : json["companyType"] as String,
    cover: json["cover"] == null ? null : json["cover"] as String,
    createdAt: json["createdAt"] as String,
    description: json["description"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    foundedYear: json["foundedYear"] as num,
    id: json["id"] as String,
    images: json["images"] == null ? null : (json["images"] as List).map((v) => ApiImageResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    industry: json["industry"] as String,
    location: json["location"] as String,
    name: json["name"] as String,
    openPositions: json["openPositions"] == null ? null : (json["openPositions"] as List).map((v) => ApiJobPositionResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    phone: json["phone"] == null ? null : json["phone"] as String,
    socials: (json["socials"] as List).map((v) => ApiSocialResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    values: json["values"] == null ? null : (json["values"] as List).map((v) => ApiValuesAndBenefitsResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    websiteUrl: json["websiteUrl"] == null ? null : json["websiteUrl"] as String,
  );
  Map<String, dynamic> toJson() => {
    "availableTimes": availableTimes.map((v) => v).toList(),
    if (avatar != null) "avatar": avatar!,
    if (benefits != null) "benefits": benefits!.map((v) => v.toJson()).toList(),
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    "companySize": companySize,
    if (companyType != null) "companyType": companyType!,
    if (cover != null) "cover": cover!,
    "createdAt": createdAt,
    "description": description,
    if (email != null) "email": email!,
    "foundedYear": foundedYear,
    "id": id,
    if (images != null) "images": images!.map((v) => v.toJson()).toList(),
    "industry": industry,
    "location": location,
    "name": name,
    if (openPositions != null) "openPositions": openPositions!.map((v) => v.toJson()).toList(),
    if (phone != null) "phone": phone!,
    "socials": socials.map((v) => v.toJson()).toList(),
    if (values != null) "values": values!.map((v) => v.toJson()).toList(),
    if (websiteUrl != null) "websiteUrl": websiteUrl!,
  };
}

class ApiCompanyUnfavoriteEmployeeResponseDTO {
  const ApiCompanyUnfavoriteEmployeeResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiCompanyUnfavoriteEmployeeResponseDTO.fromJson(Map<String, dynamic> json) => ApiCompanyUnfavoriteEmployeeResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiCountAllUsersResponseDTO {
  const ApiCountAllUsersResponseDTO({this.totalCompanies, this.totalEmployees, this.totalUsers});
  final num? totalCompanies;
  final num? totalEmployees;
  final num? totalUsers;
  factory ApiCountAllUsersResponseDTO.fromJson(Map<String, dynamic> json) => ApiCountAllUsersResponseDTO(
    totalCompanies: json["totalCompanies"] == null ? null : json["totalCompanies"] as num,
    totalEmployees: json["totalEmployees"] == null ? null : json["totalEmployees"] as num,
    totalUsers: json["totalUsers"] == null ? null : json["totalUsers"] as num,
  );
  Map<String, dynamic> toJson() => {
    if (totalCompanies != null) "totalCompanies": totalCompanies!,
    if (totalEmployees != null) "totalEmployees": totalEmployees!,
    if (totalUsers != null) "totalUsers": totalUsers!,
  };
}

class ApiCreateApplicationNoteDTO {
  const ApiCreateApplicationNoteDTO({required this.body});
  final String body;
  factory ApiCreateApplicationNoteDTO.fromJson(Map<String, dynamic> json) => ApiCreateApplicationNoteDTO(
    body: json["body"] as String,
  );
  Map<String, dynamic> toJson() => {
    "body": body,
  };
}

class ApiCreateInterviewDTO {
  const ApiCreateInterviewDTO({this.applicationId, required this.companyId, this.createdBy, this.description, this.durationMinutes, required this.employeeId, this.location, this.meetingLink, required this.scheduledAt, this.timezone, required this.title});
  final String? applicationId;
  final String companyId;
  final String? createdBy;
  final String? description;
  final num? durationMinutes;
  final String employeeId;
  final String? location;
  final String? meetingLink;
  final String scheduledAt;
  final String? timezone;
  final String title;
  factory ApiCreateInterviewDTO.fromJson(Map<String, dynamic> json) => ApiCreateInterviewDTO(
    applicationId: json["applicationId"] == null ? null : json["applicationId"] as String,
    companyId: json["companyId"] as String,
    createdBy: json["createdBy"] == null ? null : json["createdBy"] as String,
    description: json["description"] == null ? null : json["description"] as String,
    durationMinutes: json["durationMinutes"] == null ? null : json["durationMinutes"] as num,
    employeeId: json["employeeId"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    meetingLink: json["meetingLink"] == null ? null : json["meetingLink"] as String,
    scheduledAt: json["scheduledAt"] as String,
    timezone: json["timezone"] == null ? null : json["timezone"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (applicationId != null) "applicationId": applicationId!,
    "companyId": companyId,
    if (createdBy != null) "createdBy": createdBy!,
    if (description != null) "description": description!,
    if (durationMinutes != null) "durationMinutes": durationMinutes!,
    "employeeId": employeeId,
    if (location != null) "location": location!,
    if (meetingLink != null) "meetingLink": meetingLink!,
    "scheduledAt": scheduledAt,
    if (timezone != null) "timezone": timezone!,
    "title": title,
  };
}

class ApiCreateInterviewResponseDTO {
  const ApiCreateInterviewResponseDTO({this.applicationId, required this.company, required this.createdAt, required this.createdBy, required this.description, required this.durationMinutes, required this.employee, required this.id, required this.location, required this.meetingLink, this.notifyUserId, required this.scheduledAt, required this.status, required this.timezone, required this.title, required this.updatedAt});
  final String? applicationId;
  final ApiCompanyResponseDTO company;
  final String createdAt;
  final String? createdBy;
  final String? description;
  final num durationMinutes;
  final ApiEmployeeResponseDTO employee;
  final String id;
  final String? location;
  final String? meetingLink;
  final String? notifyUserId;
  final String scheduledAt;
  final String status;
  final String? timezone;
  final String title;
  final String updatedAt;
  factory ApiCreateInterviewResponseDTO.fromJson(Map<String, dynamic> json) => ApiCreateInterviewResponseDTO(
    applicationId: json["applicationId"] == null ? null : json["applicationId"] as String,
    company: ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] as String,
    createdBy: json["createdBy"] == null ? null : json["createdBy"] as String,
    description: json["description"] == null ? null : json["description"] as String,
    durationMinutes: json["durationMinutes"] as num,
    employee: ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    meetingLink: json["meetingLink"] == null ? null : json["meetingLink"] as String,
    notifyUserId: json["notifyUserId"] == null ? null : json["notifyUserId"] as String,
    scheduledAt: json["scheduledAt"] as String,
    status: json["status"] as String,
    timezone: json["timezone"] == null ? null : json["timezone"] as String,
    title: json["title"] as String,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (applicationId != null) "applicationId": applicationId!,
    "company": company.toJson(),
    "createdAt": createdAt,
    if (createdBy != null) "createdBy": createdBy!,
    if (description != null) "description": description!,
    "durationMinutes": durationMinutes,
    "employee": employee.toJson(),
    "id": id,
    if (location != null) "location": location!,
    if (meetingLink != null) "meetingLink": meetingLink!,
    if (notifyUserId != null) "notifyUserId": notifyUserId!,
    "scheduledAt": scheduledAt,
    "status": status,
    if (timezone != null) "timezone": timezone!,
    "title": title,
    "updatedAt": updatedAt,
  };
}

class ApiCreateNotificationCurrentUserDTO {
  const ApiCreateNotificationCurrentUserDTO({this.data, this.emailAttachments, required this.message, this.sendEmail, this.sendPush, this.senderAvatar, required this.title, this.type, this.userId});
  final Map<String, dynamic>? data;
  final List<Map<String, dynamic>>? emailAttachments;
  final String message;
  final bool? sendEmail;
  final bool? sendPush;
  final String? senderAvatar;
  final String title;
  final String? type;
  final String? userId;
  factory ApiCreateNotificationCurrentUserDTO.fromJson(Map<String, dynamic> json) => ApiCreateNotificationCurrentUserDTO(
    data: json["data"] == null ? null : Map<String, dynamic>.from(json["data"] as Map),
    emailAttachments: json["emailAttachments"] == null ? null : (json["emailAttachments"] as List).map((v) => Map<String, dynamic>.from(v as Map)).toList(),
    message: json["message"] as String,
    sendEmail: json["sendEmail"] == null ? null : json["sendEmail"] as bool,
    sendPush: json["sendPush"] == null ? null : json["sendPush"] as bool,
    senderAvatar: json["senderAvatar"] == null ? null : json["senderAvatar"] as String,
    title: json["title"] as String,
    type: json["type"] == null ? null : json["type"] as String,
    userId: json["userId"] == null ? null : json["userId"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (data != null) "data": data!,
    if (emailAttachments != null) "emailAttachments": emailAttachments!.map((v) => v).toList(),
    "message": message,
    if (sendEmail != null) "sendEmail": sendEmail!,
    if (sendPush != null) "sendPush": sendPush!,
    if (senderAvatar != null) "senderAvatar": senderAvatar!,
    "title": title,
    if (type != null) "type": type!,
    if (userId != null) "userId": userId!,
  };
}

class ApiCreateNotificationCurrentUserResponseDTO {
  const ApiCreateNotificationCurrentUserResponseDTO({required this.createdAt, required this.data, required this.id, required this.isRead, required this.message, required this.title, required this.type});
  final String createdAt;
  final Map<String, dynamic>? data;
  final String id;
  final bool isRead;
  final String message;
  final String title;
  final String? type;
  factory ApiCreateNotificationCurrentUserResponseDTO.fromJson(Map<String, dynamic> json) => ApiCreateNotificationCurrentUserResponseDTO(
    createdAt: json["createdAt"] as String,
    data: json["data"] == null ? null : Map<String, dynamic>.from(json["data"] as Map),
    id: json["id"] as String,
    isRead: json["isRead"] as bool,
    message: json["message"] as String,
    title: json["title"] as String,
    type: json["type"] == null ? null : json["type"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    if (data != null) "data": data!,
    "id": id,
    "isRead": isRead,
    "message": message,
    "title": title,
    if (type != null) "type": type!,
  };
}

class ApiCreateReportBodyDTO {
  const ApiCreateReportBodyDTO({this.details, required this.reason, required this.reportedId});
  final String? details;
  final String reason;
  final String reportedId;
  factory ApiCreateReportBodyDTO.fromJson(Map<String, dynamic> json) => ApiCreateReportBodyDTO(
    details: json["details"] == null ? null : json["details"] as String,
    reason: json["reason"] as String,
    reportedId: json["reportedId"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (details != null) "details": details!,
    "reason": reason,
    "reportedId": reportedId,
  };
}

class ApiCreateResumeDraftDTO {
  const ApiCreateResumeDraftDTO({required this.content, required this.id, required this.name});
  final Map<String, dynamic> content;
  final String id;
  final String name;
  factory ApiCreateResumeDraftDTO.fromJson(Map<String, dynamic> json) => ApiCreateResumeDraftDTO(
    content: Map<String, dynamic>.from(json["content"] as Map),
    id: json["id"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    "content": content,
    "id": id,
    "name": name,
  };
}

class ApiCreateResumeTemplateDTO {
  const ApiCreateResumeTemplateDTO({required this.description, required this.isPremium, required this.price, required this.templateKey, required this.title});
  final String description;
  final bool isPremium;
  final num price;
  final String templateKey;
  final String title;
  factory ApiCreateResumeTemplateDTO.fromJson(Map<String, dynamic> json) => ApiCreateResumeTemplateDTO(
    description: json["description"] as String,
    isPremium: json["isPremium"] as bool,
    price: json["price"] as num,
    templateKey: json["templateKey"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    "description": description,
    "isPremium": isPremium,
    "price": price,
    "templateKey": templateKey,
    "title": title,
  };
}

class ApiCreateResumeTemplateResponseDTO {
  const ApiCreateResumeTemplateResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiCreateResumeTemplateResponseDTO.fromJson(Map<String, dynamic> json) => ApiCreateResumeTemplateResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiCreateSavedSearchDTO {
  const ApiCreateSavedSearchDTO({required this.filters, this.frequency, required this.name});
  final dynamic filters;
  final String? frequency;
  final String name;
  factory ApiCreateSavedSearchDTO.fromJson(Map<String, dynamic> json) => ApiCreateSavedSearchDTO(
    filters: json["filters"],
    frequency: json["frequency"] == null ? null : json["frequency"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    "filters": filters,
    if (frequency != null) "frequency": frequency!,
    "name": name,
  };
}

class ApiDeleteNotificationResponseDTO {
  const ApiDeleteNotificationResponseDTO({this.affected, required this.success});
  final num? affected;
  final bool success;
  factory ApiDeleteNotificationResponseDTO.fromJson(Map<String, dynamic> json) => ApiDeleteNotificationResponseDTO(
    affected: json["affected"] == null ? null : json["affected"] as num,
    success: json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    if (affected != null) "affected": affected!,
    "success": success,
  };
}

class ApiDeviceTokenBodyDTO {
  const ApiDeviceTokenBodyDTO({required this.token});
  final String token;
  factory ApiDeviceTokenBodyDTO.fromJson(Map<String, dynamic> json) => ApiDeviceTokenBodyDTO(
    token: json["token"] as String,
  );
  Map<String, dynamic> toJson() => {
    "token": token,
  };
}

class ApiDeviceTokenResponseDTO {
  const ApiDeviceTokenResponseDTO({required this.success});
  final bool success;
  factory ApiDeviceTokenResponseDTO.fromJson(Map<String, dynamic> json) => ApiDeviceTokenResponseDTO(
    success: json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "success": success,
  };
}

class ApiEducationResponseDTO {
  const ApiEducationResponseDTO({required this.degree, this.id, required this.school, required this.year});
  final String degree;
  final String? id;
  final String school;
  final String year;
  factory ApiEducationResponseDTO.fromJson(Map<String, dynamic> json) => ApiEducationResponseDTO(
    degree: json["degree"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    school: json["school"] as String,
    year: json["year"] as String,
  );
  Map<String, dynamic> toJson() => {
    "degree": degree,
    if (id != null) "id": id!,
    "school": school,
    "year": year,
  };
}

class ApiEmployeeFavoriteCompanyResponseDTO {
  const ApiEmployeeFavoriteCompanyResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiEmployeeFavoriteCompanyResponseDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeFavoriteCompanyResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiEmployeeFavoritesListItemDTO {
  const ApiEmployeeFavoritesListItemDTO({required this.company, required this.createdAt, required this.id, required this.userId});
  final ApiCompanyResponseDTO company;
  final String createdAt;
  final String id;
  final String userId;
  factory ApiEmployeeFavoritesListItemDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeFavoritesListItemDTO(
    company: ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] as String,
    id: json["id"] as String,
    userId: json["userId"] as String,
  );
  Map<String, dynamic> toJson() => {
    "company": company.toJson(),
    "createdAt": createdAt,
    "id": id,
    "userId": userId,
  };
}

class ApiEmployeeRegisterDTO {
  const ApiEmployeeRegisterDTO({this.authEmail, this.availability, this.careerScopes, this.description, this.dob, this.educations, this.email, this.expectedSalaryMax, this.expectedSalaryMin, this.experiences, this.firstname, this.gender, required this.job, this.languages, this.lastname, this.linkedinUrl, required this.location, this.noticePeriod, required this.password, this.phone, this.portfolioUrl, this.skills, this.socials, this.username, this.workMode, this.yearsOfExperience});
  final bool? authEmail;
  final String? availability;
  final List<ApiRegisterEmployeeCareerScopeDTO>? careerScopes;
  final String? description;
  final String? dob;
  final List<ApiRegisterEmployeeEducationDTO>? educations;
  final String? email;
  final num? expectedSalaryMax;
  final num? expectedSalaryMin;
  final List<ApiRegisterEmployeeExperienceDTO>? experiences;
  final String? firstname;
  final String? gender;
  final String job;
  final List<String>? languages;
  final String? lastname;
  final String? linkedinUrl;
  final String location;
  final String? noticePeriod;
  final String password;
  final String? phone;
  final String? portfolioUrl;
  final List<ApiRegisterEmployeeSkillDTO>? skills;
  final List<ApiRegisterEmployeeSocialDTO>? socials;
  final String? username;
  final String? workMode;
  final String? yearsOfExperience;
  factory ApiEmployeeRegisterDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeRegisterDTO(
    authEmail: json["authEmail"] == null ? null : json["authEmail"] as bool,
    availability: json["availability"] == null ? null : json["availability"] as String,
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiRegisterEmployeeCareerScopeDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    description: json["description"] == null ? null : json["description"] as String,
    dob: json["dob"] == null ? null : json["dob"] as String,
    educations: json["educations"] == null ? null : (json["educations"] as List).map((v) => ApiRegisterEmployeeEducationDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    email: json["email"] == null ? null : json["email"] as String,
    expectedSalaryMax: json["expectedSalaryMax"] == null ? null : json["expectedSalaryMax"] as num,
    expectedSalaryMin: json["expectedSalaryMin"] == null ? null : json["expectedSalaryMin"] as num,
    experiences: json["experiences"] == null ? null : (json["experiences"] as List).map((v) => ApiRegisterEmployeeExperienceDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    firstname: json["firstname"] == null ? null : json["firstname"] as String,
    gender: json["gender"] == null ? null : json["gender"] as String,
    job: json["job"] as String,
    languages: json["languages"] == null ? null : (json["languages"] as List).map((v) => v as String).toList(),
    lastname: json["lastname"] == null ? null : json["lastname"] as String,
    linkedinUrl: json["linkedinUrl"] == null ? null : json["linkedinUrl"] as String,
    location: json["location"] as String,
    noticePeriod: json["noticePeriod"] == null ? null : json["noticePeriod"] as String,
    password: json["password"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    portfolioUrl: json["portfolioUrl"] == null ? null : json["portfolioUrl"] as String,
    skills: json["skills"] == null ? null : (json["skills"] as List).map((v) => ApiRegisterEmployeeSkillDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiRegisterEmployeeSocialDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    username: json["username"] == null ? null : json["username"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
    yearsOfExperience: json["yearsOfExperience"] == null ? null : json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (authEmail != null) "authEmail": authEmail!,
    if (availability != null) "availability": availability!,
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    if (description != null) "description": description!,
    if (dob != null) "dob": dob!,
    if (educations != null) "educations": educations!.map((v) => v.toJson()).toList(),
    if (email != null) "email": email!,
    if (expectedSalaryMax != null) "expectedSalaryMax": expectedSalaryMax!,
    if (expectedSalaryMin != null) "expectedSalaryMin": expectedSalaryMin!,
    if (experiences != null) "experiences": experiences!.map((v) => v.toJson()).toList(),
    if (firstname != null) "firstname": firstname!,
    if (gender != null) "gender": gender!,
    "job": job,
    if (languages != null) "languages": languages!.map((v) => v).toList(),
    if (lastname != null) "lastname": lastname!,
    if (linkedinUrl != null) "linkedinUrl": linkedinUrl!,
    "location": location,
    if (noticePeriod != null) "noticePeriod": noticePeriod!,
    "password": password,
    if (phone != null) "phone": phone!,
    if (portfolioUrl != null) "portfolioUrl": portfolioUrl!,
    if (skills != null) "skills": skills!.map((v) => v.toJson()).toList(),
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (username != null) "username": username!,
    if (workMode != null) "workMode": workMode!,
    if (yearsOfExperience != null) "yearsOfExperience": yearsOfExperience!,
  };
}

class ApiEmployeeRegisterResponseDTO {
  const ApiEmployeeRegisterResponseDTO({this.accessToken, required this.message, this.refreshToken, this.requiresTwoFactor, this.success, this.twoFactorToken, this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? requiresTwoFactor;
  final bool? success;
  final String? twoFactorToken;
  final ApiUserResponseDTO? user;
  factory ApiEmployeeRegisterResponseDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeRegisterResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    requiresTwoFactor: json["requiresTwoFactor"] == null ? null : json["requiresTwoFactor"] as bool,
    success: json["success"] == null ? null : json["success"] as bool,
    twoFactorToken: json["twoFactorToken"] == null ? null : json["twoFactorToken"] as String,
    user: json["user"] == null ? null : ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (requiresTwoFactor != null) "requiresTwoFactor": requiresTwoFactor!,
    if (success != null) "success": success!,
    if (twoFactorToken != null) "twoFactorToken": twoFactorToken!,
    if (user != null) "user": user!.toJson(),
  };
}

class ApiEmployeeResponseDTO {
  const ApiEmployeeResponseDTO({required this.availability, this.avatar, this.careerScopes, this.coverLetter, this.createdAt, required this.description, this.dob, this.educations, this.email, this.expectedSalaryMax, this.expectedSalaryMin, this.experiences, required this.firstname, required this.gender, required this.id, required this.isHide, required this.job, this.languages, required this.lastname, this.linkedinUrl, required this.location, this.noticePeriod, required this.phone, this.portfolioUrl, this.resume, this.skills, this.socials, this.updatedAt, this.userId, required this.username, this.workMode, required this.yearsOfExperience});
  final String availability;
  final String? avatar;
  final List<ApiCareerScopesResponseDTO>? careerScopes;
  final String? coverLetter;
  final String? createdAt;
  final String description;
  final String? dob;
  final List<ApiEducationResponseDTO>? educations;
  final String? email;
  final num? expectedSalaryMax;
  final num? expectedSalaryMin;
  final List<ApiExperienceResponseDTO>? experiences;
  final String firstname;
  final String gender;
  final String id;
  final bool isHide;
  final String job;
  final List<String>? languages;
  final String lastname;
  final String? linkedinUrl;
  final String location;
  final String? noticePeriod;
  final String phone;
  final String? portfolioUrl;
  final String? resume;
  final List<ApiSkillResponseDTO>? skills;
  final List<ApiSocialResponseDTO>? socials;
  final String? updatedAt;
  final String? userId;
  final String username;
  final String? workMode;
  final String yearsOfExperience;
  factory ApiEmployeeResponseDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeResponseDTO(
    availability: json["availability"] as String,
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiCareerScopesResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    coverLetter: json["coverLetter"] == null ? null : json["coverLetter"] as String,
    createdAt: json["createdAt"] == null ? null : json["createdAt"] as String,
    description: json["description"] as String,
    dob: json["dob"] == null ? null : json["dob"] as String,
    educations: json["educations"] == null ? null : (json["educations"] as List).map((v) => ApiEducationResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    email: json["email"] == null ? null : json["email"] as String,
    expectedSalaryMax: json["expectedSalaryMax"] == null ? null : json["expectedSalaryMax"] as num,
    expectedSalaryMin: json["expectedSalaryMin"] == null ? null : json["expectedSalaryMin"] as num,
    experiences: json["experiences"] == null ? null : (json["experiences"] as List).map((v) => ApiExperienceResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    firstname: json["firstname"] as String,
    gender: json["gender"] as String,
    id: json["id"] as String,
    isHide: json["isHide"] as bool,
    job: json["job"] as String,
    languages: json["languages"] == null ? null : (json["languages"] as List).map((v) => v as String).toList(),
    lastname: json["lastname"] as String,
    linkedinUrl: json["linkedinUrl"] == null ? null : json["linkedinUrl"] as String,
    location: json["location"] as String,
    noticePeriod: json["noticePeriod"] == null ? null : json["noticePeriod"] as String,
    phone: json["phone"] as String,
    portfolioUrl: json["portfolioUrl"] == null ? null : json["portfolioUrl"] as String,
    resume: json["resume"] == null ? null : json["resume"] as String,
    skills: json["skills"] == null ? null : (json["skills"] as List).map((v) => ApiSkillResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiSocialResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    updatedAt: json["updatedAt"] == null ? null : json["updatedAt"] as String,
    userId: json["userId"] == null ? null : json["userId"] as String,
    username: json["username"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
    yearsOfExperience: json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    "availability": availability,
    if (avatar != null) "avatar": avatar!,
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    if (coverLetter != null) "coverLetter": coverLetter!,
    if (createdAt != null) "createdAt": createdAt!,
    "description": description,
    if (dob != null) "dob": dob!,
    if (educations != null) "educations": educations!.map((v) => v.toJson()).toList(),
    if (email != null) "email": email!,
    if (expectedSalaryMax != null) "expectedSalaryMax": expectedSalaryMax!,
    if (expectedSalaryMin != null) "expectedSalaryMin": expectedSalaryMin!,
    if (experiences != null) "experiences": experiences!.map((v) => v.toJson()).toList(),
    "firstname": firstname,
    "gender": gender,
    "id": id,
    "isHide": isHide,
    "job": job,
    if (languages != null) "languages": languages!.map((v) => v).toList(),
    "lastname": lastname,
    if (linkedinUrl != null) "linkedinUrl": linkedinUrl!,
    "location": location,
    if (noticePeriod != null) "noticePeriod": noticePeriod!,
    "phone": phone,
    if (portfolioUrl != null) "portfolioUrl": portfolioUrl!,
    if (resume != null) "resume": resume!,
    if (skills != null) "skills": skills!.map((v) => v.toJson()).toList(),
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (updatedAt != null) "updatedAt": updatedAt!,
    if (userId != null) "userId": userId!,
    "username": username,
    if (workMode != null) "workMode": workMode!,
    "yearsOfExperience": yearsOfExperience,
  };
}

class ApiEmployeeUnfavoriteCompanyResponseDTO {
  const ApiEmployeeUnfavoriteCompanyResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiEmployeeUnfavoriteCompanyResponseDTO.fromJson(Map<String, dynamic> json) => ApiEmployeeUnfavoriteCompanyResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiEmployerAnalyticsResponseDTO {
  const ApiEmployerAnalyticsResponseDTO({required this.activePipeline, required this.applicationsDelta, required this.funnel, required this.hired30d, required this.medianDaysToFirstMove, required this.openPositions, required this.rejected30d, required this.topJobs});
  final num activePipeline;
  final dynamic applicationsDelta;
  final List<ApiEmployerFunnelStageDTO> funnel;
  final num hired30d;
  final num? medianDaysToFirstMove;
  final num openPositions;
  final num rejected30d;
  final List<ApiTopJobDTO> topJobs;
  factory ApiEmployerAnalyticsResponseDTO.fromJson(Map<String, dynamic> json) => ApiEmployerAnalyticsResponseDTO(
    activePipeline: json["activePipeline"] as num,
    applicationsDelta: json["applicationsDelta"],
    funnel: (json["funnel"] as List).map((v) => ApiEmployerFunnelStageDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    hired30d: json["hired30d"] as num,
    medianDaysToFirstMove: json["medianDaysToFirstMove"] == null ? null : json["medianDaysToFirstMove"] as num,
    openPositions: json["openPositions"] as num,
    rejected30d: json["rejected30d"] as num,
    topJobs: (json["topJobs"] as List).map((v) => ApiTopJobDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
  );
  Map<String, dynamic> toJson() => {
    "activePipeline": activePipeline,
    "applicationsDelta": applicationsDelta,
    "funnel": funnel.map((v) => v.toJson()).toList(),
    "hired30d": hired30d,
    if (medianDaysToFirstMove != null) "medianDaysToFirstMove": medianDaysToFirstMove!,
    "openPositions": openPositions,
    "rejected30d": rejected30d,
    "topJobs": topJobs.map((v) => v.toJson()).toList(),
  };
}

class ApiEmployerFunnelStageDTO {
  const ApiEmployerFunnelStageDTO({required this.count, required this.status});
  final num count;
  final String status;
  factory ApiEmployerFunnelStageDTO.fromJson(Map<String, dynamic> json) => ApiEmployerFunnelStageDTO(
    count: json["count"] as num,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "count": count,
    "status": status,
  };
}

class ApiExperienceResponseDTO {
  const ApiExperienceResponseDTO({this.company, required this.description, required this.endDate, this.id, required this.startDate, required this.title});
  final String? company;
  final String description;
  final String endDate;
  final String? id;
  final String startDate;
  final String title;
  factory ApiExperienceResponseDTO.fromJson(Map<String, dynamic> json) => ApiExperienceResponseDTO(
    company: json["company"] == null ? null : json["company"] as String,
    description: json["description"] as String,
    endDate: json["endDate"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    startDate: json["startDate"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!,
    "description": description,
    "endDate": endDate,
    if (id != null) "id": id!,
    "startDate": startDate,
    "title": title,
  };
}

class ApiExperienceSuggestionDTO {
  const ApiExperienceSuggestionDTO({required this.improvedAchievements, required this.improvedDescription, required this.index});
  final List<String> improvedAchievements;
  final String improvedDescription;
  final num index;
  factory ApiExperienceSuggestionDTO.fromJson(Map<String, dynamic> json) => ApiExperienceSuggestionDTO(
    improvedAchievements: (json["improvedAchievements"] as List).map((v) => v as String).toList(),
    improvedDescription: json["improvedDescription"] as String,
    index: json["index"] as num,
  );
  Map<String, dynamic> toJson() => {
    "improvedAchievements": improvedAchievements.map((v) => v).toList(),
    "improvedDescription": improvedDescription,
    "index": index,
  };
}

class ApiFavoriteCountResponseDTO {
  const ApiFavoriteCountResponseDTO({required this.count});
  final num count;
  factory ApiFavoriteCountResponseDTO.fromJson(Map<String, dynamic> json) => ApiFavoriteCountResponseDTO(
    count: json["count"] as num,
  );
  Map<String, dynamic> toJson() => {
    "count": count,
  };
}

class ApiFindCurrentLikeResponseDTO {
  const ApiFindCurrentLikeResponseDTO({this.company, this.createdAt, this.deletedAt, this.email, this.employee, required this.id, this.isEmailVerified, this.isTwoFactorEnabled, this.lastLoginAt, this.lastLoginMethod, this.phone, this.profileCompleted, required this.role, this.updatedAt});
  final ApiCompanyResponseDTO? company;
  final String? createdAt;
  final String? deletedAt;
  final String? email;
  final ApiEmployeeResponseDTO? employee;
  final String id;
  final bool? isEmailVerified;
  final bool? isTwoFactorEnabled;
  final String? lastLoginAt;
  final String? lastLoginMethod;
  final String? phone;
  final bool? profileCompleted;
  final String role;
  final String? updatedAt;
  factory ApiFindCurrentLikeResponseDTO.fromJson(Map<String, dynamic> json) => ApiFindCurrentLikeResponseDTO(
    company: json["company"] == null ? null : ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] == null ? null : json["createdAt"] as String,
    deletedAt: json["deletedAt"] == null ? null : json["deletedAt"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    employee: json["employee"] == null ? null : ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    isEmailVerified: json["isEmailVerified"] == null ? null : json["isEmailVerified"] as bool,
    isTwoFactorEnabled: json["isTwoFactorEnabled"] == null ? null : json["isTwoFactorEnabled"] as bool,
    lastLoginAt: json["lastLoginAt"] == null ? null : json["lastLoginAt"] as String,
    lastLoginMethod: json["lastLoginMethod"] == null ? null : json["lastLoginMethod"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profileCompleted: json["profileCompleted"] == null ? null : json["profileCompleted"] as bool,
    role: json["role"] as String,
    updatedAt: json["updatedAt"] == null ? null : json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!.toJson(),
    if (createdAt != null) "createdAt": createdAt!,
    if (deletedAt != null) "deletedAt": deletedAt!,
    if (email != null) "email": email!,
    if (employee != null) "employee": employee!.toJson(),
    "id": id,
    if (isEmailVerified != null) "isEmailVerified": isEmailVerified!,
    if (isTwoFactorEnabled != null) "isTwoFactorEnabled": isTwoFactorEnabled!,
    if (lastLoginAt != null) "lastLoginAt": lastLoginAt!,
    if (lastLoginMethod != null) "lastLoginMethod": lastLoginMethod!,
    if (phone != null) "phone": phone!,
    if (profileCompleted != null) "profileCompleted": profileCompleted!,
    "role": role,
    if (updatedAt != null) "updatedAt": updatedAt!,
  };
}

class ApiFindCurrentMatchingResponseDTO {
  const ApiFindCurrentMatchingResponseDTO({this.company, this.createdAt, this.deletedAt, this.email, this.employee, required this.id, this.isEmailVerified, this.isTwoFactorEnabled, this.lastLoginAt, this.lastLoginMethod, this.matchScore, this.phone, this.profileCompleted, required this.role, this.skillScore, this.updatedAt});
  final ApiCompanyResponseDTO? company;
  final String? createdAt;
  final String? deletedAt;
  final String? email;
  final ApiEmployeeResponseDTO? employee;
  final String id;
  final bool? isEmailVerified;
  final bool? isTwoFactorEnabled;
  final String? lastLoginAt;
  final String? lastLoginMethod;
  final num? matchScore;
  final String? phone;
  final bool? profileCompleted;
  final String role;
  final num? skillScore;
  final String? updatedAt;
  factory ApiFindCurrentMatchingResponseDTO.fromJson(Map<String, dynamic> json) => ApiFindCurrentMatchingResponseDTO(
    company: json["company"] == null ? null : ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] == null ? null : json["createdAt"] as String,
    deletedAt: json["deletedAt"] == null ? null : json["deletedAt"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    employee: json["employee"] == null ? null : ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    isEmailVerified: json["isEmailVerified"] == null ? null : json["isEmailVerified"] as bool,
    isTwoFactorEnabled: json["isTwoFactorEnabled"] == null ? null : json["isTwoFactorEnabled"] as bool,
    lastLoginAt: json["lastLoginAt"] == null ? null : json["lastLoginAt"] as String,
    lastLoginMethod: json["lastLoginMethod"] == null ? null : json["lastLoginMethod"] as String,
    matchScore: json["matchScore"] == null ? null : json["matchScore"] as num,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profileCompleted: json["profileCompleted"] == null ? null : json["profileCompleted"] as bool,
    role: json["role"] as String,
    skillScore: json["skillScore"] == null ? null : json["skillScore"] as num,
    updatedAt: json["updatedAt"] == null ? null : json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!.toJson(),
    if (createdAt != null) "createdAt": createdAt!,
    if (deletedAt != null) "deletedAt": deletedAt!,
    if (email != null) "email": email!,
    if (employee != null) "employee": employee!.toJson(),
    "id": id,
    if (isEmailVerified != null) "isEmailVerified": isEmailVerified!,
    if (isTwoFactorEnabled != null) "isTwoFactorEnabled": isTwoFactorEnabled!,
    if (lastLoginAt != null) "lastLoginAt": lastLoginAt!,
    if (lastLoginMethod != null) "lastLoginMethod": lastLoginMethod!,
    if (matchScore != null) "matchScore": matchScore!,
    if (phone != null) "phone": phone!,
    if (profileCompleted != null) "profileCompleted": profileCompleted!,
    "role": role,
    if (skillScore != null) "skillScore": skillScore!,
    if (updatedAt != null) "updatedAt": updatedAt!,
  };
}

class ApiForgotPasswordDTO {
  const ApiForgotPasswordDTO({required this.identifier});
  final String identifier;
  factory ApiForgotPasswordDTO.fromJson(Map<String, dynamic> json) => ApiForgotPasswordDTO(
    identifier: json["identifier"] as String,
  );
  Map<String, dynamic> toJson() => {
    "identifier": identifier,
  };
}

class ApiForgotPasswordResponseDTO {
  const ApiForgotPasswordResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiForgotPasswordResponseDTO.fromJson(Map<String, dynamic> json) => ApiForgotPasswordResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiGenerateCoverLetterDTO {
  const ApiGenerateCoverLetterDTO({this.companyDescription, this.companyIndustry, required this.companyName, this.employeeDescription, this.employeeExperience, this.employeeJob, required this.employeeName, required this.employeeSkills, required this.openPositions});
  final String? companyDescription;
  final String? companyIndustry;
  final String companyName;
  final String? employeeDescription;
  final String? employeeExperience;
  final String? employeeJob;
  final String employeeName;
  final List<String> employeeSkills;
  final List<String> openPositions;
  factory ApiGenerateCoverLetterDTO.fromJson(Map<String, dynamic> json) => ApiGenerateCoverLetterDTO(
    companyDescription: json["companyDescription"] == null ? null : json["companyDescription"] as String,
    companyIndustry: json["companyIndustry"] == null ? null : json["companyIndustry"] as String,
    companyName: json["companyName"] as String,
    employeeDescription: json["employeeDescription"] == null ? null : json["employeeDescription"] as String,
    employeeExperience: json["employeeExperience"] == null ? null : json["employeeExperience"] as String,
    employeeJob: json["employeeJob"] == null ? null : json["employeeJob"] as String,
    employeeName: json["employeeName"] as String,
    employeeSkills: (json["employeeSkills"] as List).map((v) => v as String).toList(),
    openPositions: (json["openPositions"] as List).map((v) => v as String).toList(),
  );
  Map<String, dynamic> toJson() => {
    if (companyDescription != null) "companyDescription": companyDescription!,
    if (companyIndustry != null) "companyIndustry": companyIndustry!,
    "companyName": companyName,
    if (employeeDescription != null) "employeeDescription": employeeDescription!,
    if (employeeExperience != null) "employeeExperience": employeeExperience!,
    if (employeeJob != null) "employeeJob": employeeJob!,
    "employeeName": employeeName,
    "employeeSkills": employeeSkills.map((v) => v).toList(),
    "openPositions": openPositions.map((v) => v).toList(),
  };
}

class ApiGenerateCoverLetterPdfDTO {
  const ApiGenerateCoverLetterPdfDTO({this.companyIndustry, required this.companyName, required this.coverLetterText, this.employeeJob, required this.employeeName, this.style});
  final String? companyIndustry;
  final String companyName;
  final String coverLetterText;
  final String? employeeJob;
  final String employeeName;
  final String? style;
  factory ApiGenerateCoverLetterPdfDTO.fromJson(Map<String, dynamic> json) => ApiGenerateCoverLetterPdfDTO(
    companyIndustry: json["companyIndustry"] == null ? null : json["companyIndustry"] as String,
    companyName: json["companyName"] as String,
    coverLetterText: json["coverLetterText"] as String,
    employeeJob: json["employeeJob"] == null ? null : json["employeeJob"] as String,
    employeeName: json["employeeName"] as String,
    style: json["style"] == null ? null : json["style"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (companyIndustry != null) "companyIndustry": companyIndustry!,
    "companyName": companyName,
    "coverLetterText": coverLetterText,
    if (employeeJob != null) "employeeJob": employeeJob!,
    "employeeName": employeeName,
    if (style != null) "style": style!,
  };
}

class ApiGenerateCoverLetterPdfResponseDTO {
  const ApiGenerateCoverLetterPdfResponseDTO({required this.data, required this.filename, required this.mimeType});
  final String data;
  final String filename;
  final String mimeType;
  factory ApiGenerateCoverLetterPdfResponseDTO.fromJson(Map<String, dynamic> json) => ApiGenerateCoverLetterPdfResponseDTO(
    data: json["data"] as String,
    filename: json["filename"] as String,
    mimeType: json["mimeType"] as String,
  );
  Map<String, dynamic> toJson() => {
    "data": data,
    "filename": filename,
    "mimeType": mimeType,
  };
}

class ApiGenerateCoverLetterResponseDTO {
  const ApiGenerateCoverLetterResponseDTO({required this.coverLetter});
  final String coverLetter;
  factory ApiGenerateCoverLetterResponseDTO.fromJson(Map<String, dynamic> json) => ApiGenerateCoverLetterResponseDTO(
    coverLetter: json["coverLetter"] as String,
  );
  Map<String, dynamic> toJson() => {
    "coverLetter": coverLetter,
  };
}

class ApiGenerateInterviewPrepPdfDTO {
  const ApiGenerateInterviewPrepPdfDTO({this.companyIndustry, required this.companyName, required this.interviewTitle, required this.questions});
  final String? companyIndustry;
  final String companyName;
  final String interviewTitle;
  final List<ApiInterviewPrepPdfQuestionDTO> questions;
  factory ApiGenerateInterviewPrepPdfDTO.fromJson(Map<String, dynamic> json) => ApiGenerateInterviewPrepPdfDTO(
    companyIndustry: json["companyIndustry"] == null ? null : json["companyIndustry"] as String,
    companyName: json["companyName"] as String,
    interviewTitle: json["interviewTitle"] as String,
    questions: (json["questions"] as List).map((v) => ApiInterviewPrepPdfQuestionDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
  );
  Map<String, dynamic> toJson() => {
    if (companyIndustry != null) "companyIndustry": companyIndustry!,
    "companyName": companyName,
    "interviewTitle": interviewTitle,
    "questions": questions.map((v) => v.toJson()).toList(),
  };
}

class ApiGenerateInterviewPrepPdfResponseDTO {
  const ApiGenerateInterviewPrepPdfResponseDTO({required this.data, required this.filename, required this.mimeType});
  final String data;
  final String filename;
  final String mimeType;
  factory ApiGenerateInterviewPrepPdfResponseDTO.fromJson(Map<String, dynamic> json) => ApiGenerateInterviewPrepPdfResponseDTO(
    data: json["data"] as String,
    filename: json["filename"] as String,
    mimeType: json["mimeType"] as String,
  );
  Map<String, dynamic> toJson() => {
    "data": data,
    "filename": filename,
    "mimeType": mimeType,
  };
}

class ApiGenerateResumeFromTextDTO {
  const ApiGenerateResumeFromTextDTO({required this.sourceText, required this.template});
  final String sourceText;
  final String template;
  factory ApiGenerateResumeFromTextDTO.fromJson(Map<String, dynamic> json) => ApiGenerateResumeFromTextDTO(
    sourceText: json["sourceText"] as String,
    template: json["template"] as String,
  );
  Map<String, dynamic> toJson() => {
    "sourceText": sourceText,
    "template": template,
  };
}

class ApiGetAllNotificationResponseDTO {
  const ApiGetAllNotificationResponseDTO({required this.createdAt, required this.data, required this.id, required this.isRead, required this.message, required this.title, required this.type});
  final String createdAt;
  final Map<String, dynamic>? data;
  final String id;
  final bool isRead;
  final String message;
  final String title;
  final String? type;
  factory ApiGetAllNotificationResponseDTO.fromJson(Map<String, dynamic> json) => ApiGetAllNotificationResponseDTO(
    createdAt: json["createdAt"] as String,
    data: json["data"] == null ? null : Map<String, dynamic>.from(json["data"] as Map),
    id: json["id"] as String,
    isRead: json["isRead"] as bool,
    message: json["message"] as String,
    title: json["title"] as String,
    type: json["type"] == null ? null : json["type"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    if (data != null) "data": data!,
    "id": id,
    "isRead": isRead,
    "message": message,
    "title": title,
    if (type != null) "type": type!,
  };
}

class ApiGetApplicationResponseDTO {
  const ApiGetApplicationResponseDTO({required this.appliedAt, this.coverLetterNote, this.employeeId, this.employeeName, required this.id, this.jobId, this.jobTitle, this.matchScore, this.rejectionReason, this.reviewedAt, required this.status, this.statusChangedAt});
  final String appliedAt;
  final String? coverLetterNote;
  final String? employeeId;
  final String? employeeName;
  final String id;
  final String? jobId;
  final String? jobTitle;
  final num? matchScore;
  final String? rejectionReason;
  final String? reviewedAt;
  final String status;
  final String? statusChangedAt;
  factory ApiGetApplicationResponseDTO.fromJson(Map<String, dynamic> json) => ApiGetApplicationResponseDTO(
    appliedAt: json["appliedAt"] as String,
    coverLetterNote: json["coverLetterNote"] == null ? null : json["coverLetterNote"] as String,
    employeeId: json["employeeId"] == null ? null : json["employeeId"] as String,
    employeeName: json["employeeName"] == null ? null : json["employeeName"] as String,
    id: json["id"] as String,
    jobId: json["jobId"] == null ? null : json["jobId"] as String,
    jobTitle: json["jobTitle"] == null ? null : json["jobTitle"] as String,
    matchScore: json["matchScore"] == null ? null : json["matchScore"] as num,
    rejectionReason: json["rejectionReason"] == null ? null : json["rejectionReason"] as String,
    reviewedAt: json["reviewedAt"] == null ? null : json["reviewedAt"] as String,
    status: json["status"] as String,
    statusChangedAt: json["statusChangedAt"] == null ? null : json["statusChangedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "appliedAt": appliedAt,
    if (coverLetterNote != null) "coverLetterNote": coverLetterNote!,
    if (employeeId != null) "employeeId": employeeId!,
    if (employeeName != null) "employeeName": employeeName!,
    "id": id,
    if (jobId != null) "jobId": jobId!,
    if (jobTitle != null) "jobTitle": jobTitle!,
    if (matchScore != null) "matchScore": matchScore!,
    if (rejectionReason != null) "rejectionReason": rejectionReason!,
    if (reviewedAt != null) "reviewedAt": reviewedAt!,
    "status": status,
    if (statusChangedAt != null) "statusChangedAt": statusChangedAt!,
  };
}

class ApiGetInterviewResponseDTO {
  const ApiGetInterviewResponseDTO({this.applicationId, required this.company, required this.createdAt, required this.createdBy, required this.description, required this.durationMinutes, required this.employee, required this.id, required this.location, required this.meetingLink, this.notifyUserId, required this.scheduledAt, required this.status, required this.timezone, required this.title, required this.updatedAt});
  final String? applicationId;
  final ApiCompanyResponseDTO company;
  final String createdAt;
  final String? createdBy;
  final String? description;
  final num durationMinutes;
  final ApiEmployeeResponseDTO employee;
  final String id;
  final String? location;
  final String? meetingLink;
  final String? notifyUserId;
  final String scheduledAt;
  final String status;
  final String? timezone;
  final String title;
  final String updatedAt;
  factory ApiGetInterviewResponseDTO.fromJson(Map<String, dynamic> json) => ApiGetInterviewResponseDTO(
    applicationId: json["applicationId"] == null ? null : json["applicationId"] as String,
    company: ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] as String,
    createdBy: json["createdBy"] == null ? null : json["createdBy"] as String,
    description: json["description"] == null ? null : json["description"] as String,
    durationMinutes: json["durationMinutes"] as num,
    employee: ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    meetingLink: json["meetingLink"] == null ? null : json["meetingLink"] as String,
    notifyUserId: json["notifyUserId"] == null ? null : json["notifyUserId"] as String,
    scheduledAt: json["scheduledAt"] as String,
    status: json["status"] as String,
    timezone: json["timezone"] == null ? null : json["timezone"] as String,
    title: json["title"] as String,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (applicationId != null) "applicationId": applicationId!,
    "company": company.toJson(),
    "createdAt": createdAt,
    if (createdBy != null) "createdBy": createdBy!,
    if (description != null) "description": description!,
    "durationMinutes": durationMinutes,
    "employee": employee.toJson(),
    "id": id,
    if (location != null) "location": location!,
    if (meetingLink != null) "meetingLink": meetingLink!,
    if (notifyUserId != null) "notifyUserId": notifyUserId!,
    "scheduledAt": scheduledAt,
    "status": status,
    if (timezone != null) "timezone": timezone!,
    "title": title,
    "updatedAt": updatedAt,
  };
}

class ApiImageResponseDTO {
  const ApiImageResponseDTO({this.id, required this.image});
  final String? id;
  final String image;
  factory ApiImageResponseDTO.fromJson(Map<String, dynamic> json) => ApiImageResponseDTO(
    id: json["id"] == null ? null : json["id"] as String,
    image: json["image"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    "image": image,
  };
}

class ApiInitiateChatDTO {
  const ApiInitiateChatDTO({required this.receiverId});
  final String receiverId;
  factory ApiInitiateChatDTO.fromJson(Map<String, dynamic> json) => ApiInitiateChatDTO(
    receiverId: json["receiverId"] as String,
  );
  Map<String, dynamic> toJson() => {
    "receiverId": receiverId,
  };
}

class ApiInitiateChatResponseDTO {
  const ApiInitiateChatResponseDTO({required this.alreadyExists, required this.avatar, required this.chatId, required this.email, required this.id, required this.isRead, required this.name, required this.preview, required this.time});
  final bool alreadyExists;
  final String avatar;
  final String chatId;
  final String email;
  final String id;
  final bool isRead;
  final String name;
  final String preview;
  final String time;
  factory ApiInitiateChatResponseDTO.fromJson(Map<String, dynamic> json) => ApiInitiateChatResponseDTO(
    alreadyExists: json["alreadyExists"] as bool,
    avatar: json["avatar"] as String,
    chatId: json["chatId"] as String,
    email: json["email"] as String,
    id: json["id"] as String,
    isRead: json["isRead"] as bool,
    name: json["name"] as String,
    preview: json["preview"] as String,
    time: json["time"] as String,
  );
  Map<String, dynamic> toJson() => {
    "alreadyExists": alreadyExists,
    "avatar": avatar,
    "chatId": chatId,
    "email": email,
    "id": id,
    "isRead": isRead,
    "name": name,
    "preview": preview,
    "time": time,
  };
}

class ApiInterviewPrepPdfQuestionDTO {
  const ApiInterviewPrepPdfQuestionDTO({required this.category, required this.question, required this.questionKm, required this.tip, required this.tipKm});
  final String category;
  final String question;
  final String questionKm;
  final String tip;
  final String tipKm;
  factory ApiInterviewPrepPdfQuestionDTO.fromJson(Map<String, dynamic> json) => ApiInterviewPrepPdfQuestionDTO(
    category: json["category"] as String,
    question: json["question"] as String,
    questionKm: json["questionKm"] as String,
    tip: json["tip"] as String,
    tipKm: json["tipKm"] as String,
  );
  Map<String, dynamic> toJson() => {
    "category": category,
    "question": question,
    "questionKm": questionKm,
    "tip": tip,
    "tipKm": tipKm,
  };
}

class ApiJobPipelineResponseDTO {
  const ApiJobPipelineResponseDTO({required this.columns, required this.jobId, required this.jobTitle, required this.totalCount});
  final List<ApiPipelineColumnDTO> columns;
  final String jobId;
  final String jobTitle;
  final num totalCount;
  factory ApiJobPipelineResponseDTO.fromJson(Map<String, dynamic> json) => ApiJobPipelineResponseDTO(
    columns: (json["columns"] as List).map((v) => ApiPipelineColumnDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    jobId: json["jobId"] as String,
    jobTitle: json["jobTitle"] as String,
    totalCount: json["totalCount"] as num,
  );
  Map<String, dynamic> toJson() => {
    "columns": columns.map((v) => v.toJson()).toList(),
    "jobId": jobId,
    "jobTitle": jobTitle,
    "totalCount": totalCount,
  };
}

class ApiJobPositionResponseDTO {
  const ApiJobPositionResponseDTO({required this.deadlineDate, required this.description, required this.education, required this.experience, required this.id, this.languagesRequired, this.location, this.openingsCount, required this.postedDate, required this.salary, this.salaryCurrency, this.salaryMax, this.salaryMin, required this.skills, required this.title, required this.type, this.workMode});
  final String? deadlineDate;
  final String description;
  final String education;
  final String experience;
  final String id;
  final List<String>? languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? postedDate;
  final String salary;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final List<String> skills;
  final String title;
  final String type;
  final String? workMode;
  factory ApiJobPositionResponseDTO.fromJson(Map<String, dynamic> json) => ApiJobPositionResponseDTO(
    deadlineDate: json["deadlineDate"] == null ? null : json["deadlineDate"] as String,
    description: json["description"] as String,
    education: json["education"] as String,
    experience: json["experience"] as String,
    id: json["id"] as String,
    languagesRequired: json["languagesRequired"] == null ? null : (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    postedDate: json["postedDate"] == null ? null : json["postedDate"] as String,
    salary: json["salary"] as String,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    title: json["title"] as String,
    type: json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (deadlineDate != null) "deadlineDate": deadlineDate!,
    "description": description,
    "education": education,
    "experience": experience,
    "id": id,
    if (languagesRequired != null) "languagesRequired": languagesRequired!.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (postedDate != null) "postedDate": postedDate!,
    "salary": salary,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    "skills": skills.map((v) => v).toList(),
    "title": title,
    "type": type,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiJobResponseDTO {
  const ApiJobResponseDTO({required this.company, required this.deadlineDate, required this.description, required this.education, required this.experience, required this.id, required this.isHide, this.languagesRequired, this.location, this.openingsCount, required this.postedDate, required this.salary, this.salaryCurrency, this.salaryMax, this.salaryMin, required this.skills, required this.title, required this.type, this.workMode});
  final ApiCompanyInJobResponseDTO company;
  final String? deadlineDate;
  final String description;
  final String education;
  final String experience;
  final String id;
  final bool isHide;
  final List<String>? languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? postedDate;
  final String salary;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final List<String> skills;
  final String title;
  final String type;
  final String? workMode;
  factory ApiJobResponseDTO.fromJson(Map<String, dynamic> json) => ApiJobResponseDTO(
    company: ApiCompanyInJobResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    deadlineDate: json["deadlineDate"] == null ? null : json["deadlineDate"] as String,
    description: json["description"] as String,
    education: json["education"] as String,
    experience: json["experience"] as String,
    id: json["id"] as String,
    isHide: json["isHide"] as bool,
    languagesRequired: json["languagesRequired"] == null ? null : (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    postedDate: json["postedDate"] == null ? null : json["postedDate"] as String,
    salary: json["salary"] as String,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    title: json["title"] as String,
    type: json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    "company": company.toJson(),
    if (deadlineDate != null) "deadlineDate": deadlineDate!,
    "description": description,
    "education": education,
    "experience": experience,
    "id": id,
    "isHide": isHide,
    if (languagesRequired != null) "languagesRequired": languagesRequired!.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (postedDate != null) "postedDate": postedDate!,
    "salary": salary,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    "skills": skills.map((v) => v).toList(),
    "title": title,
    "type": type,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiLandingStatsResponseDTO {
  const ApiLandingStatsResponseDTO({required this.companies, required this.employees, required this.users});
  final num companies;
  final num employees;
  final num users;
  factory ApiLandingStatsResponseDTO.fromJson(Map<String, dynamic> json) => ApiLandingStatsResponseDTO(
    companies: json["companies"] as num,
    employees: json["employees"] as num,
    users: json["users"] as num,
  );
  Map<String, dynamic> toJson() => {
    "companies": companies,
    "employees": employees,
    "users": users,
  };
}

class ApiLivenessResponseDTO {
  const ApiLivenessResponseDTO({required this.release, required this.service, required this.status, required this.timestamp, required this.uptime});
  final String release;
  final String service;
  final String status;
  final String timestamp;
  final num uptime;
  factory ApiLivenessResponseDTO.fromJson(Map<String, dynamic> json) => ApiLivenessResponseDTO(
    release: json["release"] as String,
    service: json["service"] as String,
    status: json["status"] as String,
    timestamp: json["timestamp"] as String,
    uptime: json["uptime"] as num,
  );
  Map<String, dynamic> toJson() => {
    "release": release,
    "service": service,
    "status": status,
    "timestamp": timestamp,
    "uptime": uptime,
  };
}

class ApiLoginDTO {
  const ApiLoginDTO({required this.identifier, required this.password});
  final String identifier;
  final String password;
  factory ApiLoginDTO.fromJson(Map<String, dynamic> json) => ApiLoginDTO(
    identifier: json["identifier"] as String,
    password: json["password"] as String,
  );
  Map<String, dynamic> toJson() => {
    "identifier": identifier,
    "password": password,
  };
}

class ApiLoginOtpDTO {
  const ApiLoginOtpDTO({required this.phone});
  final String phone;
  factory ApiLoginOtpDTO.fromJson(Map<String, dynamic> json) => ApiLoginOtpDTO(
    phone: json["phone"] as String,
  );
  Map<String, dynamic> toJson() => {
    "phone": phone,
  };
}

class ApiLoginOtpResponseDTO {
  const ApiLoginOtpResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiLoginOtpResponseDTO.fromJson(Map<String, dynamic> json) => ApiLoginOtpResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiLoginResponseDTO {
  const ApiLoginResponseDTO({this.accessToken, required this.message, this.refreshToken, this.requiresTwoFactor, this.success, this.twoFactorToken, this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? requiresTwoFactor;
  final bool? success;
  final String? twoFactorToken;
  final ApiUserResponseDTO? user;
  factory ApiLoginResponseDTO.fromJson(Map<String, dynamic> json) => ApiLoginResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    requiresTwoFactor: json["requiresTwoFactor"] == null ? null : json["requiresTwoFactor"] as bool,
    success: json["success"] == null ? null : json["success"] as bool,
    twoFactorToken: json["twoFactorToken"] == null ? null : json["twoFactorToken"] as String,
    user: json["user"] == null ? null : ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (requiresTwoFactor != null) "requiresTwoFactor": requiresTwoFactor!,
    if (success != null) "success": success!,
    if (twoFactorToken != null) "twoFactorToken": twoFactorToken!,
    if (user != null) "user": user!.toJson(),
  };
}

class ApiMarkNotificationAsReadResponseDTO {
  const ApiMarkNotificationAsReadResponseDTO({this.affected, required this.success});
  final num? affected;
  final bool success;
  factory ApiMarkNotificationAsReadResponseDTO.fromJson(Map<String, dynamic> json) => ApiMarkNotificationAsReadResponseDTO(
    affected: json["affected"] == null ? null : json["affected"] as num,
    success: json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    if (affected != null) "affected": affected!,
    "success": success,
  };
}

class ApiMatchAnalyticsItemDTO {
  const ApiMatchAnalyticsItemDTO({required this.avatar, required this.id, required this.matchedAt, required this.name});
  final String? avatar;
  final String id;
  final String matchedAt;
  final String name;
  factory ApiMatchAnalyticsItemDTO.fromJson(Map<String, dynamic> json) => ApiMatchAnalyticsItemDTO(
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    id: json["id"] as String,
    matchedAt: json["matchedAt"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    "id": id,
    "matchedAt": matchedAt,
    "name": name,
  };
}

class ApiMatchCountResponseDTO {
  const ApiMatchCountResponseDTO({required this.count, required this.unseenCount});
  final num count;
  final num unseenCount;
  factory ApiMatchCountResponseDTO.fromJson(Map<String, dynamic> json) => ApiMatchCountResponseDTO(
    count: json["count"] as num,
    unseenCount: json["unseenCount"] as num,
  );
  Map<String, dynamic> toJson() => {
    "count": count,
    "unseenCount": unseenCount,
  };
}

class ApiMatchResponseDTO {
  const ApiMatchResponseDTO({required this.companyLiked, required this.createdAt, required this.employeeLiked, required this.id, required this.isMatched, required this.matchScore, this.notificationTargets, required this.skillScore});
  final bool companyLiked;
  final String createdAt;
  final bool employeeLiked;
  final String id;
  final bool isMatched;
  final num? matchScore;
  final List<String>? notificationTargets;
  final num? skillScore;
  factory ApiMatchResponseDTO.fromJson(Map<String, dynamic> json) => ApiMatchResponseDTO(
    companyLiked: json["companyLiked"] as bool,
    createdAt: json["createdAt"] as String,
    employeeLiked: json["employeeLiked"] as bool,
    id: json["id"] as String,
    isMatched: json["isMatched"] as bool,
    matchScore: json["matchScore"] == null ? null : json["matchScore"] as num,
    notificationTargets: json["notificationTargets"] == null ? null : (json["notificationTargets"] as List).map((v) => v as String).toList(),
    skillScore: json["skillScore"] == null ? null : json["skillScore"] as num,
  );
  Map<String, dynamic> toJson() => {
    "companyLiked": companyLiked,
    "createdAt": createdAt,
    "employeeLiked": employeeLiked,
    "id": id,
    "isMatched": isMatched,
    if (matchScore != null) "matchScore": matchScore!,
    if (notificationTargets != null) "notificationTargets": notificationTargets!.map((v) => v).toList(),
    if (skillScore != null) "skillScore": skillScore!,
  };
}

class ApiMatchingAnalyticsResponseDTO {
  const ApiMatchingAnalyticsResponseDTO({required this.matchRate, required this.monthlyActivity, required this.recentMatches, required this.totalFavorites, required this.totalLikesGiven, required this.totalLikesReceived, required this.totalMatches, required this.weeklyActivity});
  final num matchRate;
  final List<ApiMonthlyActivityItemDTO> monthlyActivity;
  final List<ApiMatchAnalyticsItemDTO> recentMatches;
  final num totalFavorites;
  final num totalLikesGiven;
  final num totalLikesReceived;
  final num totalMatches;
  final List<ApiWeeklyActivityItemDTO> weeklyActivity;
  factory ApiMatchingAnalyticsResponseDTO.fromJson(Map<String, dynamic> json) => ApiMatchingAnalyticsResponseDTO(
    matchRate: json["matchRate"] as num,
    monthlyActivity: (json["monthlyActivity"] as List).map((v) => ApiMonthlyActivityItemDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    recentMatches: (json["recentMatches"] as List).map((v) => ApiMatchAnalyticsItemDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    totalFavorites: json["totalFavorites"] as num,
    totalLikesGiven: json["totalLikesGiven"] as num,
    totalLikesReceived: json["totalLikesReceived"] as num,
    totalMatches: json["totalMatches"] as num,
    weeklyActivity: (json["weeklyActivity"] as List).map((v) => ApiWeeklyActivityItemDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
  );
  Map<String, dynamic> toJson() => {
    "matchRate": matchRate,
    "monthlyActivity": monthlyActivity.map((v) => v.toJson()).toList(),
    "recentMatches": recentMatches.map((v) => v.toJson()).toList(),
    "totalFavorites": totalFavorites,
    "totalLikesGiven": totalLikesGiven,
    "totalLikesReceived": totalLikesReceived,
    "totalMatches": totalMatches,
    "weeklyActivity": weeklyActivity.map((v) => v.toJson()).toList(),
  };
}

class ApiMobileOAuthExchangeDTO {
  const ApiMobileOAuthExchangeDTO({required this.code, required this.codeVerifier});
  final String code;
  final String codeVerifier;
  factory ApiMobileOAuthExchangeDTO.fromJson(Map<String, dynamic> json) => ApiMobileOAuthExchangeDTO(
    code: json["code"] as String,
    codeVerifier: json["codeVerifier"] as String,
  );
  Map<String, dynamic> toJson() => {
    "code": code,
    "codeVerifier": codeVerifier,
  };
}

class ApiMonthlyActivityItemDTO {
  const ApiMonthlyActivityItemDTO({required this.likes, required this.matches, required this.month, required this.received});
  final num likes;
  final num matches;
  final String month;
  final num received;
  factory ApiMonthlyActivityItemDTO.fromJson(Map<String, dynamic> json) => ApiMonthlyActivityItemDTO(
    likes: json["likes"] as num,
    matches: json["matches"] as num,
    month: json["month"] as String,
    received: json["received"] as num,
  );
  Map<String, dynamic> toJson() => {
    "likes": likes,
    "matches": matches,
    "month": month,
    "received": received,
  };
}

class ApiNotificationListByUserResponseDTO {
  const ApiNotificationListByUserResponseDTO({required this.items, required this.limit, required this.page, required this.total});
  final List<ApiGetAllNotificationResponseDTO> items;
  final num limit;
  final num page;
  final num total;
  factory ApiNotificationListByUserResponseDTO.fromJson(Map<String, dynamic> json) => ApiNotificationListByUserResponseDTO(
    items: (json["items"] as List).map((v) => ApiGetAllNotificationResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    limit: json["limit"] as num,
    page: json["page"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "items": items.map((v) => v.toJson()).toList(),
    "limit": limit,
    "page": page,
    "total": total,
  };
}

class ApiNotificationPreferenceResponseDTO {
  const ApiNotificationPreferenceResponseDTO({required this.categories, required this.emailEnabled, required this.pushEnabled});
  final Map<String, dynamic> categories;
  final bool emailEnabled;
  final bool pushEnabled;
  factory ApiNotificationPreferenceResponseDTO.fromJson(Map<String, dynamic> json) => ApiNotificationPreferenceResponseDTO(
    categories: Map<String, dynamic>.from(json["categories"] as Map),
    emailEnabled: json["emailEnabled"] as bool,
    pushEnabled: json["pushEnabled"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "categories": categories,
    "emailEnabled": emailEnabled,
    "pushEnabled": pushEnabled,
  };
}

class ApiOptimizeResumeDTO {
  const ApiOptimizeResumeDTO({this.availability, this.careerScopes, this.design, this.education, required this.experience, required this.personalInfo, this.sectionOrder, required this.skills, this.summary, required this.template, this.yearsOfExperience});
  final String? availability;
  final List<String>? careerScopes;
  final ApiResumeDesignDTO? design;
  final String? education;
  final List<ApiResumeExperienceDTO> experience;
  final ApiPersonalInfoDTO personalInfo;
  final List<String>? sectionOrder;
  final List<String> skills;
  final String? summary;
  final String template;
  final String? yearsOfExperience;
  factory ApiOptimizeResumeDTO.fromJson(Map<String, dynamic> json) => ApiOptimizeResumeDTO(
    availability: json["availability"] == null ? null : json["availability"] as String,
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => v as String).toList(),
    design: json["design"] == null ? null : ApiResumeDesignDTO.fromJson(Map<String, dynamic>.from(json["design"] as Map)),
    education: json["education"] == null ? null : json["education"] as String,
    experience: (json["experience"] as List).map((v) => ApiResumeExperienceDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    personalInfo: ApiPersonalInfoDTO.fromJson(Map<String, dynamic>.from(json["personalInfo"] as Map)),
    sectionOrder: json["sectionOrder"] == null ? null : (json["sectionOrder"] as List).map((v) => v as String).toList(),
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    summary: json["summary"] == null ? null : json["summary"] as String,
    template: json["template"] as String,
    yearsOfExperience: json["yearsOfExperience"] == null ? null : json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (availability != null) "availability": availability!,
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v).toList(),
    if (design != null) "design": design!.toJson(),
    if (education != null) "education": education!,
    "experience": experience.map((v) => v.toJson()).toList(),
    "personalInfo": personalInfo.toJson(),
    if (sectionOrder != null) "sectionOrder": sectionOrder!.map((v) => v).toList(),
    "skills": skills.map((v) => v).toList(),
    if (summary != null) "summary": summary!,
    "template": template,
    if (yearsOfExperience != null) "yearsOfExperience": yearsOfExperience!,
  };
}

class ApiOptimizeResumeResponseDTO {
  const ApiOptimizeResumeResponseDTO({required this.experienceSuggestions, required this.overallFeedback, required this.suggestedSkills, required this.suggestedSummary});
  final List<ApiExperienceSuggestionDTO> experienceSuggestions;
  final String overallFeedback;
  final List<String> suggestedSkills;
  final String suggestedSummary;
  factory ApiOptimizeResumeResponseDTO.fromJson(Map<String, dynamic> json) => ApiOptimizeResumeResponseDTO(
    experienceSuggestions: (json["experienceSuggestions"] as List).map((v) => ApiExperienceSuggestionDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    overallFeedback: json["overallFeedback"] as String,
    suggestedSkills: (json["suggestedSkills"] as List).map((v) => v as String).toList(),
    suggestedSummary: json["suggestedSummary"] as String,
  );
  Map<String, dynamic> toJson() => {
    "experienceSuggestions": experienceSuggestions.map((v) => v.toJson()).toList(),
    "overallFeedback": overallFeedback,
    "suggestedSkills": suggestedSkills.map((v) => v).toList(),
    "suggestedSummary": suggestedSummary,
  };
}

class ApiPersonalInfoDTO {
  const ApiPersonalInfoDTO({this.age, required this.email, required this.fullName, this.job, this.location, this.phone, this.profilePicture, this.socials});
  final num? age;
  final String email;
  final String fullName;
  final String? job;
  final String? location;
  final String? phone;
  final String? profilePicture;
  final Map<String, dynamic>? socials;
  factory ApiPersonalInfoDTO.fromJson(Map<String, dynamic> json) => ApiPersonalInfoDTO(
    age: json["age"] == null ? null : json["age"] as num,
    email: json["email"] as String,
    fullName: json["fullName"] as String,
    job: json["job"] == null ? null : json["job"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profilePicture: json["profilePicture"] == null ? null : json["profilePicture"] as String,
    socials: json["socials"] == null ? null : Map<String, dynamic>.from(json["socials"] as Map),
  );
  Map<String, dynamic> toJson() => {
    if (age != null) "age": age!,
    "email": email,
    "fullName": fullName,
    if (job != null) "job": job!,
    if (location != null) "location": location!,
    if (phone != null) "phone": phone!,
    if (profilePicture != null) "profilePicture": profilePicture!,
    if (socials != null) "socials": socials!,
  };
}

class ApiPipelineColumnDTO {
  const ApiPipelineColumnDTO({required this.applications, required this.count, required this.status});
  final List<ApiGetApplicationResponseDTO> applications;
  final num count;
  final String status;
  factory ApiPipelineColumnDTO.fromJson(Map<String, dynamic> json) => ApiPipelineColumnDTO(
    applications: (json["applications"] as List).map((v) => ApiGetApplicationResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    count: json["count"] as num,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "applications": applications.map((v) => v.toJson()).toList(),
    "count": count,
    "status": status,
  };
}

class ApiPolishCoverLetterDTO {
  const ApiPolishCoverLetterDTO({required this.coverLetterText});
  final String coverLetterText;
  factory ApiPolishCoverLetterDTO.fromJson(Map<String, dynamic> json) => ApiPolishCoverLetterDTO(
    coverLetterText: json["coverLetterText"] as String,
  );
  Map<String, dynamic> toJson() => {
    "coverLetterText": coverLetterText,
  };
}

class ApiPolishCoverLetterResponseDTO {
  const ApiPolishCoverLetterResponseDTO({required this.coverLetter});
  final String coverLetter;
  factory ApiPolishCoverLetterResponseDTO.fromJson(Map<String, dynamic> json) => ApiPolishCoverLetterResponseDTO(
    coverLetter: json["coverLetter"] as String,
  );
  Map<String, dynamic> toJson() => {
    "coverLetter": coverLetter,
  };
}

class ApiProfileAnalyticsResponseDTO {
  const ApiProfileAnalyticsResponseDTO({required this.browsePrivately, required this.profileViews30d, required this.profileViews7d, required this.recentViewers, required this.searchAppearances30d});
  final bool browsePrivately;
  final num profileViews30d;
  final num profileViews7d;
  final List<ApiRecentViewerDTO> recentViewers;
  final num searchAppearances30d;
  factory ApiProfileAnalyticsResponseDTO.fromJson(Map<String, dynamic> json) => ApiProfileAnalyticsResponseDTO(
    browsePrivately: json["browsePrivately"] as bool,
    profileViews30d: json["profileViews30d"] as num,
    profileViews7d: json["profileViews7d"] as num,
    recentViewers: (json["recentViewers"] as List).map((v) => ApiRecentViewerDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    searchAppearances30d: json["searchAppearances30d"] as num,
  );
  Map<String, dynamic> toJson() => {
    "browsePrivately": browsePrivately,
    "profileViews30d": profileViews30d,
    "profileViews7d": profileViews7d,
    "recentViewers": recentViewers.map((v) => v.toJson()).toList(),
    "searchAppearances30d": searchAppearances30d,
  };
}

class ApiPublicCompanyInJobDTO {
  const ApiPublicCompanyInJobDTO({required this.avatar, required this.companySize, required this.id, required this.industry, required this.location, required this.name});
  final String? avatar;
  final num? companySize;
  final String id;
  final String? industry;
  final String? location;
  final String name;
  factory ApiPublicCompanyInJobDTO.fromJson(Map<String, dynamic> json) => ApiPublicCompanyInJobDTO(
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    companySize: json["companySize"] == null ? null : json["companySize"] as num,
    id: json["id"] as String,
    industry: json["industry"] == null ? null : json["industry"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    if (companySize != null) "companySize": companySize!,
    "id": id,
    if (industry != null) "industry": industry!,
    if (location != null) "location": location!,
    "name": name,
  };
}

class ApiPublicJobDetailDTO {
  const ApiPublicJobDetailDTO({required this.company, required this.createdAt, required this.description, required this.educationRequired, required this.experienceRequired, required this.expireDate, required this.id, required this.languagesRequired, required this.location, required this.openingsCount, required this.salary, required this.salaryCurrency, required this.salaryMax, required this.salaryMin, required this.skills, required this.title, required this.type, required this.workMode});
  final ApiPublicCompanyInJobDTO company;
  final String createdAt;
  final String description;
  final String educationRequired;
  final String experienceRequired;
  final String? expireDate;
  final String id;
  final List<String> languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? salary;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final List<String> skills;
  final String title;
  final String type;
  final String? workMode;
  factory ApiPublicJobDetailDTO.fromJson(Map<String, dynamic> json) => ApiPublicJobDetailDTO(
    company: ApiPublicCompanyInJobDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] as String,
    description: json["description"] as String,
    educationRequired: json["educationRequired"] as String,
    experienceRequired: json["experienceRequired"] as String,
    expireDate: json["expireDate"] == null ? null : json["expireDate"] as String,
    id: json["id"] as String,
    languagesRequired: (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    salary: json["salary"] == null ? null : json["salary"] as String,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    title: json["title"] as String,
    type: json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    "company": company.toJson(),
    "createdAt": createdAt,
    "description": description,
    "educationRequired": educationRequired,
    "experienceRequired": experienceRequired,
    if (expireDate != null) "expireDate": expireDate!,
    "id": id,
    "languagesRequired": languagesRequired.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (salary != null) "salary": salary!,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    "skills": skills.map((v) => v).toList(),
    "title": title,
    "type": type,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiPublicJobSitemapEntryDTO {
  const ApiPublicJobSitemapEntryDTO({required this.id, required this.updatedAt});
  final String id;
  final String updatedAt;
  factory ApiPublicJobSitemapEntryDTO.fromJson(Map<String, dynamic> json) => ApiPublicJobSitemapEntryDTO(
    id: json["id"] as String,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "updatedAt": updatedAt,
  };
}

class ApiReadAllNotificationResponseDTO {
  const ApiReadAllNotificationResponseDTO({this.affected, required this.success});
  final num? affected;
  final bool success;
  factory ApiReadAllNotificationResponseDTO.fromJson(Map<String, dynamic> json) => ApiReadAllNotificationResponseDTO(
    affected: json["affected"] == null ? null : json["affected"] as num,
    success: json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    if (affected != null) "affected": affected!,
    "success": success,
  };
}

class ApiRecentViewerDTO {
  const ApiRecentViewerDTO({required this.viewedAt, required this.viewerAvatar, required this.viewerId, required this.viewerName, required this.viewerRole});
  final String viewedAt;
  final String? viewerAvatar;
  final String? viewerId;
  final String? viewerName;
  final String? viewerRole;
  factory ApiRecentViewerDTO.fromJson(Map<String, dynamic> json) => ApiRecentViewerDTO(
    viewedAt: json["viewedAt"] as String,
    viewerAvatar: json["viewerAvatar"] == null ? null : json["viewerAvatar"] as String,
    viewerId: json["viewerId"] == null ? null : json["viewerId"] as String,
    viewerName: json["viewerName"] == null ? null : json["viewerName"] as String,
    viewerRole: json["viewerRole"] == null ? null : json["viewerRole"] as String,
  );
  Map<String, dynamic> toJson() => {
    "viewedAt": viewedAt,
    if (viewerAvatar != null) "viewerAvatar": viewerAvatar!,
    if (viewerId != null) "viewerId": viewerId!,
    if (viewerName != null) "viewerName": viewerName!,
    if (viewerRole != null) "viewerRole": viewerRole!,
  };
}

class ApiRefineProfileBioDTO {
  const ApiRefineProfileBioDTO({this.availability, this.benefits, this.careerScopes, this.companyName, this.currentText, this.experience, this.industry, this.jobTitle, this.openPositions, this.skills, required this.type, this.values});
  final String? availability;
  final List<String>? benefits;
  final List<String>? careerScopes;
  final String? companyName;
  final String? currentText;
  final String? experience;
  final String? industry;
  final String? jobTitle;
  final List<String>? openPositions;
  final List<String>? skills;
  final String type;
  final List<String>? values;
  factory ApiRefineProfileBioDTO.fromJson(Map<String, dynamic> json) => ApiRefineProfileBioDTO(
    availability: json["availability"] == null ? null : json["availability"] as String,
    benefits: json["benefits"] == null ? null : (json["benefits"] as List).map((v) => v as String).toList(),
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => v as String).toList(),
    companyName: json["companyName"] == null ? null : json["companyName"] as String,
    currentText: json["currentText"] == null ? null : json["currentText"] as String,
    experience: json["experience"] == null ? null : json["experience"] as String,
    industry: json["industry"] == null ? null : json["industry"] as String,
    jobTitle: json["jobTitle"] == null ? null : json["jobTitle"] as String,
    openPositions: json["openPositions"] == null ? null : (json["openPositions"] as List).map((v) => v as String).toList(),
    skills: json["skills"] == null ? null : (json["skills"] as List).map((v) => v as String).toList(),
    type: json["type"] as String,
    values: json["values"] == null ? null : (json["values"] as List).map((v) => v as String).toList(),
  );
  Map<String, dynamic> toJson() => {
    if (availability != null) "availability": availability!,
    if (benefits != null) "benefits": benefits!.map((v) => v).toList(),
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v).toList(),
    if (companyName != null) "companyName": companyName!,
    if (currentText != null) "currentText": currentText!,
    if (experience != null) "experience": experience!,
    if (industry != null) "industry": industry!,
    if (jobTitle != null) "jobTitle": jobTitle!,
    if (openPositions != null) "openPositions": openPositions!.map((v) => v).toList(),
    if (skills != null) "skills": skills!.map((v) => v).toList(),
    "type": type,
    if (values != null) "values": values!.map((v) => v).toList(),
  };
}

class ApiRefreshTokenRequestDTO {
  const ApiRefreshTokenRequestDTO({this.refreshToken});
  final String? refreshToken;
  factory ApiRefreshTokenRequestDTO.fromJson(Map<String, dynamic> json) => ApiRefreshTokenRequestDTO(
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (refreshToken != null) "refreshToken": refreshToken!,
  };
}

class ApiRefreshTokenResponseDTO {
  const ApiRefreshTokenResponseDTO({this.accessToken, required this.message, this.refreshToken, this.requiresTwoFactor, this.success, this.twoFactorToken, this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? requiresTwoFactor;
  final bool? success;
  final String? twoFactorToken;
  final ApiUserResponseDTO? user;
  factory ApiRefreshTokenResponseDTO.fromJson(Map<String, dynamic> json) => ApiRefreshTokenResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    requiresTwoFactor: json["requiresTwoFactor"] == null ? null : json["requiresTwoFactor"] as bool,
    success: json["success"] == null ? null : json["success"] as bool,
    twoFactorToken: json["twoFactorToken"] == null ? null : json["twoFactorToken"] as String,
    user: json["user"] == null ? null : ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (requiresTwoFactor != null) "requiresTwoFactor": requiresTwoFactor!,
    if (success != null) "success": success!,
    if (twoFactorToken != null) "twoFactorToken": twoFactorToken!,
    if (user != null) "user": user!.toJson(),
  };
}

class ApiRegisterCompanyBenefitDTO {
  const ApiRegisterCompanyBenefitDTO({required this.label});
  final String label;
  factory ApiRegisterCompanyBenefitDTO.fromJson(Map<String, dynamic> json) => ApiRegisterCompanyBenefitDTO(
    label: json["label"] as String,
  );
  Map<String, dynamic> toJson() => {
    "label": label,
  };
}

class ApiRegisterCompanyCareerScopeDTO {
  const ApiRegisterCompanyCareerScopeDTO({this.description, required this.name});
  final String? description;
  final String name;
  factory ApiRegisterCompanyCareerScopeDTO.fromJson(Map<String, dynamic> json) => ApiRegisterCompanyCareerScopeDTO(
    description: json["description"] == null ? null : json["description"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    "name": name,
  };
}

class ApiRegisterCompanyJobDTO {
  const ApiRegisterCompanyJobDTO({required this.description, required this.educationRequired, required this.experienceRequired, required this.expireDate, this.languagesRequired, this.location, this.openingsCount, this.salary, this.salaryCurrency, this.salaryMax, this.salaryMin, required this.skillsRequired, required this.title, required this.type, this.workMode});
  final String description;
  final String educationRequired;
  final String experienceRequired;
  final String expireDate;
  final List<String>? languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? salary;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final String skillsRequired;
  final String title;
  final String type;
  final String? workMode;
  factory ApiRegisterCompanyJobDTO.fromJson(Map<String, dynamic> json) => ApiRegisterCompanyJobDTO(
    description: json["description"] as String,
    educationRequired: json["educationRequired"] as String,
    experienceRequired: json["experienceRequired"] as String,
    expireDate: json["expireDate"] as String,
    languagesRequired: json["languagesRequired"] == null ? null : (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    salary: json["salary"] == null ? null : json["salary"] as String,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skillsRequired: json["skillsRequired"] as String,
    title: json["title"] as String,
    type: json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    "description": description,
    "educationRequired": educationRequired,
    "experienceRequired": experienceRequired,
    "expireDate": expireDate,
    if (languagesRequired != null) "languagesRequired": languagesRequired!.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (salary != null) "salary": salary!,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    "skillsRequired": skillsRequired,
    "title": title,
    "type": type,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiRegisterCompanySocialDTO {
  const ApiRegisterCompanySocialDTO({this.platform, this.url});
  final String? platform;
  final String? url;
  factory ApiRegisterCompanySocialDTO.fromJson(Map<String, dynamic> json) => ApiRegisterCompanySocialDTO(
    platform: json["platform"] == null ? null : json["platform"] as String,
    url: json["url"] == null ? null : json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (platform != null) "platform": platform!,
    if (url != null) "url": url!,
  };
}

class ApiRegisterCompanyValueDTO {
  const ApiRegisterCompanyValueDTO({required this.label});
  final String label;
  factory ApiRegisterCompanyValueDTO.fromJson(Map<String, dynamic> json) => ApiRegisterCompanyValueDTO(
    label: json["label"] as String,
  );
  Map<String, dynamic> toJson() => {
    "label": label,
  };
}

class ApiRegisterEmployeeCareerScopeDTO {
  const ApiRegisterEmployeeCareerScopeDTO({this.description, required this.name});
  final String? description;
  final String name;
  factory ApiRegisterEmployeeCareerScopeDTO.fromJson(Map<String, dynamic> json) => ApiRegisterEmployeeCareerScopeDTO(
    description: json["description"] == null ? null : json["description"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    "name": name,
  };
}

class ApiRegisterEmployeeEducationDTO {
  const ApiRegisterEmployeeEducationDTO({required this.degree, this.school, required this.year});
  final String degree;
  final String? school;
  final String year;
  factory ApiRegisterEmployeeEducationDTO.fromJson(Map<String, dynamic> json) => ApiRegisterEmployeeEducationDTO(
    degree: json["degree"] as String,
    school: json["school"] == null ? null : json["school"] as String,
    year: json["year"] as String,
  );
  Map<String, dynamic> toJson() => {
    "degree": degree,
    if (school != null) "school": school!,
    "year": year,
  };
}

class ApiRegisterEmployeeExperienceDTO {
  const ApiRegisterEmployeeExperienceDTO({this.company, required this.description, required this.endDate, required this.startDate, required this.title});
  final String? company;
  final String description;
  final String endDate;
  final String startDate;
  final String title;
  factory ApiRegisterEmployeeExperienceDTO.fromJson(Map<String, dynamic> json) => ApiRegisterEmployeeExperienceDTO(
    company: json["company"] == null ? null : json["company"] as String,
    description: json["description"] as String,
    endDate: json["endDate"] as String,
    startDate: json["startDate"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!,
    "description": description,
    "endDate": endDate,
    "startDate": startDate,
    "title": title,
  };
}

class ApiRegisterEmployeeSkillDTO {
  const ApiRegisterEmployeeSkillDTO({this.description, required this.name});
  final String? description;
  final String name;
  factory ApiRegisterEmployeeSkillDTO.fromJson(Map<String, dynamic> json) => ApiRegisterEmployeeSkillDTO(
    description: json["description"] == null ? null : json["description"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    "name": name,
  };
}

class ApiRegisterEmployeeSocialDTO {
  const ApiRegisterEmployeeSocialDTO({this.platform, this.url});
  final String? platform;
  final String? url;
  factory ApiRegisterEmployeeSocialDTO.fromJson(Map<String, dynamic> json) => ApiRegisterEmployeeSocialDTO(
    platform: json["platform"] == null ? null : json["platform"] as String,
    url: json["url"] == null ? null : json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (platform != null) "platform": platform!,
    if (url != null) "url": url!,
  };
}

class ApiRemoveCompanyAvatarResponseDTO {
  const ApiRemoveCompanyAvatarResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveCompanyAvatarResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveCompanyAvatarResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveCompanyCoverResponseDTO {
  const ApiRemoveCompanyCoverResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveCompanyCoverResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveCompanyCoverResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveCompanyImageResponseDTO {
  const ApiRemoveCompanyImageResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveCompanyImageResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveCompanyImageResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveEmployeeAvatarResponseDTO {
  const ApiRemoveEmployeeAvatarResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveEmployeeAvatarResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveEmployeeAvatarResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveEmployeeCoverLetterResponseDTO {
  const ApiRemoveEmployeeCoverLetterResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveEmployeeCoverLetterResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveEmployeeCoverLetterResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveEmployeeEducationResponseDTO {
  const ApiRemoveEmployeeEducationResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveEmployeeEducationResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveEmployeeEducationResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveEmployeeExperienceResponseDTO {
  const ApiRemoveEmployeeExperienceResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveEmployeeExperienceResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveEmployeeExperienceResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveEmployeeResumeResponseDTO {
  const ApiRemoveEmployeeResumeResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveEmployeeResumeResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveEmployeeResumeResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiRemoveOpenPositionResponseDTO {
  const ApiRemoveOpenPositionResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiRemoveOpenPositionResponseDTO.fromJson(Map<String, dynamic> json) => ApiRemoveOpenPositionResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiReportProblemBodyDTO {
  const ApiReportProblemBodyDTO({required this.category, required this.details, this.pageUrl, this.userAgent});
  final String category;
  final String details;
  final String? pageUrl;
  final String? userAgent;
  factory ApiReportProblemBodyDTO.fromJson(Map<String, dynamic> json) => ApiReportProblemBodyDTO(
    category: json["category"] as String,
    details: json["details"] as String,
    pageUrl: json["pageUrl"] == null ? null : json["pageUrl"] as String,
    userAgent: json["userAgent"] == null ? null : json["userAgent"] as String,
  );
  Map<String, dynamic> toJson() => {
    "category": category,
    "details": details,
    if (pageUrl != null) "pageUrl": pageUrl!,
    if (userAgent != null) "userAgent": userAgent!,
  };
}

class ApiReportProblemResponseDTO {
  const ApiReportProblemResponseDTO({required this.message});
  final String message;
  factory ApiReportProblemResponseDTO.fromJson(Map<String, dynamic> json) => ApiReportProblemResponseDTO(
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
  };
}

class ApiReportUserResponseDTO {
  const ApiReportUserResponseDTO({required this.message, required this.reportId});
  final String message;
  final String reportId;
  factory ApiReportUserResponseDTO.fromJson(Map<String, dynamic> json) => ApiReportUserResponseDTO(
    message: json["message"] as String,
    reportId: json["reportId"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    "reportId": reportId,
  };
}

class ApiRequestAccountDeletionResponseDTO {
  const ApiRequestAccountDeletionResponseDTO({required this.message, required this.scheduledFor});
  final String message;
  final String scheduledFor;
  factory ApiRequestAccountDeletionResponseDTO.fromJson(Map<String, dynamic> json) => ApiRequestAccountDeletionResponseDTO(
    message: json["message"] as String,
    scheduledFor: json["scheduledFor"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    "scheduledFor": scheduledFor,
  };
}

class ApiResendEmailOtpDTO {
  const ApiResendEmailOtpDTO({required this.email});
  final String email;
  factory ApiResendEmailOtpDTO.fromJson(Map<String, dynamic> json) => ApiResendEmailOtpDTO(
    email: json["email"] as String,
  );
  Map<String, dynamic> toJson() => {
    "email": email,
  };
}

class ApiResendEmailOtpResponseDTO {
  const ApiResendEmailOtpResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiResendEmailOtpResponseDTO.fromJson(Map<String, dynamic> json) => ApiResendEmailOtpResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiResetPasswordDTO {
  const ApiResetPasswordDTO({required this.confirmPassword, required this.newPassword, this.token});
  final String confirmPassword;
  final String newPassword;
  final String? token;
  factory ApiResetPasswordDTO.fromJson(Map<String, dynamic> json) => ApiResetPasswordDTO(
    confirmPassword: json["confirmPassword"] as String,
    newPassword: json["newPassword"] as String,
    token: json["token"] == null ? null : json["token"] as String,
  );
  Map<String, dynamic> toJson() => {
    "confirmPassword": confirmPassword,
    "newPassword": newPassword,
    if (token != null) "token": token!,
  };
}

class ApiResetPasswordResponseDTO {
  const ApiResetPasswordResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiResetPasswordResponseDTO.fromJson(Map<String, dynamic> json) => ApiResetPasswordResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiResumeDesignDTO {
  const ApiResumeDesignDTO({required this.avatarPlacement, required this.columnRatio, required this.cornerStyle, this.customAccent, required this.decoration, required this.density, required this.educationStyle, required this.experienceStyle, required this.headerLayout, required this.headerStyle, required this.layout, required this.palette, required this.sectionStyle, required this.sidebarSections, required this.skillsStyle, required this.summaryStyle, required this.typography});
  final String avatarPlacement;
  final String columnRatio;
  final String cornerStyle;
  final String? customAccent;
  final String decoration;
  final String density;
  final String educationStyle;
  final String experienceStyle;
  final String headerLayout;
  final String headerStyle;
  final String layout;
  final String palette;
  final String sectionStyle;
  final List<String> sidebarSections;
  final String skillsStyle;
  final String summaryStyle;
  final String typography;
  factory ApiResumeDesignDTO.fromJson(Map<String, dynamic> json) => ApiResumeDesignDTO(
    avatarPlacement: json["avatarPlacement"] as String,
    columnRatio: json["columnRatio"] as String,
    cornerStyle: json["cornerStyle"] as String,
    customAccent: json["customAccent"] == null ? null : json["customAccent"] as String,
    decoration: json["decoration"] as String,
    density: json["density"] as String,
    educationStyle: json["educationStyle"] as String,
    experienceStyle: json["experienceStyle"] as String,
    headerLayout: json["headerLayout"] as String,
    headerStyle: json["headerStyle"] as String,
    layout: json["layout"] as String,
    palette: json["palette"] as String,
    sectionStyle: json["sectionStyle"] as String,
    sidebarSections: (json["sidebarSections"] as List).map((v) => v as String).toList(),
    skillsStyle: json["skillsStyle"] as String,
    summaryStyle: json["summaryStyle"] as String,
    typography: json["typography"] as String,
  );
  Map<String, dynamic> toJson() => {
    "avatarPlacement": avatarPlacement,
    "columnRatio": columnRatio,
    "cornerStyle": cornerStyle,
    if (customAccent != null) "customAccent": customAccent!,
    "decoration": decoration,
    "density": density,
    "educationStyle": educationStyle,
    "experienceStyle": experienceStyle,
    "headerLayout": headerLayout,
    "headerStyle": headerStyle,
    "layout": layout,
    "palette": palette,
    "sectionStyle": sectionStyle,
    "sidebarSections": sidebarSections.map((v) => v).toList(),
    "skillsStyle": skillsStyle,
    "summaryStyle": summaryStyle,
    "typography": typography,
  };
}

class ApiResumeDraftRecordDTO {
  const ApiResumeDraftRecordDTO({required this.content, required this.createdAt, required this.id, required this.name, required this.revision, required this.updatedAt});
  final Map<String, dynamic> content;
  final String createdAt;
  final String id;
  final String name;
  final num revision;
  final String updatedAt;
  factory ApiResumeDraftRecordDTO.fromJson(Map<String, dynamic> json) => ApiResumeDraftRecordDTO(
    content: Map<String, dynamic>.from(json["content"] as Map),
    createdAt: json["createdAt"] as String,
    id: json["id"] as String,
    name: json["name"] as String,
    revision: json["revision"] as num,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "content": content,
    "createdAt": createdAt,
    "id": id,
    "name": name,
    "revision": revision,
    "updatedAt": updatedAt,
  };
}

class ApiResumeDraftSummaryDTO {
  const ApiResumeDraftSummaryDTO({required this.createdAt, required this.id, required this.name, required this.revision, required this.updatedAt});
  final String createdAt;
  final String id;
  final String name;
  final num revision;
  final String updatedAt;
  factory ApiResumeDraftSummaryDTO.fromJson(Map<String, dynamic> json) => ApiResumeDraftSummaryDTO(
    createdAt: json["createdAt"] as String,
    id: json["id"] as String,
    name: json["name"] as String,
    revision: json["revision"] as num,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "id": id,
    "name": name,
    "revision": revision,
    "updatedAt": updatedAt,
  };
}

class ApiResumeExperienceDTO {
  const ApiResumeExperienceDTO({required this.achievements, required this.company, required this.description, this.endDate, required this.position, required this.startDate});
  final List<String> achievements;
  final String company;
  final String description;
  final String? endDate;
  final String position;
  final String startDate;
  factory ApiResumeExperienceDTO.fromJson(Map<String, dynamic> json) => ApiResumeExperienceDTO(
    achievements: (json["achievements"] as List).map((v) => v as String).toList(),
    company: json["company"] as String,
    description: json["description"] as String,
    endDate: json["endDate"] == null ? null : json["endDate"] as String,
    position: json["position"] as String,
    startDate: json["startDate"] as String,
  );
  Map<String, dynamic> toJson() => {
    "achievements": achievements.map((v) => v).toList(),
    "company": company,
    "description": description,
    if (endDate != null) "endDate": endDate!,
    "position": position,
    "startDate": startDate,
  };
}

class ApiResumeTemplateResponseDTO {
  const ApiResumeTemplateResponseDTO({required this.createdAt, required this.description, required this.id, required this.image, required this.isPremium, required this.price, required this.templateKey, required this.title});
  final String createdAt;
  final String description;
  final String id;
  final String? image;
  final bool isPremium;
  final num? price;
  final String templateKey;
  final String title;
  factory ApiResumeTemplateResponseDTO.fromJson(Map<String, dynamic> json) => ApiResumeTemplateResponseDTO(
    createdAt: json["createdAt"] as String,
    description: json["description"] as String,
    id: json["id"] as String,
    image: json["image"] == null ? null : json["image"] as String,
    isPremium: json["isPremium"] as bool,
    price: json["price"] == null ? null : json["price"] as num,
    templateKey: json["templateKey"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "description": description,
    "id": id,
    if (image != null) "image": image!,
    "isPremium": isPremium,
    if (price != null) "price": price!,
    "templateKey": templateKey,
    "title": title,
  };
}

class ApiSavedSearchPreviewResponseDTO {
  const ApiSavedSearchPreviewResponseDTO({required this.newMatchCount, required this.totalMatches});
  final num newMatchCount;
  final num totalMatches;
  factory ApiSavedSearchPreviewResponseDTO.fromJson(Map<String, dynamic> json) => ApiSavedSearchPreviewResponseDTO(
    newMatchCount: json["newMatchCount"] as num,
    totalMatches: json["totalMatches"] as num,
  );
  Map<String, dynamic> toJson() => {
    "newMatchCount": newMatchCount,
    "totalMatches": totalMatches,
  };
}

class ApiSavedSearchResponseDTO {
  const ApiSavedSearchResponseDTO({required this.createdAt, required this.filters, required this.frequency, required this.id, required this.lastNotifiedAt, required this.lastResultJobIds, required this.name, required this.updatedAt});
  final String createdAt;
  final Map<String, dynamic> filters;
  final String frequency;
  final String id;
  final String? lastNotifiedAt;
  final List<String> lastResultJobIds;
  final String name;
  final String updatedAt;
  factory ApiSavedSearchResponseDTO.fromJson(Map<String, dynamic> json) => ApiSavedSearchResponseDTO(
    createdAt: json["createdAt"] as String,
    filters: Map<String, dynamic>.from(json["filters"] as Map),
    frequency: json["frequency"] as String,
    id: json["id"] as String,
    lastNotifiedAt: json["lastNotifiedAt"] == null ? null : json["lastNotifiedAt"] as String,
    lastResultJobIds: (json["lastResultJobIds"] as List).map((v) => v as String).toList(),
    name: json["name"] as String,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "filters": filters,
    "frequency": frequency,
    "id": id,
    if (lastNotifiedAt != null) "lastNotifiedAt": lastNotifiedAt!,
    "lastResultJobIds": lastResultJobIds.map((v) => v).toList(),
    "name": name,
    "updatedAt": updatedAt,
  };
}

class ApiSearchEmployeeResponseDTO {
  const ApiSearchEmployeeResponseDTO({required this.availability, this.avatar, this.careerScopes, this.coverLetter, this.createdAt, required this.description, this.dob, this.educations, this.email, this.expectedSalaryMax, this.expectedSalaryMin, this.experiences, required this.firstname, required this.gender, required this.id, required this.isHide, required this.job, this.languages, required this.lastname, this.linkedinUrl, required this.location, this.noticePeriod, required this.phone, this.portfolioUrl, this.resume, this.skills, this.socials, this.updatedAt, this.userId, required this.username, this.workMode, required this.yearsOfExperience});
  final String availability;
  final String? avatar;
  final List<ApiCareerScopesResponseDTO>? careerScopes;
  final String? coverLetter;
  final String? createdAt;
  final String description;
  final String? dob;
  final List<ApiEducationResponseDTO>? educations;
  final String? email;
  final num? expectedSalaryMax;
  final num? expectedSalaryMin;
  final List<ApiExperienceResponseDTO>? experiences;
  final String firstname;
  final String gender;
  final String id;
  final bool isHide;
  final String job;
  final List<String>? languages;
  final String lastname;
  final String? linkedinUrl;
  final String location;
  final String? noticePeriod;
  final String phone;
  final String? portfolioUrl;
  final String? resume;
  final List<ApiSkillResponseDTO>? skills;
  final List<ApiSocialResponseDTO>? socials;
  final String? updatedAt;
  final String? userId;
  final String username;
  final String? workMode;
  final String yearsOfExperience;
  factory ApiSearchEmployeeResponseDTO.fromJson(Map<String, dynamic> json) => ApiSearchEmployeeResponseDTO(
    availability: json["availability"] as String,
    avatar: json["avatar"] == null ? null : json["avatar"] as String,
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiCareerScopesResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    coverLetter: json["coverLetter"] == null ? null : json["coverLetter"] as String,
    createdAt: json["createdAt"] == null ? null : json["createdAt"] as String,
    description: json["description"] as String,
    dob: json["dob"] == null ? null : json["dob"] as String,
    educations: json["educations"] == null ? null : (json["educations"] as List).map((v) => ApiEducationResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    email: json["email"] == null ? null : json["email"] as String,
    expectedSalaryMax: json["expectedSalaryMax"] == null ? null : json["expectedSalaryMax"] as num,
    expectedSalaryMin: json["expectedSalaryMin"] == null ? null : json["expectedSalaryMin"] as num,
    experiences: json["experiences"] == null ? null : (json["experiences"] as List).map((v) => ApiExperienceResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    firstname: json["firstname"] as String,
    gender: json["gender"] as String,
    id: json["id"] as String,
    isHide: json["isHide"] as bool,
    job: json["job"] as String,
    languages: json["languages"] == null ? null : (json["languages"] as List).map((v) => v as String).toList(),
    lastname: json["lastname"] as String,
    linkedinUrl: json["linkedinUrl"] == null ? null : json["linkedinUrl"] as String,
    location: json["location"] as String,
    noticePeriod: json["noticePeriod"] == null ? null : json["noticePeriod"] as String,
    phone: json["phone"] as String,
    portfolioUrl: json["portfolioUrl"] == null ? null : json["portfolioUrl"] as String,
    resume: json["resume"] == null ? null : json["resume"] as String,
    skills: json["skills"] == null ? null : (json["skills"] as List).map((v) => ApiSkillResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiSocialResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    updatedAt: json["updatedAt"] == null ? null : json["updatedAt"] as String,
    userId: json["userId"] == null ? null : json["userId"] as String,
    username: json["username"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
    yearsOfExperience: json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    "availability": availability,
    if (avatar != null) "avatar": avatar!,
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    if (coverLetter != null) "coverLetter": coverLetter!,
    if (createdAt != null) "createdAt": createdAt!,
    "description": description,
    if (dob != null) "dob": dob!,
    if (educations != null) "educations": educations!.map((v) => v.toJson()).toList(),
    if (email != null) "email": email!,
    if (expectedSalaryMax != null) "expectedSalaryMax": expectedSalaryMax!,
    if (expectedSalaryMin != null) "expectedSalaryMin": expectedSalaryMin!,
    if (experiences != null) "experiences": experiences!.map((v) => v.toJson()).toList(),
    "firstname": firstname,
    "gender": gender,
    "id": id,
    "isHide": isHide,
    "job": job,
    if (languages != null) "languages": languages!.map((v) => v).toList(),
    "lastname": lastname,
    if (linkedinUrl != null) "linkedinUrl": linkedinUrl!,
    "location": location,
    if (noticePeriod != null) "noticePeriod": noticePeriod!,
    "phone": phone,
    if (portfolioUrl != null) "portfolioUrl": portfolioUrl!,
    if (resume != null) "resume": resume!,
    if (skills != null) "skills": skills!.map((v) => v.toJson()).toList(),
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (updatedAt != null) "updatedAt": updatedAt!,
    if (userId != null) "userId": userId!,
    "username": username,
    if (workMode != null) "workMode": workMode!,
    "yearsOfExperience": yearsOfExperience,
  };
}

class ApiSearchEmployeeResult {
  const ApiSearchEmployeeResult({required this.data, required this.isUsingFallback, required this.page, required this.pageSize, required this.total});
  final List<ApiSearchEmployeeResponseDTO> data;
  final bool isUsingFallback;
  final num page;
  final num pageSize;
  final num total;
  factory ApiSearchEmployeeResult.fromJson(Map<String, dynamic> json) => ApiSearchEmployeeResult(
    data: (json["data"] as List).map((v) => ApiSearchEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    isUsingFallback: json["isUsingFallback"] as bool,
    page: json["page"] as num,
    pageSize: json["pageSize"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "data": data.map((v) => v.toJson()).toList(),
    "isUsingFallback": isUsingFallback,
    "page": page,
    "pageSize": pageSize,
    "total": total,
  };
}

class ApiSearchJobDTO {
  const ApiSearchJobDTO({this.careerScopes, this.companySizeMax, this.companySizeMin, this.educationRequired, this.excludeCompanyIds, this.experienceLevel, this.jobType, this.keyword, this.location, this.page, this.pageSize, this.postedDateFrom, this.postedDateTo, this.requesterId, this.salaryMax, this.salaryMin, this.sortBy, this.sortOrder, this.workMode});
  final List<String>? careerScopes;
  final num? companySizeMax;
  final num? companySizeMin;
  final List<String>? educationRequired;
  final List<String>? excludeCompanyIds;
  final String? experienceLevel;
  final List<String>? jobType;
  final String? keyword;
  final String? location;
  final num? page;
  final num? pageSize;
  final String? postedDateFrom;
  final String? postedDateTo;
  final String? requesterId;
  final num? salaryMax;
  final num? salaryMin;
  final String? sortBy;
  final String? sortOrder;
  final String? workMode;
  factory ApiSearchJobDTO.fromJson(Map<String, dynamic> json) => ApiSearchJobDTO(
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => v as String).toList(),
    companySizeMax: json["companySizeMax"] == null ? null : json["companySizeMax"] as num,
    companySizeMin: json["companySizeMin"] == null ? null : json["companySizeMin"] as num,
    educationRequired: json["educationRequired"] == null ? null : (json["educationRequired"] as List).map((v) => v as String).toList(),
    excludeCompanyIds: json["excludeCompanyIds"] == null ? null : (json["excludeCompanyIds"] as List).map((v) => v as String).toList(),
    experienceLevel: json["experienceLevel"] == null ? null : json["experienceLevel"] as String,
    jobType: json["jobType"] == null ? null : (json["jobType"] as List).map((v) => v as String).toList(),
    keyword: json["keyword"] == null ? null : json["keyword"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    page: json["page"] == null ? null : json["page"] as num,
    pageSize: json["pageSize"] == null ? null : json["pageSize"] as num,
    postedDateFrom: json["postedDateFrom"] == null ? null : json["postedDateFrom"] as String,
    postedDateTo: json["postedDateTo"] == null ? null : json["postedDateTo"] as String,
    requesterId: json["requesterId"] == null ? null : json["requesterId"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    sortBy: json["sortBy"] == null ? null : json["sortBy"] as String,
    sortOrder: json["sortOrder"] == null ? null : json["sortOrder"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v).toList(),
    if (companySizeMax != null) "companySizeMax": companySizeMax!,
    if (companySizeMin != null) "companySizeMin": companySizeMin!,
    if (educationRequired != null) "educationRequired": educationRequired!.map((v) => v).toList(),
    if (excludeCompanyIds != null) "excludeCompanyIds": excludeCompanyIds!.map((v) => v).toList(),
    if (experienceLevel != null) "experienceLevel": experienceLevel!,
    if (jobType != null) "jobType": jobType!.map((v) => v).toList(),
    if (keyword != null) "keyword": keyword!,
    if (location != null) "location": location!,
    if (page != null) "page": page!,
    if (pageSize != null) "pageSize": pageSize!,
    if (postedDateFrom != null) "postedDateFrom": postedDateFrom!,
    if (postedDateTo != null) "postedDateTo": postedDateTo!,
    if (requesterId != null) "requesterId": requesterId!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    if (sortBy != null) "sortBy": sortBy!,
    if (sortOrder != null) "sortOrder": sortOrder!,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiSearchJobResponseDTO {
  const ApiSearchJobResponseDTO({required this.company, required this.deadlineDate, required this.description, required this.education, required this.experience, required this.id, required this.isHide, this.languagesRequired, this.location, this.openingsCount, required this.postedDate, required this.salary, this.salaryCurrency, this.salaryMax, this.salaryMin, required this.skills, required this.title, required this.type, this.workMode});
  final ApiCompanyInJobResponseDTO company;
  final String? deadlineDate;
  final String description;
  final String education;
  final String experience;
  final String id;
  final bool isHide;
  final List<String>? languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? postedDate;
  final String salary;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final List<String> skills;
  final String title;
  final String type;
  final String? workMode;
  factory ApiSearchJobResponseDTO.fromJson(Map<String, dynamic> json) => ApiSearchJobResponseDTO(
    company: ApiCompanyInJobResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    deadlineDate: json["deadlineDate"] == null ? null : json["deadlineDate"] as String,
    description: json["description"] as String,
    education: json["education"] as String,
    experience: json["experience"] as String,
    id: json["id"] as String,
    isHide: json["isHide"] as bool,
    languagesRequired: json["languagesRequired"] == null ? null : (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    postedDate: json["postedDate"] == null ? null : json["postedDate"] as String,
    salary: json["salary"] as String,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skills: (json["skills"] as List).map((v) => v as String).toList(),
    title: json["title"] as String,
    type: json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    "company": company.toJson(),
    if (deadlineDate != null) "deadlineDate": deadlineDate!,
    "description": description,
    "education": education,
    "experience": experience,
    "id": id,
    "isHide": isHide,
    if (languagesRequired != null) "languagesRequired": languagesRequired!.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (postedDate != null) "postedDate": postedDate!,
    "salary": salary,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    "skills": skills.map((v) => v).toList(),
    "title": title,
    "type": type,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiSearchJobResult {
  const ApiSearchJobResult({required this.data, required this.isUsingFallback, required this.page, required this.pageSize, required this.total});
  final List<ApiSearchJobResponseDTO> data;
  final bool isUsingFallback;
  final num page;
  final num pageSize;
  final num total;
  factory ApiSearchJobResult.fromJson(Map<String, dynamic> json) => ApiSearchJobResult(
    data: (json["data"] as List).map((v) => ApiSearchJobResponseDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    isUsingFallback: json["isUsingFallback"] as bool,
    page: json["page"] as num,
    pageSize: json["pageSize"] as num,
    total: json["total"] as num,
  );
  Map<String, dynamic> toJson() => {
    "data": data.map((v) => v.toJson()).toList(),
    "isUsingFallback": isUsingFallback,
    "page": page,
    "pageSize": pageSize,
    "total": total,
  };
}

class ApiSearchResumeTemplateResponseDTO {
  const ApiSearchResumeTemplateResponseDTO({required this.createdAt, required this.description, required this.id, required this.image, required this.isPremium, required this.price, required this.templateKey, required this.title});
  final String createdAt;
  final String description;
  final String id;
  final String? image;
  final bool isPremium;
  final num? price;
  final String templateKey;
  final String title;
  factory ApiSearchResumeTemplateResponseDTO.fromJson(Map<String, dynamic> json) => ApiSearchResumeTemplateResponseDTO(
    createdAt: json["createdAt"] as String,
    description: json["description"] as String,
    id: json["id"] as String,
    image: json["image"] == null ? null : json["image"] as String,
    isPremium: json["isPremium"] as bool,
    price: json["price"] == null ? null : json["price"] as num,
    templateKey: json["templateKey"] as String,
    title: json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "description": description,
    "id": id,
    if (image != null) "image": image!,
    "isPremium": isPremium,
    if (price != null) "price": price!,
    "templateKey": templateKey,
    "title": title,
  };
}

class ApiSkillResponseDTO {
  const ApiSkillResponseDTO({this.description, this.id, required this.name});
  final String? description;
  final String? id;
  final String name;
  factory ApiSkillResponseDTO.fromJson(Map<String, dynamic> json) => ApiSkillResponseDTO(
    description: json["description"] == null ? null : json["description"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    name: json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (id != null) "id": id!,
    "name": name,
  };
}

class ApiSocialResponseDTO {
  const ApiSocialResponseDTO({this.id, required this.platform, required this.url});
  final String? id;
  final String platform;
  final String url;
  factory ApiSocialResponseDTO.fromJson(Map<String, dynamic> json) => ApiSocialResponseDTO(
    id: json["id"] == null ? null : json["id"] as String,
    platform: json["platform"] as String,
    url: json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    "platform": platform,
    "url": url,
  };
}

class ApiTimeWindowDeltaDTO {
  const ApiTimeWindowDeltaDTO({required this.current, required this.delta, required this.previous});
  final num current;
  final num delta;
  final num previous;
  factory ApiTimeWindowDeltaDTO.fromJson(Map<String, dynamic> json) => ApiTimeWindowDeltaDTO(
    current: json["current"] as num,
    delta: json["delta"] as num,
    previous: json["previous"] as num,
  );
  Map<String, dynamic> toJson() => {
    "current": current,
    "delta": delta,
    "previous": previous,
  };
}

class ApiTopJobDTO {
  const ApiTopJobDTO({required this.activePipeline, required this.hired, required this.jobId, required this.rejected, required this.title, required this.totalApplicants});
  final num activePipeline;
  final num hired;
  final String jobId;
  final num rejected;
  final String title;
  final num totalApplicants;
  factory ApiTopJobDTO.fromJson(Map<String, dynamic> json) => ApiTopJobDTO(
    activePipeline: json["activePipeline"] as num,
    hired: json["hired"] as num,
    jobId: json["jobId"] as String,
    rejected: json["rejected"] as num,
    title: json["title"] as String,
    totalApplicants: json["totalApplicants"] as num,
  );
  Map<String, dynamic> toJson() => {
    "activePipeline": activePipeline,
    "hired": hired,
    "jobId": jobId,
    "rejected": rejected,
    "title": title,
    "totalApplicants": totalApplicants,
  };
}

class ApiTwoFactorDisableResponseDTO {
  const ApiTwoFactorDisableResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiTwoFactorDisableResponseDTO.fromJson(Map<String, dynamic> json) => ApiTwoFactorDisableResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiTwoFactorEnableResponseDTO {
  const ApiTwoFactorEnableResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiTwoFactorEnableResponseDTO.fromJson(Map<String, dynamic> json) => ApiTwoFactorEnableResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiTwoFactorSetupResponseDTO {
  const ApiTwoFactorSetupResponseDTO({required this.message, required this.qrCodeUrl, required this.secret, this.success});
  final String message;
  final String qrCodeUrl;
  final String secret;
  final bool? success;
  factory ApiTwoFactorSetupResponseDTO.fromJson(Map<String, dynamic> json) => ApiTwoFactorSetupResponseDTO(
    message: json["message"] as String,
    qrCodeUrl: json["qrCodeUrl"] as String,
    secret: json["secret"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    "qrCodeUrl": qrCodeUrl,
    "secret": secret,
    if (success != null) "success": success!,
  };
}

class ApiTwoFactorVerifyLoginDTO {
  const ApiTwoFactorVerifyLoginDTO({required this.otp, required this.twoFactorToken});
  final String otp;
  final String twoFactorToken;
  factory ApiTwoFactorVerifyLoginDTO.fromJson(Map<String, dynamic> json) => ApiTwoFactorVerifyLoginDTO(
    otp: json["otp"] as String,
    twoFactorToken: json["twoFactorToken"] as String,
  );
  Map<String, dynamic> toJson() => {
    "otp": otp,
    "twoFactorToken": twoFactorToken,
  };
}

class ApiTwoFactorVerifyLoginResponseDTO {
  const ApiTwoFactorVerifyLoginResponseDTO({this.accessToken, required this.message, this.refreshToken, this.success, required this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? success;
  final ApiUserResponseDTO user;
  factory ApiTwoFactorVerifyLoginResponseDTO.fromJson(Map<String, dynamic> json) => ApiTwoFactorVerifyLoginResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
    user: ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (success != null) "success": success!,
    "user": user.toJson(),
  };
}

class ApiUnMatchResposneDTO {
  const ApiUnMatchResposneDTO({required this.message, this.notifyUserIds, this.success});
  final String message;
  final List<String>? notifyUserIds;
  final bool? success;
  factory ApiUnMatchResposneDTO.fromJson(Map<String, dynamic> json) => ApiUnMatchResposneDTO(
    message: json["message"] as String,
    notifyUserIds: json["notifyUserIds"] == null ? null : (json["notifyUserIds"] as List).map((v) => v as String).toList(),
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (notifyUserIds != null) "notifyUserIds": notifyUserIds!.map((v) => v).toList(),
    if (success != null) "success": success!,
  };
}

class ApiUnreadCountResponseDTO {
  const ApiUnreadCountResponseDTO({required this.unreadCount});
  final num unreadCount;
  factory ApiUnreadCountResponseDTO.fromJson(Map<String, dynamic> json) => ApiUnreadCountResponseDTO(
    unreadCount: json["unreadCount"] as num,
  );
  Map<String, dynamic> toJson() => {
    "unreadCount": unreadCount,
  };
}

class ApiUnsubscribeBodyDTO {
  const ApiUnsubscribeBodyDTO({required this.token});
  final String token;
  factory ApiUnsubscribeBodyDTO.fromJson(Map<String, dynamic> json) => ApiUnsubscribeBodyDTO(
    token: json["token"] as String,
  );
  Map<String, dynamic> toJson() => {
    "token": token,
  };
}

class ApiUnsubscribeResponseDTO {
  const ApiUnsubscribeResponseDTO({required this.message});
  final String message;
  factory ApiUnsubscribeResponseDTO.fromJson(Map<String, dynamic> json) => ApiUnsubscribeResponseDTO(
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
  };
}

class ApiUpdateApplicationStatusDTO {
  const ApiUpdateApplicationStatusDTO({required this.applicationId, this.rejectionReason, required this.status});
  final String applicationId;
  final String? rejectionReason;
  final String status;
  factory ApiUpdateApplicationStatusDTO.fromJson(Map<String, dynamic> json) => ApiUpdateApplicationStatusDTO(
    applicationId: json["applicationId"] as String,
    rejectionReason: json["rejectionReason"] == null ? null : json["rejectionReason"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "applicationId": applicationId,
    if (rejectionReason != null) "rejectionReason": rejectionReason!,
    "status": status,
  };
}

class ApiUpdateApplicationStatusResponseDTO {
  const ApiUpdateApplicationStatusResponseDTO({required this.appliedAt, this.coverLetterNote, this.employeeId, this.employeeName, required this.id, this.jobId, this.jobTitle, this.matchScore, this.rejectionReason, this.reviewedAt, required this.status, this.statusChangedAt});
  final String appliedAt;
  final String? coverLetterNote;
  final String? employeeId;
  final String? employeeName;
  final String id;
  final String? jobId;
  final String? jobTitle;
  final num? matchScore;
  final String? rejectionReason;
  final String? reviewedAt;
  final String status;
  final String? statusChangedAt;
  factory ApiUpdateApplicationStatusResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdateApplicationStatusResponseDTO(
    appliedAt: json["appliedAt"] as String,
    coverLetterNote: json["coverLetterNote"] == null ? null : json["coverLetterNote"] as String,
    employeeId: json["employeeId"] == null ? null : json["employeeId"] as String,
    employeeName: json["employeeName"] == null ? null : json["employeeName"] as String,
    id: json["id"] as String,
    jobId: json["jobId"] == null ? null : json["jobId"] as String,
    jobTitle: json["jobTitle"] == null ? null : json["jobTitle"] as String,
    matchScore: json["matchScore"] == null ? null : json["matchScore"] as num,
    rejectionReason: json["rejectionReason"] == null ? null : json["rejectionReason"] as String,
    reviewedAt: json["reviewedAt"] == null ? null : json["reviewedAt"] as String,
    status: json["status"] as String,
    statusChangedAt: json["statusChangedAt"] == null ? null : json["statusChangedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    "appliedAt": appliedAt,
    if (coverLetterNote != null) "coverLetterNote": coverLetterNote!,
    if (employeeId != null) "employeeId": employeeId!,
    if (employeeName != null) "employeeName": employeeName!,
    "id": id,
    if (jobId != null) "jobId": jobId!,
    if (jobTitle != null) "jobTitle": jobTitle!,
    if (matchScore != null) "matchScore": matchScore!,
    if (rejectionReason != null) "rejectionReason": rejectionReason!,
    if (reviewedAt != null) "reviewedAt": reviewedAt!,
    "status": status,
    if (statusChangedAt != null) "statusChangedAt": statusChangedAt!,
  };
}

class ApiUpdateCompanyBenefitDTO {
  const ApiUpdateCompanyBenefitDTO({this.id, this.label});
  final num? id;
  final String? label;
  factory ApiUpdateCompanyBenefitDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyBenefitDTO(
    id: json["id"] == null ? null : json["id"] as num,
    label: json["label"] == null ? null : json["label"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    if (label != null) "label": label!,
  };
}

class ApiUpdateCompanyCareerScopeDTO {
  const ApiUpdateCompanyCareerScopeDTO({this.description, this.id, this.name});
  final String? description;
  final String? id;
  final String? name;
  factory ApiUpdateCompanyCareerScopeDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyCareerScopeDTO(
    description: json["description"] == null ? null : json["description"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    name: json["name"] == null ? null : json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (id != null) "id": id!,
    if (name != null) "name": name!,
  };
}

class ApiUpdateCompanyInfoDTO {
  const ApiUpdateCompanyInfoDTO({this.avatar, this.benefitIdsToDelete, this.benefits, this.careerScopeIdsToDelete, this.careerScopes, this.companySize, this.companyType, this.cover, this.description, this.email, this.foundedYear, this.industry, this.jobIdsToDelete, this.jobs, this.location, this.name, this.phone, this.socialIdsToDelete, this.socials, this.valueIdsToDelete, this.values, this.websiteUrl});
  final Map<String, dynamic>? avatar;
  final List<num>? benefitIdsToDelete;
  final List<ApiUpdateCompanyBenefitDTO>? benefits;
  final List<String>? careerScopeIdsToDelete;
  final List<ApiUpdateCompanyCareerScopeDTO>? careerScopes;
  final num? companySize;
  final String? companyType;
  final Map<String, dynamic>? cover;
  final String? description;
  final String? email;
  final num? foundedYear;
  final String? industry;
  final List<String>? jobIdsToDelete;
  final List<ApiUpdateCompanyJobDTO>? jobs;
  final String? location;
  final String? name;
  final String? phone;
  final List<String>? socialIdsToDelete;
  final List<ApiUpdateCompanySocialDTO>? socials;
  final List<num>? valueIdsToDelete;
  final List<ApiUpdateCompanyValueDTO>? values;
  final String? websiteUrl;
  factory ApiUpdateCompanyInfoDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyInfoDTO(
    avatar: json["avatar"] == null ? null : Map<String, dynamic>.from(json["avatar"] as Map),
    benefitIdsToDelete: json["benefitIdsToDelete"] == null ? null : (json["benefitIdsToDelete"] as List).map((v) => v as num).toList(),
    benefits: json["benefits"] == null ? null : (json["benefits"] as List).map((v) => ApiUpdateCompanyBenefitDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    careerScopeIdsToDelete: json["careerScopeIdsToDelete"] == null ? null : (json["careerScopeIdsToDelete"] as List).map((v) => v as String).toList(),
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiUpdateCompanyCareerScopeDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    companySize: json["companySize"] == null ? null : json["companySize"] as num,
    companyType: json["companyType"] == null ? null : json["companyType"] as String,
    cover: json["cover"] == null ? null : Map<String, dynamic>.from(json["cover"] as Map),
    description: json["description"] == null ? null : json["description"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    foundedYear: json["foundedYear"] == null ? null : json["foundedYear"] as num,
    industry: json["industry"] == null ? null : json["industry"] as String,
    jobIdsToDelete: json["jobIdsToDelete"] == null ? null : (json["jobIdsToDelete"] as List).map((v) => v as String).toList(),
    jobs: json["jobs"] == null ? null : (json["jobs"] as List).map((v) => ApiUpdateCompanyJobDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    name: json["name"] == null ? null : json["name"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    socialIdsToDelete: json["socialIdsToDelete"] == null ? null : (json["socialIdsToDelete"] as List).map((v) => v as String).toList(),
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiUpdateCompanySocialDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    valueIdsToDelete: json["valueIdsToDelete"] == null ? null : (json["valueIdsToDelete"] as List).map((v) => v as num).toList(),
    values: json["values"] == null ? null : (json["values"] as List).map((v) => ApiUpdateCompanyValueDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    websiteUrl: json["websiteUrl"] == null ? null : json["websiteUrl"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (avatar != null) "avatar": avatar!,
    if (benefitIdsToDelete != null) "benefitIdsToDelete": benefitIdsToDelete!.map((v) => v).toList(),
    if (benefits != null) "benefits": benefits!.map((v) => v.toJson()).toList(),
    if (careerScopeIdsToDelete != null) "careerScopeIdsToDelete": careerScopeIdsToDelete!.map((v) => v).toList(),
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    if (companySize != null) "companySize": companySize!,
    if (companyType != null) "companyType": companyType!,
    if (cover != null) "cover": cover!,
    if (description != null) "description": description!,
    if (email != null) "email": email!,
    if (foundedYear != null) "foundedYear": foundedYear!,
    if (industry != null) "industry": industry!,
    if (jobIdsToDelete != null) "jobIdsToDelete": jobIdsToDelete!.map((v) => v).toList(),
    if (jobs != null) "jobs": jobs!.map((v) => v.toJson()).toList(),
    if (location != null) "location": location!,
    if (name != null) "name": name!,
    if (phone != null) "phone": phone!,
    if (socialIdsToDelete != null) "socialIdsToDelete": socialIdsToDelete!.map((v) => v).toList(),
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (valueIdsToDelete != null) "valueIdsToDelete": valueIdsToDelete!.map((v) => v).toList(),
    if (values != null) "values": values!.map((v) => v.toJson()).toList(),
    if (websiteUrl != null) "websiteUrl": websiteUrl!,
  };
}

class ApiUpdateCompanyInfoResponseDTO {
  const ApiUpdateCompanyInfoResponseDTO({required this.company, required this.message});
  final ApiCompanyResponseDTO company;
  final String message;
  factory ApiUpdateCompanyInfoResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyInfoResponseDTO(
    company: ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "company": company.toJson(),
    "message": message,
  };
}

class ApiUpdateCompanyJobDTO {
  const ApiUpdateCompanyJobDTO({this.description, this.educationRequired, this.experienceRequired, this.expireDate, this.id, this.languagesRequired, this.location, this.openingsCount, this.salaryCurrency, this.salaryMax, this.salaryMin, this.skillsRequired, this.title, this.type, this.workMode});
  final String? description;
  final String? educationRequired;
  final String? experienceRequired;
  final String? expireDate;
  final String? id;
  final List<String>? languagesRequired;
  final String? location;
  final num? openingsCount;
  final String? salaryCurrency;
  final num? salaryMax;
  final num? salaryMin;
  final String? skillsRequired;
  final String? title;
  final String? type;
  final String? workMode;
  factory ApiUpdateCompanyJobDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyJobDTO(
    description: json["description"] == null ? null : json["description"] as String,
    educationRequired: json["educationRequired"] == null ? null : json["educationRequired"] as String,
    experienceRequired: json["experienceRequired"] == null ? null : json["experienceRequired"] as String,
    expireDate: json["expireDate"] == null ? null : json["expireDate"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    languagesRequired: json["languagesRequired"] == null ? null : (json["languagesRequired"] as List).map((v) => v as String).toList(),
    location: json["location"] == null ? null : json["location"] as String,
    openingsCount: json["openingsCount"] == null ? null : json["openingsCount"] as num,
    salaryCurrency: json["salaryCurrency"] == null ? null : json["salaryCurrency"] as String,
    salaryMax: json["salaryMax"] == null ? null : json["salaryMax"] as num,
    salaryMin: json["salaryMin"] == null ? null : json["salaryMin"] as num,
    skillsRequired: json["skillsRequired"] == null ? null : json["skillsRequired"] as String,
    title: json["title"] == null ? null : json["title"] as String,
    type: json["type"] == null ? null : json["type"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (educationRequired != null) "educationRequired": educationRequired!,
    if (experienceRequired != null) "experienceRequired": experienceRequired!,
    if (expireDate != null) "expireDate": expireDate!,
    if (id != null) "id": id!,
    if (languagesRequired != null) "languagesRequired": languagesRequired!.map((v) => v).toList(),
    if (location != null) "location": location!,
    if (openingsCount != null) "openingsCount": openingsCount!,
    if (salaryCurrency != null) "salaryCurrency": salaryCurrency!,
    if (salaryMax != null) "salaryMax": salaryMax!,
    if (salaryMin != null) "salaryMin": salaryMin!,
    if (skillsRequired != null) "skillsRequired": skillsRequired!,
    if (title != null) "title": title!,
    if (type != null) "type": type!,
    if (workMode != null) "workMode": workMode!,
  };
}

class ApiUpdateCompanySocialDTO {
  const ApiUpdateCompanySocialDTO({this.id, this.platform, this.url});
  final String? id;
  final String? platform;
  final String? url;
  factory ApiUpdateCompanySocialDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanySocialDTO(
    id: json["id"] == null ? null : json["id"] as String,
    platform: json["platform"] == null ? null : json["platform"] as String,
    url: json["url"] == null ? null : json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    if (platform != null) "platform": platform!,
    if (url != null) "url": url!,
  };
}

class ApiUpdateCompanyValueDTO {
  const ApiUpdateCompanyValueDTO({this.id, this.label});
  final num? id;
  final String? label;
  factory ApiUpdateCompanyValueDTO.fromJson(Map<String, dynamic> json) => ApiUpdateCompanyValueDTO(
    id: json["id"] == null ? null : json["id"] as num,
    label: json["label"] == null ? null : json["label"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    if (label != null) "label": label!,
  };
}

class ApiUpdateEmployeeCareerScopeDTO {
  const ApiUpdateEmployeeCareerScopeDTO({this.description, this.id, this.name});
  final String? description;
  final String? id;
  final String? name;
  factory ApiUpdateEmployeeCareerScopeDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeCareerScopeDTO(
    description: json["description"] == null ? null : json["description"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    name: json["name"] == null ? null : json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (id != null) "id": id!,
    if (name != null) "name": name!,
  };
}

class ApiUpdateEmployeeEducationDTO {
  const ApiUpdateEmployeeEducationDTO({required this.degree, this.id, this.school, required this.year});
  final String degree;
  final String? id;
  final String? school;
  final String year;
  factory ApiUpdateEmployeeEducationDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeEducationDTO(
    degree: json["degree"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    school: json["school"] == null ? null : json["school"] as String,
    year: json["year"] as String,
  );
  Map<String, dynamic> toJson() => {
    "degree": degree,
    if (id != null) "id": id!,
    if (school != null) "school": school!,
    "year": year,
  };
}

class ApiUpdateEmployeeExperienceDTO {
  const ApiUpdateEmployeeExperienceDTO({this.company, this.description, this.endDate, this.id, this.startDate, this.title});
  final String? company;
  final String? description;
  final String? endDate;
  final String? id;
  final String? startDate;
  final String? title;
  factory ApiUpdateEmployeeExperienceDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeExperienceDTO(
    company: json["company"] == null ? null : json["company"] as String,
    description: json["description"] == null ? null : json["description"] as String,
    endDate: json["endDate"] == null ? null : json["endDate"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    startDate: json["startDate"] == null ? null : json["startDate"] as String,
    title: json["title"] == null ? null : json["title"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!,
    if (description != null) "description": description!,
    if (endDate != null) "endDate": endDate!,
    if (id != null) "id": id!,
    if (startDate != null) "startDate": startDate!,
    if (title != null) "title": title!,
  };
}

class ApiUpdateEmployeeInfoDTO {
  const ApiUpdateEmployeeInfoDTO({this.availability, this.careerScopeIdsToDelete, this.careerScopes, this.description, this.dob, this.educationIdsToDelete, this.educations, this.email, this.expectedSalaryMax, this.expectedSalaryMin, this.experienceIdsToDelete, this.experiences, this.firstname, this.gender, this.isHide, this.job, this.languages, this.lastname, this.linkedinUrl, this.location, this.noticePeriod, this.phone, this.portfolioUrl, this.skillIdsToDelete, this.skills, this.socialIdsToDelete, this.socials, this.username, this.workMode, this.yearsOfExperience});
  final String? availability;
  final List<String>? careerScopeIdsToDelete;
  final List<ApiUpdateEmployeeCareerScopeDTO>? careerScopes;
  final String? description;
  final String? dob;
  final List<String>? educationIdsToDelete;
  final List<ApiUpdateEmployeeEducationDTO>? educations;
  final String? email;
  final num? expectedSalaryMax;
  final num? expectedSalaryMin;
  final List<String>? experienceIdsToDelete;
  final List<ApiUpdateEmployeeExperienceDTO>? experiences;
  final String? firstname;
  final String? gender;
  final bool? isHide;
  final String? job;
  final List<String>? languages;
  final String? lastname;
  final String? linkedinUrl;
  final String? location;
  final String? noticePeriod;
  final String? phone;
  final String? portfolioUrl;
  final List<String>? skillIdsToDelete;
  final List<ApiUpdateEmployeeSkillDTO>? skills;
  final List<String>? socialIdsToDelete;
  final List<ApiUpdateEmployeeSocialDTO>? socials;
  final String? username;
  final String? workMode;
  final String? yearsOfExperience;
  factory ApiUpdateEmployeeInfoDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeInfoDTO(
    availability: json["availability"] == null ? null : json["availability"] as String,
    careerScopeIdsToDelete: json["careerScopeIdsToDelete"] == null ? null : (json["careerScopeIdsToDelete"] as List).map((v) => v as String).toList(),
    careerScopes: json["careerScopes"] == null ? null : (json["careerScopes"] as List).map((v) => ApiUpdateEmployeeCareerScopeDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    description: json["description"] == null ? null : json["description"] as String,
    dob: json["dob"] == null ? null : json["dob"] as String,
    educationIdsToDelete: json["educationIdsToDelete"] == null ? null : (json["educationIdsToDelete"] as List).map((v) => v as String).toList(),
    educations: json["educations"] == null ? null : (json["educations"] as List).map((v) => ApiUpdateEmployeeEducationDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    email: json["email"] == null ? null : json["email"] as String,
    expectedSalaryMax: json["expectedSalaryMax"] == null ? null : json["expectedSalaryMax"] as num,
    expectedSalaryMin: json["expectedSalaryMin"] == null ? null : json["expectedSalaryMin"] as num,
    experienceIdsToDelete: json["experienceIdsToDelete"] == null ? null : (json["experienceIdsToDelete"] as List).map((v) => v as String).toList(),
    experiences: json["experiences"] == null ? null : (json["experiences"] as List).map((v) => ApiUpdateEmployeeExperienceDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    firstname: json["firstname"] == null ? null : json["firstname"] as String,
    gender: json["gender"] == null ? null : json["gender"] as String,
    isHide: json["isHide"] == null ? null : json["isHide"] as bool,
    job: json["job"] == null ? null : json["job"] as String,
    languages: json["languages"] == null ? null : (json["languages"] as List).map((v) => v as String).toList(),
    lastname: json["lastname"] == null ? null : json["lastname"] as String,
    linkedinUrl: json["linkedinUrl"] == null ? null : json["linkedinUrl"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    noticePeriod: json["noticePeriod"] == null ? null : json["noticePeriod"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    portfolioUrl: json["portfolioUrl"] == null ? null : json["portfolioUrl"] as String,
    skillIdsToDelete: json["skillIdsToDelete"] == null ? null : (json["skillIdsToDelete"] as List).map((v) => v as String).toList(),
    skills: json["skills"] == null ? null : (json["skills"] as List).map((v) => ApiUpdateEmployeeSkillDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    socialIdsToDelete: json["socialIdsToDelete"] == null ? null : (json["socialIdsToDelete"] as List).map((v) => v as String).toList(),
    socials: json["socials"] == null ? null : (json["socials"] as List).map((v) => ApiUpdateEmployeeSocialDTO.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
    username: json["username"] == null ? null : json["username"] as String,
    workMode: json["workMode"] == null ? null : json["workMode"] as String,
    yearsOfExperience: json["yearsOfExperience"] == null ? null : json["yearsOfExperience"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (availability != null) "availability": availability!,
    if (careerScopeIdsToDelete != null) "careerScopeIdsToDelete": careerScopeIdsToDelete!.map((v) => v).toList(),
    if (careerScopes != null) "careerScopes": careerScopes!.map((v) => v.toJson()).toList(),
    if (description != null) "description": description!,
    if (dob != null) "dob": dob!,
    if (educationIdsToDelete != null) "educationIdsToDelete": educationIdsToDelete!.map((v) => v).toList(),
    if (educations != null) "educations": educations!.map((v) => v.toJson()).toList(),
    if (email != null) "email": email!,
    if (expectedSalaryMax != null) "expectedSalaryMax": expectedSalaryMax!,
    if (expectedSalaryMin != null) "expectedSalaryMin": expectedSalaryMin!,
    if (experienceIdsToDelete != null) "experienceIdsToDelete": experienceIdsToDelete!.map((v) => v).toList(),
    if (experiences != null) "experiences": experiences!.map((v) => v.toJson()).toList(),
    if (firstname != null) "firstname": firstname!,
    if (gender != null) "gender": gender!,
    if (isHide != null) "isHide": isHide!,
    if (job != null) "job": job!,
    if (languages != null) "languages": languages!.map((v) => v).toList(),
    if (lastname != null) "lastname": lastname!,
    if (linkedinUrl != null) "linkedinUrl": linkedinUrl!,
    if (location != null) "location": location!,
    if (noticePeriod != null) "noticePeriod": noticePeriod!,
    if (phone != null) "phone": phone!,
    if (portfolioUrl != null) "portfolioUrl": portfolioUrl!,
    if (skillIdsToDelete != null) "skillIdsToDelete": skillIdsToDelete!.map((v) => v).toList(),
    if (skills != null) "skills": skills!.map((v) => v.toJson()).toList(),
    if (socialIdsToDelete != null) "socialIdsToDelete": socialIdsToDelete!.map((v) => v).toList(),
    if (socials != null) "socials": socials!.map((v) => v.toJson()).toList(),
    if (username != null) "username": username!,
    if (workMode != null) "workMode": workMode!,
    if (yearsOfExperience != null) "yearsOfExperience": yearsOfExperience!,
  };
}

class ApiUpdateEmployeeInfoResponseDTO {
  const ApiUpdateEmployeeInfoResponseDTO({required this.employee, required this.message});
  final ApiEmployeeResponseDTO employee;
  final String message;
  factory ApiUpdateEmployeeInfoResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeInfoResponseDTO(
    employee: ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    message: json["message"] as String,
  );
  Map<String, dynamic> toJson() => {
    "employee": employee.toJson(),
    "message": message,
  };
}

class ApiUpdateEmployeeSkillDTO {
  const ApiUpdateEmployeeSkillDTO({this.description, this.id, this.name});
  final String? description;
  final String? id;
  final String? name;
  factory ApiUpdateEmployeeSkillDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeSkillDTO(
    description: json["description"] == null ? null : json["description"] as String,
    id: json["id"] == null ? null : json["id"] as String,
    name: json["name"] == null ? null : json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (description != null) "description": description!,
    if (id != null) "id": id!,
    if (name != null) "name": name!,
  };
}

class ApiUpdateEmployeeSocialDTO {
  const ApiUpdateEmployeeSocialDTO({this.id, this.platform, this.url});
  final String? id;
  final String? platform;
  final String? url;
  factory ApiUpdateEmployeeSocialDTO.fromJson(Map<String, dynamic> json) => ApiUpdateEmployeeSocialDTO(
    id: json["id"] == null ? null : json["id"] as String,
    platform: json["platform"] == null ? null : json["platform"] as String,
    url: json["url"] == null ? null : json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    if (platform != null) "platform": platform!,
    if (url != null) "url": url!,
  };
}

class ApiUpdateInterviewStatusDTO {
  const ApiUpdateInterviewStatusDTO({required this.interviewId, this.requestUserId, this.requestUserRole, required this.status});
  final String interviewId;
  final String? requestUserId;
  final String? requestUserRole;
  final String status;
  factory ApiUpdateInterviewStatusDTO.fromJson(Map<String, dynamic> json) => ApiUpdateInterviewStatusDTO(
    interviewId: json["interviewId"] as String,
    requestUserId: json["requestUserId"] == null ? null : json["requestUserId"] as String,
    requestUserRole: json["requestUserRole"] == null ? null : json["requestUserRole"] as String,
    status: json["status"] as String,
  );
  Map<String, dynamic> toJson() => {
    "interviewId": interviewId,
    if (requestUserId != null) "requestUserId": requestUserId!,
    if (requestUserRole != null) "requestUserRole": requestUserRole!,
    "status": status,
  };
}

class ApiUpdateInterviewStatusResponseDTO {
  const ApiUpdateInterviewStatusResponseDTO({this.applicationId, required this.company, required this.createdAt, required this.createdBy, required this.description, required this.durationMinutes, required this.employee, required this.id, required this.location, required this.meetingLink, this.notifyUserId, required this.scheduledAt, required this.status, required this.timezone, required this.title, required this.updatedAt});
  final String? applicationId;
  final ApiCompanyResponseDTO company;
  final String createdAt;
  final String? createdBy;
  final String? description;
  final num durationMinutes;
  final ApiEmployeeResponseDTO employee;
  final String id;
  final String? location;
  final String? meetingLink;
  final String? notifyUserId;
  final String scheduledAt;
  final String status;
  final String? timezone;
  final String title;
  final String updatedAt;
  factory ApiUpdateInterviewStatusResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdateInterviewStatusResponseDTO(
    applicationId: json["applicationId"] == null ? null : json["applicationId"] as String,
    company: ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] as String,
    createdBy: json["createdBy"] == null ? null : json["createdBy"] as String,
    description: json["description"] == null ? null : json["description"] as String,
    durationMinutes: json["durationMinutes"] as num,
    employee: ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    location: json["location"] == null ? null : json["location"] as String,
    meetingLink: json["meetingLink"] == null ? null : json["meetingLink"] as String,
    notifyUserId: json["notifyUserId"] == null ? null : json["notifyUserId"] as String,
    scheduledAt: json["scheduledAt"] as String,
    status: json["status"] as String,
    timezone: json["timezone"] == null ? null : json["timezone"] as String,
    title: json["title"] as String,
    updatedAt: json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (applicationId != null) "applicationId": applicationId!,
    "company": company.toJson(),
    "createdAt": createdAt,
    if (createdBy != null) "createdBy": createdBy!,
    if (description != null) "description": description!,
    "durationMinutes": durationMinutes,
    "employee": employee.toJson(),
    "id": id,
    if (location != null) "location": location!,
    if (meetingLink != null) "meetingLink": meetingLink!,
    if (notifyUserId != null) "notifyUserId": notifyUserId!,
    "scheduledAt": scheduledAt,
    "status": status,
    if (timezone != null) "timezone": timezone!,
    "title": title,
    "updatedAt": updatedAt,
  };
}

class ApiUpdateNotificationPreferenceBodyDTO {
  const ApiUpdateNotificationPreferenceBodyDTO({this.categories, this.emailEnabled, this.pushEnabled});
  final Map<String, dynamic>? categories;
  final bool? emailEnabled;
  final bool? pushEnabled;
  factory ApiUpdateNotificationPreferenceBodyDTO.fromJson(Map<String, dynamic> json) => ApiUpdateNotificationPreferenceBodyDTO(
    categories: json["categories"] == null ? null : Map<String, dynamic>.from(json["categories"] as Map),
    emailEnabled: json["emailEnabled"] == null ? null : json["emailEnabled"] as bool,
    pushEnabled: json["pushEnabled"] == null ? null : json["pushEnabled"] as bool,
  );
  Map<String, dynamic> toJson() => {
    if (categories != null) "categories": categories!,
    if (emailEnabled != null) "emailEnabled": emailEnabled!,
    if (pushEnabled != null) "pushEnabled": pushEnabled!,
  };
}

class ApiUpdatePrivacyDTO {
  const ApiUpdatePrivacyDTO({required this.browsePrivately});
  final bool browsePrivately;
  factory ApiUpdatePrivacyDTO.fromJson(Map<String, dynamic> json) => ApiUpdatePrivacyDTO(
    browsePrivately: json["browsePrivately"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "browsePrivately": browsePrivately,
  };
}

class ApiUpdatePrivacyResponseDTO {
  const ApiUpdatePrivacyResponseDTO({required this.browsePrivately});
  final bool browsePrivately;
  factory ApiUpdatePrivacyResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdatePrivacyResponseDTO(
    browsePrivately: json["browsePrivately"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "browsePrivately": browsePrivately,
  };
}

class ApiUpdatePushNotificationTokenBodyDTO {
  const ApiUpdatePushNotificationTokenBodyDTO({this.token});
  final String? token;
  factory ApiUpdatePushNotificationTokenBodyDTO.fromJson(Map<String, dynamic> json) => ApiUpdatePushNotificationTokenBodyDTO(
    token: json["token"] == null ? null : json["token"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (token != null) "token": token!,
  };
}

class ApiUpdatePushNotificationTokenResponseDTO {
  const ApiUpdatePushNotificationTokenResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUpdatePushNotificationTokenResponseDTO.fromJson(Map<String, dynamic> json) => ApiUpdatePushNotificationTokenResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUpdateResumeDraftDTO {
  const ApiUpdateResumeDraftDTO({required this.content, required this.name, required this.revision});
  final Map<String, dynamic> content;
  final String name;
  final num revision;
  factory ApiUpdateResumeDraftDTO.fromJson(Map<String, dynamic> json) => ApiUpdateResumeDraftDTO(
    content: Map<String, dynamic>.from(json["content"] as Map),
    name: json["name"] as String,
    revision: json["revision"] as num,
  );
  Map<String, dynamic> toJson() => {
    "content": content,
    "name": name,
    "revision": revision,
  };
}

class ApiUpdateSavedSearchDTO {
  const ApiUpdateSavedSearchDTO({this.filters, this.frequency, this.name});
  final dynamic filters;
  final String? frequency;
  final String? name;
  factory ApiUpdateSavedSearchDTO.fromJson(Map<String, dynamic> json) => ApiUpdateSavedSearchDTO(
    filters: json["filters"],
    frequency: json["frequency"] == null ? null : json["frequency"] as String,
    name: json["name"] == null ? null : json["name"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (filters != null) "filters": filters!,
    if (frequency != null) "frequency": frequency!,
    if (name != null) "name": name!,
  };
}

class ApiUploadAttachmentResponseDTO {
  const ApiUploadAttachmentResponseDTO({required this.filename, required this.size, required this.type, required this.url});
  final String filename;
  final num size;
  final String type;
  final String url;
  factory ApiUploadAttachmentResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadAttachmentResponseDTO(
    filename: json["filename"] as String,
    size: json["size"] as num,
    type: json["type"] as String,
    url: json["url"] as String,
  );
  Map<String, dynamic> toJson() => {
    "filename": filename,
    "size": size,
    "type": type,
    "url": url,
  };
}

class ApiUploadCompanyAvatarResponseDTO {
  const ApiUploadCompanyAvatarResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadCompanyAvatarResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadCompanyAvatarResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUploadCompanyCoverResponseDTO {
  const ApiUploadCompanyCoverResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadCompanyCoverResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadCompanyCoverResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUploadCompanyImagesResponseDTO {
  const ApiUploadCompanyImagesResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadCompanyImagesResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadCompanyImagesResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUploadEmployeeAvatarResponseDTO {
  const ApiUploadEmployeeAvatarResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadEmployeeAvatarResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadEmployeeAvatarResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUploadEmployeeCoverLetterResponseDTO {
  const ApiUploadEmployeeCoverLetterResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadEmployeeCoverLetterResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadEmployeeCoverLetterResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUploadEmployeeResumeResponseDTO {
  const ApiUploadEmployeeResumeResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiUploadEmployeeResumeResponseDTO.fromJson(Map<String, dynamic> json) => ApiUploadEmployeeResumeResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiUserInJobResponseDTO {
  const ApiUserInJobResponseDTO({required this.id});
  final String id;
  factory ApiUserInJobResponseDTO.fromJson(Map<String, dynamic> json) => ApiUserInJobResponseDTO(
    id: json["id"] as String,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class ApiUserResponseDTO {
  const ApiUserResponseDTO({this.company, this.createdAt, this.deletedAt, this.email, this.employee, required this.id, this.isEmailVerified, this.isTwoFactorEnabled, this.lastLoginAt, this.lastLoginMethod, this.phone, this.profileCompleted, required this.role, this.updatedAt});
  final ApiCompanyResponseDTO? company;
  final String? createdAt;
  final String? deletedAt;
  final String? email;
  final ApiEmployeeResponseDTO? employee;
  final String id;
  final bool? isEmailVerified;
  final bool? isTwoFactorEnabled;
  final String? lastLoginAt;
  final String? lastLoginMethod;
  final String? phone;
  final bool? profileCompleted;
  final String role;
  final String? updatedAt;
  factory ApiUserResponseDTO.fromJson(Map<String, dynamic> json) => ApiUserResponseDTO(
    company: json["company"] == null ? null : ApiCompanyResponseDTO.fromJson(Map<String, dynamic>.from(json["company"] as Map)),
    createdAt: json["createdAt"] == null ? null : json["createdAt"] as String,
    deletedAt: json["deletedAt"] == null ? null : json["deletedAt"] as String,
    email: json["email"] == null ? null : json["email"] as String,
    employee: json["employee"] == null ? null : ApiEmployeeResponseDTO.fromJson(Map<String, dynamic>.from(json["employee"] as Map)),
    id: json["id"] as String,
    isEmailVerified: json["isEmailVerified"] == null ? null : json["isEmailVerified"] as bool,
    isTwoFactorEnabled: json["isTwoFactorEnabled"] == null ? null : json["isTwoFactorEnabled"] as bool,
    lastLoginAt: json["lastLoginAt"] == null ? null : json["lastLoginAt"] as String,
    lastLoginMethod: json["lastLoginMethod"] == null ? null : json["lastLoginMethod"] as String,
    phone: json["phone"] == null ? null : json["phone"] as String,
    profileCompleted: json["profileCompleted"] == null ? null : json["profileCompleted"] as bool,
    role: json["role"] as String,
    updatedAt: json["updatedAt"] == null ? null : json["updatedAt"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (company != null) "company": company!.toJson(),
    if (createdAt != null) "createdAt": createdAt!,
    if (deletedAt != null) "deletedAt": deletedAt!,
    if (email != null) "email": email!,
    if (employee != null) "employee": employee!.toJson(),
    "id": id,
    if (isEmailVerified != null) "isEmailVerified": isEmailVerified!,
    if (isTwoFactorEnabled != null) "isTwoFactorEnabled": isTwoFactorEnabled!,
    if (lastLoginAt != null) "lastLoginAt": lastLoginAt!,
    if (lastLoginMethod != null) "lastLoginMethod": lastLoginMethod!,
    if (phone != null) "phone": phone!,
    if (profileCompleted != null) "profileCompleted": profileCompleted!,
    "role": role,
    if (updatedAt != null) "updatedAt": updatedAt!,
  };
}

class ApiValuesAndBenefitsResponseDTO {
  const ApiValuesAndBenefitsResponseDTO({this.id, required this.label});
  final num? id;
  final String label;
  factory ApiValuesAndBenefitsResponseDTO.fromJson(Map<String, dynamic> json) => ApiValuesAndBenefitsResponseDTO(
    id: json["id"] == null ? null : json["id"] as num,
    label: json["label"] as String,
  );
  Map<String, dynamic> toJson() => {
    if (id != null) "id": id!,
    "label": label,
  };
}

class ApiVerifyEmailDTO {
  const ApiVerifyEmailDTO({required this.email, required this.otp});
  final String email;
  final String otp;
  factory ApiVerifyEmailDTO.fromJson(Map<String, dynamic> json) => ApiVerifyEmailDTO(
    email: json["email"] as String,
    otp: json["otp"] as String,
  );
  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}

class ApiVerifyEmailResponseDTO {
  const ApiVerifyEmailResponseDTO({required this.message, this.success});
  final String message;
  final bool? success;
  factory ApiVerifyEmailResponseDTO.fromJson(Map<String, dynamic> json) => ApiVerifyEmailResponseDTO(
    message: json["message"] as String,
    success: json["success"] == null ? null : json["success"] as bool,
  );
  Map<String, dynamic> toJson() => {
    "message": message,
    if (success != null) "success": success!,
  };
}

class ApiVerifyOtpDTO {
  const ApiVerifyOtpDTO({required this.otp, required this.phone});
  final String otp;
  final String phone;
  factory ApiVerifyOtpDTO.fromJson(Map<String, dynamic> json) => ApiVerifyOtpDTO(
    otp: json["otp"] as String,
    phone: json["phone"] as String,
  );
  Map<String, dynamic> toJson() => {
    "otp": otp,
    "phone": phone,
  };
}

class ApiVerifyOtpResponseDTO {
  const ApiVerifyOtpResponseDTO({this.accessToken, required this.message, this.refreshToken, this.requiresTwoFactor, this.success, this.twoFactorToken, this.user});
  final String? accessToken;
  final String message;
  final String? refreshToken;
  final bool? requiresTwoFactor;
  final bool? success;
  final String? twoFactorToken;
  final ApiUserResponseDTO? user;
  factory ApiVerifyOtpResponseDTO.fromJson(Map<String, dynamic> json) => ApiVerifyOtpResponseDTO(
    accessToken: json["accessToken"] == null ? null : json["accessToken"] as String,
    message: json["message"] as String,
    refreshToken: json["refreshToken"] == null ? null : json["refreshToken"] as String,
    requiresTwoFactor: json["requiresTwoFactor"] == null ? null : json["requiresTwoFactor"] as bool,
    success: json["success"] == null ? null : json["success"] as bool,
    twoFactorToken: json["twoFactorToken"] == null ? null : json["twoFactorToken"] as String,
    user: json["user"] == null ? null : ApiUserResponseDTO.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
  );
  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken!,
    "message": message,
    if (refreshToken != null) "refreshToken": refreshToken!,
    if (requiresTwoFactor != null) "requiresTwoFactor": requiresTwoFactor!,
    if (success != null) "success": success!,
    if (twoFactorToken != null) "twoFactorToken": twoFactorToken!,
    if (user != null) "user": user!.toJson(),
  };
}

class ApiWeeklyActivityItemDTO {
  const ApiWeeklyActivityItemDTO({required this.day, required this.likes, required this.matches, required this.received});
  final String day;
  final num likes;
  final num matches;
  final num received;
  factory ApiWeeklyActivityItemDTO.fromJson(Map<String, dynamic> json) => ApiWeeklyActivityItemDTO(
    day: json["day"] as String,
    likes: json["likes"] as num,
    matches: json["matches"] as num,
    received: json["received"] as num,
  );
  Map<String, dynamic> toJson() => {
    "day": day,
    "likes": likes,
    "matches": matches,
    "received": received,
  };
}

class GatewayApi {
  GatewayApi(this.client);
  final ApiClient client;
  Future<Response<dynamic>> adminReportControllerListAudit({Map<String, dynamic>? query, Options? options}) => client.get("/admin/audit", queryParameters: query, options: options);
  Future<Response<dynamic>> adminJobControllerListJobs({Map<String, dynamic>? query, Options? options}) => client.get("/admin/jobs", queryParameters: query, options: options);
  Future<Response<dynamic>> adminJobControllerHideJob({required String jobId, Map<String, dynamic>? query, Options? options, required ApiAdminHideJobBodyDTO body}) => client.delete("/admin/jobs/${Uri.encodeComponent(jobId)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> adminJobControllerRestoreJob({required String jobId, Map<String, dynamic>? query, Options? options}) => client.post("/admin/jobs/${Uri.encodeComponent(jobId)}/restore", options: options);
  Future<Response<dynamic>> adminProblemReportControllerListReports({Map<String, dynamic>? query, Options? options}) => client.get("/admin/problem-reports", queryParameters: query, options: options);
  Future<Response<dynamic>> adminProblemReportControllerUpdateStatus({required String reportId, Map<String, dynamic>? query, Options? options, required ApiAdminUpdateProblemReportStatusBodyDTO body}) => client.patch("/admin/problem-reports/${Uri.encodeComponent(reportId)}/status", data: body.toJson(), options: options);
  Future<Response<dynamic>> adminReportControllerListReports({Map<String, dynamic>? query, Options? options}) => client.get("/admin/reports", queryParameters: query, options: options);
  Future<Response<dynamic>> adminReportControllerUpdateReportStatus({required String reportId, Map<String, dynamic>? query, Options? options, required ApiAdminUpdateReportStatusBodyDTO body}) => client.patch("/admin/reports/${Uri.encodeComponent(reportId)}/status", data: body.toJson(), options: options);
  Future<Response<dynamic>> adminUserControllerListUsers({Map<String, dynamic>? query, Options? options}) => client.get("/admin/users", queryParameters: query, options: options);
  Future<Response<dynamic>> adminUserControllerGetOverview({Map<String, dynamic>? query, Options? options}) => client.get("/admin/users/overview", queryParameters: query, options: options);
  Future<Response<dynamic>> adminUserControllerGetUser({required String userId, Map<String, dynamic>? query, Options? options}) => client.get("/admin/users/${Uri.encodeComponent(userId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> adminUserControllerUpdateUserStatus({required String userId, Map<String, dynamic>? query, Options? options, required ApiAdminUpdateUserStatusBodyDTO body}) => client.patch("/admin/users/${Uri.encodeComponent(userId)}/status", data: body.toJson(), options: options);
  Future<Response<dynamic>> aiQuotaControllerGetQuota({Map<String, dynamic>? query, Options? options}) => client.get("/ai/quota", queryParameters: query, options: options);
  Future<Response<dynamic>> authControllerTwoFactorDisable({Map<String, dynamic>? query, Options? options}) => client.post("/auth/2fa/disable", options: options);
  Future<Response<dynamic>> authControllerTwoFactorEnable({Map<String, dynamic>? query, Options? options}) => client.post("/auth/2fa/enable", options: options);
  Future<Response<dynamic>> authControllerTwoFactorSetup({Map<String, dynamic>? query, Options? options}) => client.post("/auth/2fa/setup", options: options);
  Future<Response<dynamic>> authControllerTwoFactorVerifyLogin({Map<String, dynamic>? query, Options? options, required ApiTwoFactorVerifyLoginDTO body}) => client.post("/auth/2fa/verify-login", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerForgotPassword({Map<String, dynamic>? query, Options? options, required ApiForgotPasswordDTO body}) => client.post("/auth/forgot-password", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerGetIceServers({Map<String, dynamic>? query, Options? options}) => client.get("/auth/ice-servers", queryParameters: query, options: options);
  Future<Response<dynamic>> authControllerLogin({Map<String, dynamic>? query, Options? options, required ApiLoginDTO body}) => client.post("/auth/login", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerLoginOtp({Map<String, dynamic>? query, Options? options, required ApiLoginOtpDTO body}) => client.post("/auth/login-otp", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerLogout({Map<String, dynamic>? query, Options? options}) => client.post("/auth/logout", options: options);
  Future<Response<dynamic>> authControllerParseResume({Map<String, dynamic>? query, Options? options}) => client.post("/auth/parse-resume", options: options);
  Future<Response<dynamic>> authControllerRefreshToken({Map<String, dynamic>? query, Options? options, required ApiRefreshTokenRequestDTO body}) => client.post("/auth/refresh", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerRegisterCompany({Map<String, dynamic>? query, Options? options, required ApiCompanyRegisterDTO body}) => client.post("/auth/register-company", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerRegisterEmployee({Map<String, dynamic>? query, Options? options, required ApiEmployeeRegisterDTO body}) => client.post("/auth/register-employee", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerResetPassword({required String token, Map<String, dynamic>? query, Options? options, required ApiResetPasswordDTO body}) => client.post("/auth/reset-password/${Uri.encodeComponent(token)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerVerifyEmail({Map<String, dynamic>? query, Options? options, required ApiVerifyEmailDTO body}) => client.post("/auth/verify-email", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerResendEmailOtp({Map<String, dynamic>? query, Options? options, required ApiResendEmailOtpDTO body}) => client.post("/auth/verify-email/resend", data: body.toJson(), options: options);
  Future<Response<dynamic>> authControllerVerifyOtp({Map<String, dynamic>? query, Options? options, required ApiVerifyOtpDTO body}) => client.post("/auth/verify-otp", data: body.toJson(), options: options);
  Future<Response<dynamic>> chatControllerGetAttachment({required String date, required String filename, Map<String, dynamic>? query, Options? options}) => client.get("/chat/attachment/${Uri.encodeComponent(date)}/${Uri.encodeComponent(filename)}", queryParameters: query, options: options);
  Future<Response<dynamic>> chatControllerInitiateChat({Map<String, dynamic>? query, Options? options, required ApiInitiateChatDTO body}) => client.post("/chat/initiate", data: body.toJson(), options: options);
  Future<Response<dynamic>> chatControllerGetRecentChats({Map<String, dynamic>? query, Options? options}) => client.get("/chat/recent", queryParameters: query, options: options);
  Future<Response<dynamic>> chatControllerUploadAttachment({Map<String, dynamic>? query, Options? options}) => client.post("/chat/upload", options: options);
  Future<Response<dynamic>> healthControllerCheckHealth({Map<String, dynamic>? query, Options? options}) => client.get("/health", queryParameters: query, options: options);
  Future<Response<dynamic>> healthControllerCheckLiveness({Map<String, dynamic>? query, Options? options}) => client.get("/health/live", queryParameters: query, options: options);
  Future<Response<dynamic>> healthControllerCheckReadiness({Map<String, dynamic>? query, Options? options}) => client.get("/health/ready", queryParameters: query, options: options);
  Future<Response<dynamic>> jobControllerFindAllJobs({Map<String, dynamic>? query, Options? options}) => client.get("/job/all", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerApplyApplication({Map<String, dynamic>? query, Options? options, required ApiApplyApplicationDTO body}) => client.post("/job/application", data: body.toJson(), options: options);
  Future<Response<dynamic>> applicationControllerBulkUpdateApplicationStatus({Map<String, dynamic>? query, Options? options, required ApiBulkUpdateApplicationStatusDTO body}) => client.patch("/job/application/bulk-status", data: body.toJson(), options: options);
  Future<Response<dynamic>> applicationControllerGetJobApplications({required String jobId, required String companyId, Map<String, dynamic>? query, Options? options}) => client.get("/job/application/job/${Uri.encodeComponent(jobId)}/company/${Uri.encodeComponent(companyId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerGetMyApplications({Map<String, dynamic>? query, Options? options}) => client.get("/job/application/mine", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerGetJobPipeline({required String jobId, required String companyId, Map<String, dynamic>? query, Options? options}) => client.get("/job/application/pipeline/job/${Uri.encodeComponent(jobId)}/company/${Uri.encodeComponent(companyId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerUpdateApplicationStatus({Map<String, dynamic>? query, Options? options, required ApiUpdateApplicationStatusDTO body}) => client.patch("/job/application/status", data: body.toJson(), options: options);
  Future<Response<dynamic>> applicationControllerWithdrawApplication({required String applicationId, Map<String, dynamic>? query, Options? options}) => client.delete("/job/application/${Uri.encodeComponent(applicationId)}", options: options);
  Future<Response<dynamic>> applicationControllerListApplicationStatusHistory({required String applicationId, Map<String, dynamic>? query, Options? options}) => client.get("/job/application/${Uri.encodeComponent(applicationId)}/history", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerListApplicationNotes({required String applicationId, Map<String, dynamic>? query, Options? options}) => client.get("/job/application/${Uri.encodeComponent(applicationId)}/notes", queryParameters: query, options: options);
  Future<Response<dynamic>> applicationControllerCreateApplicationNote({required String applicationId, Map<String, dynamic>? query, Options? options, required ApiCreateApplicationNoteDTO body}) => client.post("/job/application/${Uri.encodeComponent(applicationId)}/notes", data: body.toJson(), options: options);
  Future<Response<dynamic>> applicationControllerDeleteApplicationNote({required String applicationId, required String noteId, Map<String, dynamic>? query, Options? options}) => client.delete("/job/application/${Uri.encodeComponent(applicationId)}/notes/${Uri.encodeComponent(noteId)}", options: options);
  Future<Response<dynamic>> employerAnalyticsControllerGetEmployerAnalytics({Map<String, dynamic>? query, Options? options}) => client.get("/job/employer-analytics", queryParameters: query, options: options);
  Future<Response<dynamic>> savedSearchControllerListSavedSearches({Map<String, dynamic>? query, Options? options}) => client.get("/job/saved-search", queryParameters: query, options: options);
  Future<Response<dynamic>> savedSearchControllerCreateSavedSearch({Map<String, dynamic>? query, Options? options, required ApiCreateSavedSearchDTO body}) => client.post("/job/saved-search", data: body.toJson(), options: options);
  Future<Response<dynamic>> savedSearchControllerUpdateSavedSearch({required String savedSearchId, Map<String, dynamic>? query, Options? options, required ApiUpdateSavedSearchDTO body}) => client.patch("/job/saved-search/${Uri.encodeComponent(savedSearchId)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> savedSearchControllerDeleteSavedSearch({required String savedSearchId, Map<String, dynamic>? query, Options? options}) => client.delete("/job/saved-search/${Uri.encodeComponent(savedSearchId)}", options: options);
  Future<Response<dynamic>> savedSearchControllerPreviewSavedSearch({required String savedSearchId, Map<String, dynamic>? query, Options? options}) => client.get("/job/saved-search/${Uri.encodeComponent(savedSearchId)}/preview", queryParameters: query, options: options);
  Future<Response<dynamic>> jobControllerSearchJobs({Map<String, dynamic>? query, Options? options}) => client.get("/job/search", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerGetAiMatchExplanation({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/ai-explanation/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerStreamAiMatchExplanation({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/ai-explanation/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}/stream", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerGetAiInterviewPrep({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/ai-interview-prep/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerStreamAiInterviewPrep({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/ai-interview-prep/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}/stream", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerStreamAiSkillGap({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/ai-skill-gap/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}/stream", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerGetMatchingAnalytics({required String id, Map<String, dynamic>? query, Options? options}) => client.get("/match/analytics/${Uri.encodeComponent(id)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerCompanyLikes({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.post("/match/company/${Uri.encodeComponent(cid)}/like/${Uri.encodeComponent(eid)}", options: options);
  Future<Response<dynamic>> jobMatchingControllerMarkCompanyMatchingSeen({required String cid, Map<String, dynamic>? query, Options? options}) => client.post("/match/company/${Uri.encodeComponent(cid)}/matching-seen", options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentCompanyLiked({required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-company-liked/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentCompanyMatchingCount({required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-company-matching-count/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentCompanyMatching({required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-company-matching/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentEmployeeLiked({required String eid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-employee-liked/${Uri.encodeComponent(eid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentEmployeeMatchingCount({required String eid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-employee-matching-count/${Uri.encodeComponent(eid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerFindCurrentEmployeeMatching({required String eid, Map<String, dynamic>? query, Options? options}) => client.get("/match/current-employee-matching/${Uri.encodeComponent(eid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> jobMatchingControllerEmployeeLikes({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.post("/match/employee/${Uri.encodeComponent(eid)}/like/${Uri.encodeComponent(cid)}", options: options);
  Future<Response<dynamic>> jobMatchingControllerMarkEmployeeMatchingSeen({required String eid, Map<String, dynamic>? query, Options? options}) => client.post("/match/employee/${Uri.encodeComponent(eid)}/matching-seen", options: options);
  Future<Response<dynamic>> interviewControllerCreateInterview({Map<String, dynamic>? query, Options? options, required ApiCreateInterviewDTO body}) => client.post("/match/interview", data: body.toJson(), options: options);
  Future<Response<dynamic>> interviewControllerGetInterviewsByCompany({required String companyId, Map<String, dynamic>? query, Options? options}) => client.get("/match/interview/company/${Uri.encodeComponent(companyId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> interviewControllerGetInterviewsByEmployee({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.get("/match/interview/employee/${Uri.encodeComponent(employeeId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> interviewControllerUpdateInterviewStatus({Map<String, dynamic>? query, Options? options, required ApiUpdateInterviewStatusDTO body}) => client.patch("/match/interview/status", data: body.toJson(), options: options);
  Future<Response<dynamic>> jobMatchingControllerUnmatch({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.delete("/match/unmatch/${Uri.encodeComponent(eid)}/${Uri.encodeComponent(cid)}", options: options);
  Future<Response<dynamic>> metricsControllerMetrics({Map<String, dynamic>? query, Options? options}) => client.get("/metrics", queryParameters: query, options: options);
  Future<Response<dynamic>> notificationControllerListByUser({Map<String, dynamic>? query, Options? options}) => client.get("/notification", queryParameters: query, options: options);
  Future<Response<dynamic>> notificationControllerCreateForCurrentUser({Map<String, dynamic>? query, Options? options, required ApiCreateNotificationCurrentUserDTO body}) => client.post("/notification", data: body.toJson(), options: options);
  Future<Response<dynamic>> notificationControllerDeleteAllNotifications({Map<String, dynamic>? query, Options? options}) => client.delete("/notification", options: options);
  Future<Response<dynamic>> notificationControllerRegisterDeviceToken({Map<String, dynamic>? query, Options? options, required ApiDeviceTokenBodyDTO body}) => client.put("/notification/device-token", data: body.toJson(), options: options);
  Future<Response<dynamic>> notificationControllerRemoveDeviceToken({Map<String, dynamic>? query, Options? options, required ApiDeviceTokenBodyDTO body}) => client.delete("/notification/device-token", data: body.toJson(), options: options);
  Future<Response<dynamic>> notificationPreferenceControllerGetPreferences({Map<String, dynamic>? query, Options? options}) => client.get("/notification/preferences", queryParameters: query, options: options);
  Future<Response<dynamic>> notificationPreferenceControllerUpdatePreferences({Map<String, dynamic>? query, Options? options, required ApiUpdateNotificationPreferenceBodyDTO body}) => client.patch("/notification/preferences", data: body.toJson(), options: options);
  Future<Response<dynamic>> notificationPreferenceControllerUnsubscribe({Map<String, dynamic>? query, Options? options, required ApiUnsubscribeBodyDTO body}) => client.post("/notification/preferences/unsubscribe", data: body.toJson(), options: options);
  Future<Response<dynamic>> notificationControllerMarkAllRead({Map<String, dynamic>? query, Options? options}) => client.patch("/notification/read-all", options: options);
  Future<Response<dynamic>> notificationControllerGetUnreadCount({Map<String, dynamic>? query, Options? options}) => client.get("/notification/unread-count", queryParameters: query, options: options);
  Future<Response<dynamic>> notificationControllerDeleteNotification({required String id, Map<String, dynamic>? query, Options? options}) => client.delete("/notification/${Uri.encodeComponent(id)}", options: options);
  Future<Response<dynamic>> notificationControllerMarkRead({required String id, Map<String, dynamic>? query, Options? options}) => client.patch("/notification/${Uri.encodeComponent(id)}/read", options: options);
  Future<Response<dynamic>> publicJobControllerFindPublicJobSitemap({Map<String, dynamic>? query, Options? options}) => client.get("/public/job/sitemap/entries", queryParameters: query, options: options);
  Future<Response<dynamic>> publicJobControllerFindOneJob({required String jobId, Map<String, dynamic>? query, Options? options}) => client.get("/public/job/${Uri.encodeComponent(jobId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> publicUserControllerGetCareerScopes({Map<String, dynamic>? query, Options? options}) => client.get("/public/user/career-scopes", queryParameters: query, options: options);
  Future<Response<dynamic>> publicUserControllerGetLandingStats({Map<String, dynamic>? query, Options? options}) => client.get("/public/user/landing-stats", queryParameters: query, options: options);
  Future<Response<dynamic>> resumeBuilderControllerBuildResume({Map<String, dynamic>? query, Options? options, required ApiBuildResumeDTO body}) => client.post("/resume/build-resume", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerGenerateCoverLetter({Map<String, dynamic>? query, Options? options, required ApiGenerateCoverLetterDTO body}) => client.post("/resume/cover-letter", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerGenerateCoverLetterPdf({Map<String, dynamic>? query, Options? options, required ApiGenerateCoverLetterPdfDTO body}) => client.post("/resume/cover-letter-pdf", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerStreamCoverLetter({Map<String, dynamic>? query, Options? options, required ApiGenerateCoverLetterDTO body}) => client.post("/resume/cover-letter/stream", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeDraftControllerList({Map<String, dynamic>? query, Options? options}) => client.get("/resume/drafts", queryParameters: query, options: options);
  Future<Response<dynamic>> resumeDraftControllerCreate({Map<String, dynamic>? query, Options? options, required ApiCreateResumeDraftDTO body}) => client.post("/resume/drafts", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeDraftControllerRead({required String id, Map<String, dynamic>? query, Options? options}) => client.get("/resume/drafts/${Uri.encodeComponent(id)}", queryParameters: query, options: options);
  Future<Response<dynamic>> resumeDraftControllerUpdate({required String id, Map<String, dynamic>? query, Options? options, required ApiUpdateResumeDraftDTO body}) => client.put("/resume/drafts/${Uri.encodeComponent(id)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeDraftControllerRemove({required String id, Map<String, dynamic>? query, Options? options}) => client.delete("/resume/drafts/${Uri.encodeComponent(id)}", options: options);
  Future<Response<dynamic>> resumeBuilderControllerGenerateResume({Map<String, dynamic>? query, Options? options, required ApiBuildResumeDTO body}) => client.post("/resume/generate", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerGenerateResumeFromText({Map<String, dynamic>? query, Options? options, required ApiGenerateResumeFromTextDTO body}) => client.post("/resume/generate-from-text", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerGenerateInterviewPrepPdf({Map<String, dynamic>? query, Options? options, required ApiGenerateInterviewPrepPdfDTO body}) => client.post("/resume/interview-prep-pdf", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerOptimizeResume({Map<String, dynamic>? query, Options? options, required ApiOptimizeResumeDTO body}) => client.post("/resume/optimize", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerStreamOptimizeResume({Map<String, dynamic>? query, Options? options, required ApiOptimizeResumeDTO body}) => client.post("/resume/optimize/stream", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerPolishCoverLetter({Map<String, dynamic>? query, Options? options, required ApiPolishCoverLetterDTO body}) => client.post("/resume/polish-cover-letter", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerStreamPolishCoverLetter({Map<String, dynamic>? query, Options? options, required ApiPolishCoverLetterDTO body}) => client.post("/resume/polish-cover-letter/stream", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeBuilderControllerStreamRefineBio({Map<String, dynamic>? query, Options? options, required ApiRefineProfileBioDTO body}) => client.post("/resume/refine-bio/stream", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeTemplateControllerFindAllResumeTemplate({Map<String, dynamic>? query, Options? options}) => client.get("/resume/template/all", queryParameters: query, options: options);
  Future<Response<dynamic>> resumeTemplateControllerCreateResumeTemplate({Map<String, dynamic>? query, Options? options, required ApiCreateResumeTemplateDTO body}) => client.post("/resume/template/create", data: body.toJson(), options: options);
  Future<Response<dynamic>> resumeTemplateControllerFindOneResumeTemplateById({required String id, Map<String, dynamic>? query, Options? options}) => client.get("/resume/template/one/${Uri.encodeComponent(id)}", queryParameters: query, options: options);
  Future<Response<dynamic>> resumeTemplateControllerSearchResumeTemplate({Map<String, dynamic>? query, Options? options}) => client.get("/resume/template/search", queryParameters: query, options: options);
  Future<Response<dynamic>> facebookControllerFacebookCallback({Map<String, dynamic>? query, Options? options}) => client.get("/social/facebook/callback", queryParameters: query, options: options);
  Future<Response<dynamic>> facebookControllerFacebookAuth({Map<String, dynamic>? query, Options? options}) => client.get("/social/facebook/login", queryParameters: query, options: options);
  Future<Response<dynamic>> githubControllerGithubCallback({Map<String, dynamic>? query, Options? options}) => client.get("/social/github/callback", queryParameters: query, options: options);
  Future<Response<dynamic>> githubControllerGithubAuth({Map<String, dynamic>? query, Options? options}) => client.get("/social/github/login", queryParameters: query, options: options);
  Future<Response<dynamic>> googleControllerGoogleCallback({Map<String, dynamic>? query, Options? options}) => client.get("/social/google/callback", queryParameters: query, options: options);
  Future<Response<dynamic>> googleControllerGoogleAuth({Map<String, dynamic>? query, Options? options}) => client.get("/social/google/login", queryParameters: query, options: options);
  Future<Response<dynamic>> linkedInControllerLinkedInCallback({Map<String, dynamic>? query, Options? options}) => client.get("/social/linkedin/callback", queryParameters: query, options: options);
  Future<Response<dynamic>> linkedInControllerLinkedInAuth({Map<String, dynamic>? query, Options? options}) => client.get("/social/linkedin/login", queryParameters: query, options: options);
  Future<Response<dynamic>> mobileOAuthControllerExchange({Map<String, dynamic>? query, Options? options, required ApiMobileOAuthExchangeDTO body}) => client.post("/social/mobile/exchange", data: body.toJson(), options: options);
  Future<Response<dynamic>> publicStorageControllerGetPublicFile({required String folder, Map<String, dynamic>? query, Options? options}) => client.get("/storage/${Uri.encodeComponent(folder)}/{path}", queryParameters: query, options: options);
  Future<Response<dynamic>> accountLifecycleControllerRequestDeletion({Map<String, dynamic>? query, Options? options}) => client.post("/user/account/delete", options: options);
  Future<Response<dynamic>> accountLifecycleControllerCancelDeletion({Map<String, dynamic>? query, Options? options}) => client.post("/user/account/delete/cancel", options: options);
  Future<Response<dynamic>> accountLifecycleControllerExportData({Map<String, dynamic>? query, Options? options}) => client.get("/user/account/export", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerFindAllUsers({Map<String, dynamic>? query, Options? options}) => client.get("/user/all", queryParameters: query, options: options);
  Future<Response<dynamic>> companyControllerFindAll({Map<String, dynamic>? query, Options? options}) => client.get("/user/company/all", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerFindAllCompanyFavorite({required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/user/company/all-favorites/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> companyControllerCountAllCompanies({Map<String, dynamic>? query, Options? options}) => client.get("/user/company/count", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerCountCompanyFavorite({required String cid, Map<String, dynamic>? query, Options? options}) => client.get("/user/company/count-favorite/${Uri.encodeComponent(cid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> companyControllerFindOneById({required String companyId, Map<String, dynamic>? query, Options? options}) => client.get("/user/company/one/${Uri.encodeComponent(companyId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> companyControllerRemoveCompanyAvatar({required String companyId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/remove-avatar/${Uri.encodeComponent(companyId)}", options: options);
  Future<Response<dynamic>> companyControllerRemoveCompanyCover({required String companyId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/remove-cover/${Uri.encodeComponent(companyId)}", options: options);
  Future<Response<dynamic>> companyControllerRemoveCompanyImage({required String companyId, required String imageId, Map<String, dynamic>? query, Options? options}) => client.delete("/user/company/remove-images/${Uri.encodeComponent(companyId)}/${Uri.encodeComponent(imageId)}", options: options);
  Future<Response<dynamic>> companyControllerRemoveOpenPosition({required String companyId, required String opId, Map<String, dynamic>? query, Options? options}) => client.delete("/user/company/remove-open-position/${Uri.encodeComponent(companyId)}/${Uri.encodeComponent(opId)}", options: options);
  Future<Response<dynamic>> companyControllerUpdateCompanyInfo({required String companyId, Map<String, dynamic>? query, Options? options, required ApiUpdateCompanyInfoDTO body}) => client.patch("/user/company/update-info/${Uri.encodeComponent(companyId)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> companyControllerUploadCompanyAvatar({required String companyId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/upload-avatar/${Uri.encodeComponent(companyId)}", options: options);
  Future<Response<dynamic>> companyControllerUploadCompanyCover({required String companyId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/upload-cover/${Uri.encodeComponent(companyId)}", options: options);
  Future<Response<dynamic>> companyControllerUploadCompanyImages({required String companyId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/upload-images/${Uri.encodeComponent(companyId)}", options: options);
  Future<Response<dynamic>> userControllerCompanyFavoriteEmployee({required String cid, required String eid, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/${Uri.encodeComponent(cid)}/favorite/employee/${Uri.encodeComponent(eid)}", options: options);
  Future<Response<dynamic>> userControllerCompanyUnfavoriteEmployee({required String cid, required String eid, required String favoriteId, Map<String, dynamic>? query, Options? options}) => client.post("/user/company/${Uri.encodeComponent(cid)}/unfavorite/${Uri.encodeComponent(favoriteId)}/employee/${Uri.encodeComponent(eid)}", options: options);
  Future<Response<dynamic>> userControllerGetCurrentUser({Map<String, dynamic>? query, Options? options}) => client.get("/user/current-user", queryParameters: query, options: options);
  Future<Response<dynamic>> employeeControllerFindAll({Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/all", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerFindAllEmployeeFavorite({required String eid, Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/all-favorites/${Uri.encodeComponent(eid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerCountEmployeeFavorite({required String eid, Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/count-favorite/${Uri.encodeComponent(eid)}", queryParameters: query, options: options);
  Future<Response<dynamic>> employeeControllerFindOneById({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/one/${Uri.encodeComponent(employeeId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> employeeControllerRemoveEmployeeAvatar({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/remove-avatar/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> employeeControllerRemoveEmployeeCoverLetter({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/remove-cover-letter/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> employeeControllerRemoveEmployeeEducation({required String employeeId, required String educationId, Map<String, dynamic>? query, Options? options}) => client.delete("/user/employee/remove-education/${Uri.encodeComponent(employeeId)}/${Uri.encodeComponent(educationId)}", options: options);
  Future<Response<dynamic>> employeeControllerRemoveEmployeeExperience({required String employeeId, required String experienceId, Map<String, dynamic>? query, Options? options}) => client.delete("/user/employee/remove-experience/${Uri.encodeComponent(employeeId)}/${Uri.encodeComponent(experienceId)}", options: options);
  Future<Response<dynamic>> employeeControllerRemoveEmployeeResume({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/remove-resume/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> employeeControllerSearchEmployee({Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/search-employee", queryParameters: query, options: options);
  Future<Response<dynamic>> employeeControllerUpdateEmployeeInfo({required String employeeId, Map<String, dynamic>? query, Options? options, required ApiUpdateEmployeeInfoDTO body}) => client.patch("/user/employee/update-info/${Uri.encodeComponent(employeeId)}", data: body.toJson(), options: options);
  Future<Response<dynamic>> employeeControllerUploadEmployeeAvatar({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/upload-avatar/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> employeeControllerUploadEmployeeCoverLetter({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/upload-cover-letter/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> employeeControllerUploadEmployeeResume({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/upload-resume/${Uri.encodeComponent(employeeId)}", options: options);
  Future<Response<dynamic>> userControllerEmployeeFavoriteCompany({required String eid, required String cid, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/${Uri.encodeComponent(eid)}/favorite/company/${Uri.encodeComponent(cid)}", options: options);
  Future<Response<dynamic>> userControllerEmployeeUnfavoriteCompany({required String eid, required String cid, required String favoriteId, Map<String, dynamic>? query, Options? options}) => client.post("/user/employee/${Uri.encodeComponent(eid)}/unfavorite/${Uri.encodeComponent(favoriteId)}/company/${Uri.encodeComponent(cid)}", options: options);
  Future<Response<dynamic>> employeeControllerGetDocument({required String employeeId, required String type, Map<String, dynamic>? query, Options? options}) => client.get("/user/employee/${Uri.encodeComponent(employeeId)}/document/${Uri.encodeComponent(type)}", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerFindAllCareerScopes({Map<String, dynamic>? query, Options? options}) => client.get("/user/find-all-career-scopes", queryParameters: query, options: options);
  Future<Response<dynamic>> profileAnalyticsControllerUpdatePrivacySettings({Map<String, dynamic>? query, Options? options, required ApiUpdatePrivacyDTO body}) => client.patch("/user/me/privacy", data: body.toJson(), options: options);
  Future<Response<dynamic>> profileAnalyticsControllerGetMyProfileAnalytics({Map<String, dynamic>? query, Options? options}) => client.get("/user/me/profile-analytics", queryParameters: query, options: options);
  Future<Response<dynamic>> moderationControllerGetBlockStatus({required String userId, Map<String, dynamic>? query, Options? options}) => client.get("/user/moderation/block-status/${Uri.encodeComponent(userId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> moderationControllerBlockUser({required String userId, Map<String, dynamic>? query, Options? options}) => client.post("/user/moderation/block/${Uri.encodeComponent(userId)}", options: options);
  Future<Response<dynamic>> moderationControllerUnblockUser({required String userId, Map<String, dynamic>? query, Options? options}) => client.delete("/user/moderation/block/${Uri.encodeComponent(userId)}", options: options);
  Future<Response<dynamic>> moderationControllerListBlockedUsers({Map<String, dynamic>? query, Options? options}) => client.get("/user/moderation/blocked", queryParameters: query, options: options);
  Future<Response<dynamic>> moderationControllerGetHiddenProfileIds({Map<String, dynamic>? query, Options? options}) => client.get("/user/moderation/hidden-ids", queryParameters: query, options: options);
  Future<Response<dynamic>> moderationControllerReportUser({Map<String, dynamic>? query, Options? options, required ApiCreateReportBodyDTO body}) => client.post("/user/moderation/report", data: body.toJson(), options: options);
  Future<Response<dynamic>> userControllerFindOneUserById({required String userId, Map<String, dynamic>? query, Options? options}) => client.get("/user/one/${Uri.encodeComponent(userId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerUpdatePushNotificationToken({Map<String, dynamic>? query, Options? options, required ApiUpdatePushNotificationTokenBodyDTO body}) => client.post("/user/push-token", data: body.toJson(), options: options);
  Future<Response<dynamic>> userControllerGetCompanyRecommendations({required String companyId, Map<String, dynamic>? query, Options? options}) => client.get("/user/recommendation/company/${Uri.encodeComponent(companyId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> userControllerGetEmployeeRecommendations({required String employeeId, Map<String, dynamic>? query, Options? options}) => client.get("/user/recommendation/employee/${Uri.encodeComponent(employeeId)}", queryParameters: query, options: options);
  Future<Response<dynamic>> supportControllerReportProblem({Map<String, dynamic>? query, Options? options, required ApiReportProblemBodyDTO body}) => client.post("/user/support/report-problem", data: body.toJson(), options: options);
}

const realtimeRefreshEvents = <String>["newNotification","badgeIncrement","interviewUpdate","unmatchUpdate"];
