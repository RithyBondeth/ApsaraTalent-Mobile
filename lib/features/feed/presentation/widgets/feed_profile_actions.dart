/// Open, save and like a counterpart profile from wherever it is listed.
///
/// The feed and talent search both go through `feedProvider`, so a save made
/// in one shows in the other, and a profile already liked is never offered a
/// second like. Talent search used to render these cards with no-op handlers.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_sheet.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';

/// Opens [profile] in the profile sheet.
Future<void> openFeedProfile(
  BuildContext context,
  WidgetRef ref,
  FeedProfile profile,
) {
  final liked = ref.read(feedProvider).value?.likedIds.contains(profile.id);
  return showFeedProfileSheet(
    context,
    profile: profile,
    actionState: (ref) {
      final feed = ref.watch(feedProvider).value;
      return (
        saved: feed?.isSaved(profile.id) ?? false,
        busy: feed?.isPending(profile.id) ?? false,
      );
    },
    onSave: () => saveFeedProfile(context, ref, profile),
    onLike:
        (liked ?? false) ? null : () => likeFeedProfile(context, ref, profile),
  );
}

Future<void> likeFeedProfile(
  BuildContext context,
  WidgetRef ref,
  FeedProfile profile,
) async {
  try {
    final outcome = await ref.read(feedProvider.notifier).like(profile);
    if (!context.mounted) return;
    if (outcome == FeedLikeOutcome.matched) {
      // This used to be a dead end: the app announced a match and had
      // nowhere to send anyone.
      ref.invalidate(matchCountProvider);
      _snack(
        context,
        "It's a match! You and ${profile.displayName} liked each other.",
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.router.push(const MatchRoute()),
        ),
      );
      return;
    }
    _snack(
      context,
      'You liked ${profile.displayName}. '
      "You'll match if they like you back.",
    );
  } on ApiException catch (e) {
    if (context.mounted) _snack(context, e.message);
  }
}

Future<void> saveFeedProfile(
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

void _snack(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
