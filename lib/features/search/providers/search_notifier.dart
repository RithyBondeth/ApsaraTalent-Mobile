import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(apiClientProvider)),
);

/// What this viewer searches. There is no company search in the gateway, so
/// an employee looks for jobs and a company looks for talent — browsing
/// companies is what the feed already does.
enum SearchMode { jobs, talent }

final searchModeProvider = Provider<SearchMode?>((ref) {
  final viewer = ref.watch(feedViewerProvider);
  return switch (viewer?.role) {
    FeedViewerRole.employee => SearchMode.jobs,
    FeedViewerRole.company => SearchMode.talent,
    null => null,
  };
});

/// The viewer's own career scopes, by name — what narrowing filters on.
///
/// Read from the profile that is already loaded for the profile screen, so
/// turning narrowing on costs no extra request.
final myCareerScopesProvider = Provider<List<String>>((ref) {
  final profile = ref.watch(profileProvider).value;
  return switch (profile) {
    EmployeeProfile(:final careerScopes) => careerScopes,
    CompanyProfile(:final careerScopes) => careerScopes,
    _ => const [],
  };
});

class SearchState {
  const SearchState({
    required this.mode,
    this.keyword = '',
    this.narrowToMyScopes = false,
    this.jobs = const [],
    this.talent = const [],
    this.total = 0,
    this.page = 1,
    this.usedFallback = false,
    this.isSearching = false,
    this.isLoadingMore = false,
    this.error,
  });

  final SearchMode mode;
  final String keyword;

  /// Off by default, and deliberately so. Scope matching is exact-string:
  /// none of the career scopes carry embeddings, so the API's similarity
  /// branch never matches and only an identical name does. Narrowing by
  /// default would quietly hide results a reader expects to see.
  final bool narrowToMyScopes;

  final List<JobPosting> jobs;
  final List<FeedEmployee> talent;
  final int total;
  final int page;

  /// The API narrowed, found nothing, and retried without the filter — so
  /// what is on screen is *not* narrowed.
  final bool usedFallback;

  final bool isSearching;
  final bool isLoadingMore;
  final String? error;

  int get count => mode == SearchMode.jobs ? jobs.length : talent.length;
  bool get hasMore => count < total;
  bool get isEmpty => count == 0;

  SearchState copyWith({
    String? keyword,
    bool? narrowToMyScopes,
    List<JobPosting>? jobs,
    List<FeedEmployee>? talent,
    int? total,
    int? page,
    bool? usedFallback,
    bool? isSearching,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) =>
      SearchState(
        mode: mode,
        keyword: keyword ?? this.keyword,
        narrowToMyScopes: narrowToMyScopes ?? this.narrowToMyScopes,
        jobs: jobs ?? this.jobs,
        talent: talent ?? this.talent,
        total: total ?? this.total,
        page: page ?? this.page,
        usedFallback: usedFallback ?? this.usedFallback,
        isSearching: isSearching ?? this.isSearching,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class SearchNotifier extends AutoDisposeNotifier<SearchState?> {
  static const _debounce = Duration(milliseconds: 350);

  Timer? _timer;
  int _generation = 0;

  SearchRepository get _repository => ref.read(searchRepositoryProvider);

  @override
  SearchState? build() {
    final mode = ref.watch(searchModeProvider);
    ref.onDispose(() => _timer?.cancel());
    if (mode == null) return null;
    return SearchState(mode: mode);
  }

  /// Types are debounced: a search runs once the viewer stops for a moment,
  /// not on every keystroke.
  void onKeyword(String keyword) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(keyword: keyword);

    _timer?.cancel();
    if (keyword.trim().isEmpty) {
      // An empty box shows nothing rather than every posting in the country.
      state = state!.copyWith(
        jobs: const [],
        talent: const [],
        total: 0,
        usedFallback: false,
        isSearching: false,
        clearError: true,
      );
      return;
    }
    _timer = Timer(_debounce, run);
  }

  void setNarrowing(bool narrow) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(narrowToMyScopes: narrow);
    if (current.keyword.trim().isNotEmpty) run();
  }

  Future<void> run() async {
    final current = state;
    if (current == null || current.keyword.trim().isEmpty) return;

    // A slow first search must not overwrite a faster later one.
    final generation = ++_generation;
    state = current.copyWith(isSearching: true, clearError: true);

    try {
      final results = await _fetch(current, page: 1);
      if (generation != _generation) return;
      state = state!.copyWith(
        jobs: results.$1,
        talent: results.$2,
        total: results.$3,
        usedFallback: results.$4,
        page: 1,
        isSearching: false,
      );
    } on ApiException catch (e) {
      if (generation != _generation) return;
      state = state!.copyWith(isSearching: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.isSearching) {
      return;
    }

    final generation = _generation;
    state = current.copyWith(isLoadingMore: true);
    try {
      final results = await _fetch(current, page: current.page + 1);
      if (generation != _generation) return;
      state = state!.copyWith(
        jobs: [...current.jobs, ...results.$1],
        talent: [...current.talent, ...results.$2],
        total: results.$3,
        page: current.page + 1,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      if (generation != _generation) return;
      state = state!.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  /// (jobs, talent, total, usedFallback) — only one list is ever populated.
  Future<(List<JobPosting>, List<FeedEmployee>, int, bool)> _fetch(
    SearchState from, {
    required int page,
  }) async {
    final scopes =
        from.narrowToMyScopes ? ref.read(myCareerScopesProvider) : const <String>[];
    final keyword = from.keyword.trim();

    if (from.mode == SearchMode.jobs) {
      final results = await _repository.searchJobs(
        keyword: keyword,
        careerScopes: scopes,
        page: page,
      );
      return (results.items, const <FeedEmployee>[], results.total, results.usedFallback);
    }
    final results = await _repository.searchTalent(
      keyword: keyword,
      careerScopes: scopes,
      page: page,
    );
    return (const <JobPosting>[], results.items, results.total, results.usedFallback);
  }
}

final searchProvider =
    NotifierProvider.autoDispose<SearchNotifier, SearchState?>(
  SearchNotifier.new,
);

/// One posting, for the detail screen.
final jobPostingProvider =
    FutureProvider.autoDispose.family<JobPosting, String>(
  (ref, jobId) => ref.read(searchRepositoryProvider).fetchJob(jobId),
);
