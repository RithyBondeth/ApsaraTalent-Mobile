import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:apsaratalent_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:apsaratalent_mobile/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(apiClientProvider)),
);

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pendingIds = const {},
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<AppNotification> items;

  /// What the API says exists, which is how "more pages" is known — there is
  /// no guessing from a short page here.
  final int total;

  /// The last page loaded, 1-indexed as the API counts them.
  final int page;

  final Set<String> pendingIds;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get hasMore => items.length < total;
  int get unread => items.where((n) => !n.isRead).length;
  bool isPending(String id) => pendingIds.contains(id);

  NotificationsState copyWith({
    List<AppNotification>? items,
    int? total,
    int? page,
    Set<String>? pendingIds,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        pendingIds: pendingIds ?? this.pendingIds,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError:
            clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
      );
}

class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<NotificationsState> {
  static const pageSize = 20;

  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  Future<NotificationsState> build() async => _first();

  Future<NotificationsState> _first() async {
    final page = await _repository.fetchPage(page: 1, limit: pageSize);
    return NotificationsState(
      items: page.items,
      total: page.total,
      page: page.page,
    );
  }

  Future<void> refresh() async {
    state = AsyncData(await _first());
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final next = await _repository.fetchPage(
        page: current.page + 1,
        limit: pageSize,
      );
      final known = current.items.map((n) => n.id).toSet();
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        // A notification can shift pages if one is deleted mid-scroll.
        items: [
          ...latest.items,
          ...next.items.where((n) => !known.contains(n.id)),
        ],
        total: next.total,
        page: next.page,
        isLoadingMore: false,
      ));
    } on ApiException catch (e) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreError: e.message),
      );
    }
  }

  /// Marks one read. Optimistic; rolls back on failure. Does nothing when the
  /// notification is already read, so opening a read row costs no request.
  Future<void> markRead(AppNotification notification) async {
    final current = state.value;
    if (current == null ||
        notification.isRead ||
        current.isPending(notification.id)) {
      return;
    }

    state = AsyncData(_replace(
      current,
      notification.id,
      (n) => n.copyWith(isRead: true),
      pending: true,
    ));

    try {
      await _repository.markRead(notification.id);
      _settle(notification.id);
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(_replace(
          latest,
          notification.id,
          (n) => n.copyWith(isRead: false),
          pending: false,
        ));
      }
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null || current.unread == 0) return;

    state = AsyncData(current.copyWith(
      items: current.items.map((n) => n.copyWith(isRead: true)).toList(),
    ));

    try {
      await _repository.markAllRead();
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(items: current.items));
      }
      rethrow;
    }
  }

  /// Deletes one. The row leaves at once and comes back if the request fails.
  Future<void> remove(AppNotification notification) async {
    final current = state.value;
    if (current == null || current.isPending(notification.id)) return;

    state = AsyncData(current.copyWith(
      items: current.items.where((n) => n.id != notification.id).toList(),
      // One fewer exists, so paging does not ask for a page past the end.
      total: current.total > 0 ? current.total - 1 : 0,
      pendingIds: {...current.pendingIds, notification.id},
    ));

    try {
      await _repository.remove(notification.id);
      _settle(notification.id);
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          items: current.items,
          total: current.total,
          pendingIds: {...latest.pendingIds}..remove(notification.id),
        ));
      }
      rethrow;
    }
  }

  /// Deletes everything. The screen confirms first.
  Future<void> clearAll() async {
    final current = state.value;
    if (current == null || current.items.isEmpty) return;

    state = const AsyncData(NotificationsState());

    try {
      await _repository.clearAll();
    } on ApiException {
      state = AsyncData(current);
      rethrow;
    }
  }

  NotificationsState _replace(
    NotificationsState from,
    String id,
    AppNotification Function(AppNotification) change, {
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
    state = AsyncData(latest.copyWith(
      pendingIds: {...latest.pendingIds}..remove(id),
    ));
  }
}

final notificationsProvider = AsyncNotifierProvider.autoDispose<
    NotificationsNotifier, NotificationsState>(NotificationsNotifier.new);
