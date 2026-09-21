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

/// Block or report the account behind a profile.
///
/// Takes a **user** id, which is what moderation is addressed by. Where a
/// payload does not carry one — the trimmed records in favourites and matches
/// — there is nothing to call this with, and the caller does not offer it.
Future<void> showModerationSheet(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
}) async {
  final action = await showModalBottomSheet<_ModerationAction>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppShape.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.label.copyWith(
                      color: context.tokens.foreground,
                      fontSize: AppTypography.base,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(LucideIcons.flag, size: 18),
            title: const Text('Report'),
            subtitle: const Text('Tell us what is wrong. They are not told.'),
            onTap: () => Navigator.of(context).pop(_ModerationAction.report),
          ),
          ListTile(
            leading: const Icon(LucideIcons.userX, size: 18),
            title: const Text('Block'),
            subtitle: const Text(
              'You disappear from each other\'s feed and search.',
            ),
            onTap: () => Navigator.of(context).pop(_ModerationAction.block),
          ),
          const SizedBox(height: AppShape.space2),
        ],
      ),
    ),
  );

  if (action == null || !context.mounted) return;
  switch (action) {
    case _ModerationAction.block:
      await _confirmBlock(context, ref, userId: userId, name: name);
    case _ModerationAction.report:
      await _report(context, ref, userId: userId, name: name);
  }
}

enum _ModerationAction { block, report }

Future<void> _confirmBlock(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Block $name?'),
      content: const Text(
        'You will not see each other in the feed or in search, and neither '
        'of you can like the other. They are not told. You can undo this in '
        'Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Block'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(moderationActionsProvider).block(userId);
    if (context.mounted) _snack(context, 'Blocked $name.');
  } on ApiException catch (e) {
    if (context.mounted) _snack(context, e.message);
  }
}

Future<void> _report(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
}) async {
  final controller = TextEditingController();
  var reason = ReportReason.spam;

  final send = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: AppShape.screenPadding,
          right: AppShape.screenPadding,
          top: AppShape.screenPadding,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppShape.screenPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report $name',
                style:
                    AppTypography.h4.copyWith(color: context.tokens.foreground),
              ),
              const SizedBox(height: AppShape.space2),
              Text(
                // Reporting and blocking are separate on the API, so the
                // sheet says so rather than letting someone assume one does
                // the other.
                'Reporting does not block them. Block separately if you also '
                'want them gone from your feed.',
                style: AppTypography.small.copyWith(
                  color: context.tokens.mutedForeground,
                ),
              ),
              const SizedBox(height: AppShape.space4),
              // RadioGroup rather than per-tile groupValue/onChanged, both
              // of which are deprecated after Flutter 3.32.
              RadioGroup<ReportReason>(
                groupValue: reason,
                onChanged: (value) =>
                    setSheetState(() => reason = value ?? reason),
                child: Column(
                  children: [
                    for (final option in ReportReason.values)
                      RadioListTile<ReportReason>(
                        value: option,
                        title: Text(option.label),
                        subtitle: Text(option.description),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppShape.space3),
              AppInput(
                controller: controller,
                hintText: 'Anything else we should know (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: AppShape.space4),
              AppButton(
                label: 'Send report',
                icon: LucideIcons.flag,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppShape.space2),
            ],
          ),
        ),
      ),
    ),
  );

  final details = controller.text;
  controller.dispose();
  if (send != true || !context.mounted) return;

  try {
    await ref
        .read(moderationActionsProvider)
        .report(userId, reason: reason, details: details);
    if (context.mounted) {
      _snack(context, 'Report sent. Thank you — we look at every one.');
    }
  } on ApiException catch (e) {
    if (context.mounted) _snack(context, e.message);
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
