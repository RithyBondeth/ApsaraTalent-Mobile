import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/verify_email_notice.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_card.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_sheet.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// The home tab: counterpart profiles to like or save. An employee sees
/// companies and a company sees talent, the same split as the web feed.
@RoutePage()
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  /// How close to the bottom, in logical pixels, the next page starts loading.
  static const _loadMoreThreshold = 600.0;

  /// Fewer visible cards than this, with more pages left, loads the next page
  /// without waiting for a scroll.
  static const _sparsePage = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    final feed = ref.watch(feedProvider);
    final state = feed.value;
    final notifier = ref.read(feedProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // After a failed page, retrying is the button's job — otherwise every
        // scroll event near the bottom would fire another request.
        if (state?.loadMoreError == null &&
            notification.metrics.axis == Axis.vertical &&
            notification.metrics.extentAfter < _loadMoreThreshold) {
          notifier.loadMore();
        }
        return false;
      },
      child: AppScreen(
        appBar: AppHeader(
          name: user?.displayName ?? 'Your account',
          subtitle: user?.headline ?? '',
          avatarUrl: user?.avatarUrl,
          unreadCount: state?.unreadCount ?? 0,
          onProfileTap: () => context.router.push(const ProfileRoute()),
          onNotificationsTap: () =>
              context.router.push(const NotificationRoute()),
        ),
        onRefresh: () async {
          try {
            await notifier.refresh();
          } on ApiException catch (e) {
            if (context.mounted) _snack(context, e.message);
          }
        },
        children: [
          const VerifyEmailNotice(),
          ...feed.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () => _loading(ref),
            error: (error, _) => [
              PageState(
                variant: PageStateVariant.error,
                title: 'The feed could not load',
                description: error is ApiException
                    ? error.message
                    : 'Check your connection and try again.',
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(feedProvider),
              ),
            ],
            data: (state) => state == null
                ? const [
                    PageState(
                      variant: PageStateVariant.empty,
                      icon: LucideIcons.newspaper,
                      title: 'No feed for this account',
                      description:
                          'The feed shows companies to talent and talent to '
                          'companies. Finish your profile to see yours.',
                    ),
                  ]
                : _content(context, ref, state),
          ),
        ],
      ),
    );
  }

  List<Widget> _loading(WidgetRef ref) {
    final viewer = ref.watch(feedViewerProvider);
    return [
      if (viewer != null) _banner(viewer.role, null),
      for (var i = 0; i < 3; i++) const FeedProfileCardSkeleton(),
    ];
  }

  Widget _banner(FeedViewerRole role, FeedState? state) {
    final employee = role == FeedViewerRole.employee;
    return PageBanner(
      eyebrow: employee ? 'Companies' : 'Talent',
      title: employee
          ? 'Companies hiring for what you do'
          : 'Talent that fits your roles',
      subtitle: employee
          ? 'Like a company to show interest. If they like you back, '
              "it's a match."
          : 'Like a candidate to show interest. If they like you back, '
              "it's a match.",
      // Withheld until loaded, so no placeholder zero flashes and reflows.
      stats: state == null
          ? null
          : [
              PageBannerStat(
                icon: LucideIcons.sparkles,
                value: '${state.visibleRecommendations.length}',
                label: 'for you',
              ),
              PageBannerStat(
                icon: LucideIcons.heart,
                value: '${state.likedIds.length}',
                label: 'liked',
              ),
              PageBannerStat(
                icon: LucideIcons.bookmark,
                value: '${state.favorites.length}',
                label: 'saved',
              ),
            ],
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, FeedState state) {
    final employee = state.viewer.role == FeedViewerRole.employee;
    final recommendations = state.visibleRecommendations;
    final profiles = state.visibleProfiles;
    final noun = employee ? 'companies' : 'talent';

    // A page of profiles the viewer already liked leaves nothing to scroll,
    // so no scroll event would ever ask for the next page. Ask now.
    if (profiles.length < _sparsePage &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.loadMoreError == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(feedProvider.notifier).loadMore(),
      );
    }

    Widget card(FeedProfile profile, {bool recommended = false}) =>
        FeedProfileCard(
          key: ValueKey('${recommended ? 'rec' : 'all'}-${profile.id}'),
          profile: profile,
          recommended: recommended,
          saved: state.isSaved(profile.id),
          busy: state.isPending(profile.id),
          onTap: () => showFeedProfileSheet(
            context,
            profile: profile,
            onSave: () => _save(context, ref, profile),
            onLike: () => _like(context, ref, profile),
          ),
          onSave: () => _save(context, ref, profile),
          onLike: () => _like(context, ref, profile),
          onView: () => {},
        );
    return [
      _banner(state.viewer.role, state),
      if (recommendations.isNotEmpty) ...[
        SectionTitle(
          title: 'Recommended for you',
          subtitle: employee
              ? 'Ranked against your skills and career scopes'
              : 'Ranked against your open roles and career scopes',
        ),
        for (final profile in recommendations) card(profile, recommended: true),
      ] else if (state.recommendationsError != null)
        PageState(
          variant: PageStateVariant.error,
          compact: true,
          title: 'Recommendations are unavailable',
          description: state.recommendationsError,
          actionLabel: 'Retry',
          onAction: () => _refresh(context, ref),
        ),
      SectionTitle(
        title: employee ? 'All companies' : 'All talent',
        subtitle: employee
            ? 'Every company on Apsara Talent you have not liked yet'
            : 'Every candidate on Apsara Talent you have not liked yet',
      ),
      if (profiles.isEmpty && !state.hasMore)
        PageState(
          variant: PageStateVariant.empty,
          icon: employee ? LucideIcons.building2 : LucideIcons.users,
          compact: true,
          title: 'You have seen all the $noun',
          description: 'New profiles appear here as they join. Pull down to '
              'check again.',
        )
      else
        for (final profile in profiles) card(profile),
      if (state.isLoadingMore)
        const FeedProfileCardSkeleton()
      else if (state.loadMoreError != null)
        PageState(
          variant: PageStateVariant.error,
          compact: true,
          title: 'More $noun could not load',
          description: state.loadMoreError,
          actionLabel: 'Try again',
          onAction: () => ref.read(feedProvider.notifier).loadMore(),
        )
      else if (!state.hasMore && profiles.isNotEmpty)
        const _EndOfFeed(),
    ];
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(feedProvider.notifier).refresh();
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message);
    }
  }

  Future<void> _like(
    BuildContext context,
    WidgetRef ref,
    FeedProfile profile,
  ) async {
    try {
      final outcome = await ref.read(feedProvider.notifier).like(profile);
      if (!context.mounted) return;
      _snack(
        context,
        outcome == FeedLikeOutcome.matched
            ? "It's a match! You and ${profile.displayName} liked each other."
            : 'You liked ${profile.displayName}. '
                "You'll match if they like you back.",
      );
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message);
    }
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    FeedProfile profile,
  ) async {
    try {
      final saved = await ref.read(feedProvider.notifier).toggleSave(profile);
      if (!context.mounted) return;
      _snack(
        context,
        saved
            ? 'Saved ${profile.displayName}.'
            : 'Removed ${profile.displayName} from saved.',
      );
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message);
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EndOfFeed extends StatelessWidget {
  const _EndOfFeed();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppShape.space4),
      child: Row(
        children: [
          Expanded(child: Divider(color: t.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppShape.space3),
            child: Text(
              "You're all caught up",
              style: AppTypography.tiny.copyWith(color: t.mutedForeground),
            ),
          ),
          Expanded(child: Divider(color: t.border)),
        ],
      ),
    );
  }
}
