import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/application/data/repositories/application_repository_impl.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:apsaratalent_mobile/features/application/domain/repositories/application_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => ApplicationRepositoryImpl(ref.watch(apiClientProvider)),
);

class ApplicationsState {
  const ApplicationsState({this.items = const [], this.pendingIds = const {}});

  final List<JobApplication> items;

  /// Applications with a withdrawal in flight.
  final Set<String> pendingIds;

  int get open => items.where((a) => a.status.isOpen).length;
  bool isPending(String id) => pendingIds.contains(id);

  ApplicationsState copyWith({
    List<JobApplication>? items,
    Set<String>? pendingIds,
  }) =>
      ApplicationsState(
        items: items ?? this.items,
        pendingIds: pendingIds ?? this.pendingIds,
      );
}

class ApplicationsNotifier
    extends AutoDisposeAsyncNotifier<ApplicationsState> {
  ApplicationRepository get _repository =>
      ref.read(applicationRepositoryProvider);

  @override
  Future<ApplicationsState> build() async =>
      ApplicationsState(items: await _repository.fetchMine());

  Future<void> refresh() async {
    state = AsyncData(ApplicationsState(items: await _repository.fetchMine()));
  }

  /// Withdraws [application]. The row stays — it moves to `withdrawn`, which
  /// is what the API does — rather than disappearing, so the record of having
  /// applied is not silently lost.
  Future<void> withdraw(JobApplication application) async {
    final current = state.value;
    if (current == null ||
        current.isPending(application.id) ||
        !application.status.canWithdraw) {
      return;
    }

    state = AsyncData(_replace(
      current,
      application.id,
      (a) => a.copyWith(status: ApplicationStatus.withdrawn),
      pending: true,
    ));

    try {
      await _repository.withdraw(application.id);
      _settle(application.id);
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(_replace(
          latest,
          application.id,
          (a) => a.copyWith(status: application.status),
          pending: false,
        ));
      }
      rethrow;
    }
  }

  ApplicationsState _replace(
    ApplicationsState from,
    String id,
    JobApplication Function(JobApplication) change, {
    required bool pending,
  }) {
    final pendingIds = {...from.pendingIds};
    pending ? pendingIds.add(id) : pendingIds.remove(id);
    return from.copyWith(
      items: [
        for (final item in from.items)
          if (item.id == id) change(item) else item,
      ],
      pendingIds: pendingIds,
    );
  }

  void _settle(String id) {
    final latest = state.value;
    if (latest == null) return;
    state = AsyncData(
      latest.copyWith(pendingIds: {...latest.pendingIds}..remove(id)),
    );
  }
}

final applicationsProvider = AsyncNotifierProvider.autoDispose<
    ApplicationsNotifier, ApplicationsState>(ApplicationsNotifier.new);
