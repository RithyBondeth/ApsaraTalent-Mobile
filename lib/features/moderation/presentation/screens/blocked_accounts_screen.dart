import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/entities/moderation.dart';
import 'package:apsaratalent_mobile/features/moderation/providers/moderation_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Who the viewer has blocked, and the only place to undo it.
@RoutePage()
class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedProvider);
    final notifier = ref.read(blockedProvider.notifier);

    return AppScreen(
      appBar: AppBar(title: const Text('Blocked accounts')),
      onRefresh: () async {
        try {
          await notifier.refresh();
        } on ApiException catch (e) {
          if (context.mounted) _snack(context, e.message);
        }
      },
      children: blocked.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => [for (var i = 0; i < 3; i++) const _RowSkeleton()],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'The blocked list could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(blockedProvider),
          ),
        ],
        data: (state) => [
          PageBanner(
            eyebrow: 'Privacy',
            title: 'Accounts you blocked',
            subtitle: 'Neither of you appears in the other\'s feed or search.',
            stats: [
              PageBannerStat(
                icon: LucideIcons.userX,
                value: '${state.users.length}',
                label: state.users.length == 1 ? 'account' : 'accounts',
              ),
            ],
          ),
          if (state.users.isEmpty)
            const PageState(
              variant: PageStateVariant.empty,
              icon: LucideIcons.userCheck,
              title: 'Nobody blocked',
              description:
                  'Block someone from their profile and they appear here.',
            )
          else
            for (final user in state.users)
              _BlockedRow(
                key: ValueKey(user.userId),
                user: user,
                busy: state.isPending(user.userId),
                onUnblock: () => _confirmUnblock(context, ref, user),
              ),
          const SizedBox(height: AppShape.space6),
        ],
      ),
    );
  }

  Future<void> _confirmUnblock(
    BuildContext context,
    WidgetRef ref,
    BlockedUser user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unblock ${user.name}?'),
        content: const Text(
          'You will be able to see each other again, in the feed and in '
          'search. They are not told either way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep blocked'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(blockedProvider.notifier).unblock(user);
      if (context.mounted) _snack(context, 'Unblocked ${user.name}.');
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

class _BlockedRow extends StatelessWidget {
  const _BlockedRow({
    super.key,
    required this.user,
    required this.busy,
    required this.onUnblock,
  });

  final BlockedUser user;
  final bool busy;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space2),
      child: AppSurface(
        elevation: SurfaceElevation.sm,
        padding: const EdgeInsets.all(AppShape.space3),
        child: Row(
          children: [
            AppAvatar(
              name: user.name,
              imageUrl: user.avatarUrl,
              size: AppAvatarSize.sm,
            ),
            const SizedBox(width: AppShape.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(color: t.foreground),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.roleLabel,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
              label: 'Unblock',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              loading: busy,
              onPressed: busy ? null : onUnblock,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppShape.space2),
        child: AppSurface(
          elevation: SurfaceElevation.sm,
          padding: EdgeInsets.all(AppShape.space3),
          child: Row(
            children: [
              AppSkeleton(width: 36, height: 36),
              SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 120, height: 12),
                    SizedBox(height: AppShape.space2),
                    AppSkeleton(width: 60, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
