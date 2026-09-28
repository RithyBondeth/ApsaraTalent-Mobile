import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/saved_search/data/repositories/saved_search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/repositories/saved_search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedSearchRepositoryProvider = Provider<SavedSearchRepository>(
  (ref) => SavedSearchRepositoryImpl(ref.watch(apiClientProvider)),
);

/// Saved searches are for candidates. The API answers a company with 403, so
/// the entry points are not shown to one rather than shown and refused.
final canSaveSearchesProvider = Provider<bool>(
  (ref) => ref.watch(feedViewerProvider)?.role == FeedViewerRole.employee,
);

class SavedSearchesState {
  const SavedSearchesState({
    this.items = const [],
    this.previews = const {},
    this.previewFailedIds = const {},
    this.pendingIds = const {},
  });

  final List<SavedSearch> items;

  /// Loaded after the list, per search, so a slow count never holds the list
  /// back. Absent means still loading or unavailable.
  final Map<String, SavedSearchPreview> previews;
  final Set<String> previewFailedIds;
  final Set<String> pendingIds;

  bool isPending(String id) => pendingIds.contains(id);

  SavedSearchesState copyWith({
    List<SavedSearch>? items,
    Map<String, SavedSearchPreview>? previews,
    Set<String>? previewFailedIds,
    Set<String>? pendingIds,
  }) =>
      SavedSearchesState(
        items: items ?? this.items,
        previews: previews ?? this.previews,
        previewFailedIds: previewFailedIds ?? this.previewFailedIds,
        pendingIds: pendingIds ?? this.pendingIds,
      );
}

class SavedSearchesNotifier
    extends AutoDisposeAsyncNotifier<SavedSearchesState> {
  bool _disposed = false;

  SavedSearchRepository get _repository =>
      ref.read(savedSearchRepositoryProvider);

  @override
  Future<SavedSearchesState> build() async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final repository = _repository;
    final items = await repository.fetchAll();
    // Counts follow the list rather than blocking it.
    Future.microtask(() => _loadPreviews(items, repository));
    return SavedSearchesState(items: items);
  }

  Future<void> refresh() async {
    final items = await _repository.fetchAll();
    state = AsyncData(SavedSearchesState(items: items));
    await _loadPreviews(items, _repository);
  }

  /// One count per search. A failed count leaves that one blank rather than
  /// failing the list — the search still exists and still runs.
  Future<void> _loadPreviews(
    List<SavedSearch> items,
    SavedSearchRepository repository,
  ) async {
    for (final item in items) {
      if (_disposed) return;
      try {
        final preview = await repository.preview(item.id);
        if (_disposed) return;
        final latest = state.value;
        if (latest == null) return;
        state = AsyncData(latest.copyWith(
          previews: {...latest.previews, item.id: preview},
          previewFailedIds: {...latest.previewFailedIds}..remove(item.id),
        ));
      } on ApiException {
        if (_disposed) return;
        final latest = state.value;
        if (latest == null) return;
        state = AsyncData(latest.copyWith(
          previewFailedIds: {...latest.previewFailedIds, item.id},
        ));
      }
    }
  }

  /// Saves the search the viewer is looking at. Not optimistic: the new row
  /// needs the id the API gives it before anything can be done with it.
  Future<SavedSearch> save({
    required String name,
    required String keyword,
    List<String> careerScopes = const [],
    SearchFrequency frequency = SearchFrequency.weekly,
  }) async {
    final created = await _repository.create(
      name: name,
      keyword: keyword,
      careerScopes: careerScopes,
      frequency: frequency,
    );
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(items: [created, ...current.items]));
      await _loadPreviews([created], _repository);
    }
    return created;
  }

  Future<void> setFrequency(SavedSearch search, SearchFrequency frequency) =>
      _optimistic(
        search.id,
        change: (s) => s.copyWith(frequency: frequency),
        write: () => _repository.setFrequency(search.id, frequency),
      );

  /// Deletes. The row leaves at once and comes back if the request fails.
  Future<void> remove(SavedSearch search) async {
    final current = state.value;
    if (current == null || current.isPending(search.id)) return;

    state = AsyncData(current.copyWith(
      items: current.items.where((s) => s.id != search.id).toList(),
      previews: {...current.previews}..remove(search.id),
      previewFailedIds: {...current.previewFailedIds}..remove(search.id),
      pendingIds: {...current.pendingIds, search.id},
    ));
    try {
      await _repository.remove(search.id);
      _settle(search.id);
    } on ApiException {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        items: current.items,
        previews: current.previews,
        previewFailedIds: current.previewFailedIds,
        pendingIds: {...latest.pendingIds}..remove(search.id),
      ));
      rethrow;
    }
  }

  Future<void> _optimistic(
    String id, {
    required SavedSearch Function(SavedSearch) change,
    required Future<SavedSearch> Function() write,
  }) async {
    final current = state.value;
    if (current == null || current.isPending(id)) return;

    state = AsyncData(current.copyWith(
      items: [
        for (final s in current.items)
          if (s.id == id) change(s) else s,
      ],
      pendingIds: {...current.pendingIds, id},
    ));
    try {
      final saved = await write();
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        items: [
          for (final s in latest.items)
            if (s.id == id) saved else s,
        ],
        pendingIds: {...latest.pendingIds}..remove(id),
      ));
    } on ApiException {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        items: current.items,
        pendingIds: {...latest.pendingIds}..remove(id),
      ));
      rethrow;
    }
  }

  void _settle(String id) {
    final latest = state.value;
    if (latest == null) return;
    state = AsyncData(
      latest.copyWith(pendingIds: {...latest.pendingIds}..remove(id)),
    );
  }
}

final savedSearchesProvider = AsyncNotifierProvider.autoDispose<
    SavedSearchesNotifier, SavedSearchesState>(SavedSearchesNotifier.new);
