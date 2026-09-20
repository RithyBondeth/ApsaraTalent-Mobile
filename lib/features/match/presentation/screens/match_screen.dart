import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_card.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/match/presentation/widgets/match_card.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Mutual matches: both sides liked each other.
///
/// The feed announced these and had nowhere to send anyone. This is where it
/// sends them.
@RoutePage()
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  bool _markedSeen = false;

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchesProvider);
    final notifier = ref.read(matchesProvider.notifier);

    // Opening the list is what "seen" means — the API has no per-match route.
    // Once per visit, after the first load lands.
    if (!_markedSeen && matches.hasValue && matches.value != null) {
      _markedSeen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.markSeen());
    }

    return AppScreen(
      appBar: AppBar(title: const Text('Matches')),
      onRefresh: () async {
        try {
          await notifier.refresh();
        } on ApiException catch (e) {
          // `this.context` rather than build's parameter: the mounted check
          // that guards it belongs to the State.
          if (mounted) _snack(this.context, e.message);
        }
      },
      children: matches.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => [
          for (var i = 0; i < 2; i++) const FeedProfileCardSkeleton(),
        ],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your matches could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(matchesProvider),
          ),
        ],
        data: (state) => state == null
            ? const [
                PageState(
                  variant: PageStateVariant.empty,
                  icon: LucideIcons.sparkles,
                  title: 'No matches on this account',
                  description: 'Matching is for talent and companies. Finish '
                      'your profile to start.',
                ),
              ]
            : _content(state),
      ),
    );
  }

  List<Widget> _content(MatchesState state) {
    final employee = state.viewer.role == FeedViewerRole.employee;
    final matches = state.matches;

    return [
      PageBanner(
        eyebrow: 'Matches',
        title: employee ? 'Companies who liked you back' : 'Talent who liked you back',
        subtitle: 'A match means you both said yes. Start the conversation.',
        stats: [
          PageBannerStat(
            icon: LucideIcons.sparkles,
            value: '${matches.length}',
            label: matches.length == 1 ? 'match' : 'matches',
          ),
        ],
      ),
      if (matches.isEmpty)
        PageState(
          variant: PageStateVariant.empty,
          icon: LucideIcons.sparkles,
          title: 'No matches yet',
          description: employee
              ? 'Like companies in the feed. When one likes you back, they '
                  'appear here.'
              : 'Like candidates in the feed. When one likes you back, they '
                  'appear here.',
          actionLabel: 'Back to the feed',
          onAction: () => context.router.maybePop(),
        )
      else
        for (final match in matches)
          MatchCard(
            key: ValueKey('match-${match.profile.id}'),
            match: match,
            busy: state.isPending(match.profile.id),
            onTap: () => _snack(
              context,
              'A full profile view for matches is not built yet.',
            ),
            onMessage: () => _snack(
              context,
              'Messaging is not wired up yet.',
            ),
            onUnmatch: () => _confirmUnmatch(match),
          ),
      const SizedBox(height: AppShape.space6),
    ];
  }

  /// Unmatching is destructive well beyond ending the match: the API deletes
  /// the whole matching row, which holds both sides' likes, along with every
  /// interview scheduled between the two. The dialog says so, because none of
  /// that is guessable from the word "unmatch".
  Future<void> _confirmUnmatch(MatchProfile match) async {
    final name = match.profile.displayName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this match?'),
        content: Text(
          'You and $name will no longer be matched. This also undoes both '
          'your likes, so they return to your feed, and it cancels any '
          'interviews scheduled between you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unmatch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(matchesProvider.notifier).unmatch(match);
      if (mounted) _snack(context, 'You are no longer matched with $name.');
    } on ApiException catch (e) {
      if (mounted) _snack(context, e.message);
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
