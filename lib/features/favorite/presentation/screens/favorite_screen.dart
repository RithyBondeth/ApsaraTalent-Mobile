import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/favorite/providers/favorites_notifier.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_card.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_sheet.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// The profiles the viewer bookmarked in the feed: companies for an employee,
/// talent for a company. Saving is the feed's job; this screen shows what was
/// saved and takes it back off the list.
@RoutePage()
class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);

    return AppScreen(
      appBar: AppBar(title: const Text('Saved')),
      onRefresh: () async {
        try {
          await notifier.refresh();
        } on ApiException catch (e) {
          if (context.mounted) _snack(context, e.message);
        }
      },
      children: favorites.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => _loading(ref),
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your saved profiles could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(favoritesProvider),
          ),
        ],
        data: (state) => state == null
            ? const [
                PageState(
                  variant: PageStateVariant.empty,
                  icon: LucideIcons.bookmarkX,
                  title: 'No saved profiles for this account',
                  description:
                      'Saving is for talent and companies. Finish your '
                      'profile to start saving.',
                ),
              ]
            : _content(context, ref, state),
      ),
    );
  }

  List<Widget> _loading(WidgetRef ref) {
    final viewer = ref.watch(feedViewerProvider);
    return [
      if (viewer != null) _banner(viewer.role, null),
      for (var i = 0; i < 2; i++) const FeedProfileCardSkeleton(),
    ];
  }

  Widget _banner(FeedViewerRole role, int? count) {
    final employee = role == FeedViewerRole.employee;
    return PageBanner(
      eyebrow: 'Saved',
      title: employee ? 'Companies you saved' : 'Talent you saved',
      subtitle: employee
          ? 'Kept here until you like them or take them off the list.'
          : 'Kept here until you like them or take them off the list.',
      // Withheld until loaded, so no placeholder zero flashes and reflows.
      stats: count == null
          ? null
          : [
              PageBannerStat(
                icon: LucideIcons.bookmark,
                value: '$count',
                label: employee ? 'companies saved' : 'talent saved',
              ),
            ],
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    FavoritesState state,
  ) {
    final employee = state.viewer.role == FeedViewerRole.employee;
    final visible = state.visible;

    return [
      _banner(state.viewer.role, visible.length),
      if (visible.isEmpty)
        PageState(
          variant: PageStateVariant.empty,
          icon: LucideIcons.bookmarkX,
          title: 'Nothing saved yet',
          description: employee
              ? 'Tap the bookmark on any company in the feed to keep it here.'
              : 'Tap the bookmark on any candidate in the feed to keep them '
                  'here.',
          actionLabel: 'Back to the feed',
          onAction: () => context.router.maybePop(),
        )
      else
        for (final favorite in visible)
          FeedProfileCard(
            key: ValueKey('fav-${favorite.profile.id}'),
            profile: favorite.profile,
            saved: true,
            busy: state.isPending(favorite.profile.id),
            onTap: () => showFeedProfileSheet(
              context,
              profile: favorite.profile,
              actionState: (ref) {
                final latest = ref.watch(favoritesProvider).value;
                return (
                  saved: true,
                  busy: latest?.isPending(favorite.profile.id) ?? false,
                );
              },
              onSave: () => _remove(context, ref, favorite),
            ),
            onSave: () => _remove(context, ref, favorite),
            onView: () => {},
          ),
    ];
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    FavoriteProfile favorite,
  ) async {
    try {
      await ref.read(favoritesProvider.notifier).remove(favorite);
      if (!context.mounted) return;
      _snack(context, 'Removed ${favorite.profile.displayName} from saved.');
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
