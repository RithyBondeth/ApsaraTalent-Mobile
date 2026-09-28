import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/application/data/repositories/employer_workflow_repository.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';

final employerWorkflowRepositoryProvider = Provider<EmployerWorkflowRepository>(
  (ref) => EmployerWorkflowRepository(ref.watch(apiClientProvider)),
);

final employerAnalyticsProvider = FutureProvider.autoDispose<EmployerAnalytics>(
  (ref) => ref.read(employerWorkflowRepositoryProvider).analytics(),
);

final employerInterviewsProvider =
    FutureProvider.autoDispose<List<Interview>>((ref) async {
  final viewer = ref.watch(feedViewerProvider);
  if (viewer == null) return const [];
  return ref
      .read(employerWorkflowRepositoryProvider)
      .interviews(viewer.profileId);
});

typedef PipelineRequest = ({String jobId, String companyId});

final jobPipelineProvider = FutureProvider.autoDispose
    .family<JobPipeline, PipelineRequest>((ref, request) => ref
        .read(employerWorkflowRepositoryProvider)
        .pipeline(request.jobId, request.companyId));

final applicationNotesProvider = FutureProvider.autoDispose
    .family<List<ApplicationNote>, String>((ref, applicationId) =>
        ref.read(employerWorkflowRepositoryProvider).notes(applicationId));

final applicationHistoryProvider = FutureProvider.autoDispose
    .family<List<ApplicationHistoryEntry>, String>((ref, applicationId) =>
        ref.read(employerWorkflowRepositoryProvider).history(applicationId));
