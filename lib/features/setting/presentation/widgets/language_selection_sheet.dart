import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/setting/providers/locale_provider.dart';

Future<void> showLanguageSelection(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => const _LanguageSelectionSheet(),
    );

class _LanguageSelectionSheet extends ConsumerWidget {
  const _LanguageSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeProvider).languageCode;
    final t = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppShape.space5,
        AppShape.space5,
        AppShape.space5,
        AppShape.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('Choose language'),
                  style: AppTypography.h4.copyWith(color: t.foreground),
                ),
              ),
              IconButton(
                tooltip: context.tr('Close'),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
          Text(
            context.tr('Select the language used throughout Apsara Talent.'),
            style: AppTypography.small.copyWith(color: t.mutedForeground),
          ),
          const SizedBox(height: AppShape.space4),
          _LanguageOption(
            title: 'English',
            subtitle: context.tr('Use English throughout the app'),
            languageCode: 'en',
            selected: selected == 'en',
          ),
          const SizedBox(height: AppShape.space2),
          _LanguageOption(
            title: 'ភាសាខ្មែរ',
            subtitle: 'ប្រើភាសាខ្មែរនៅទូទាំងកម្មវិធី',
            languageCode: 'km',
            selected: selected == 'km',
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.languageCode,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final String languageCode;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: () async {
          await ref
              .read(localeProvider.notifier)
              .setLocale(Locale(languageCode));
          if (context.mounted) Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(AppShape.space4),
          decoration: BoxDecoration(
            color: selected ? t.primary.withValues(alpha: 0.08) : t.background,
            border: Border.all(color: selected ? t.primary : t.input),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppShape.space1),
                    Text(
                      subtitle,
                      style:
                          AppTypography.tiny.copyWith(color: t.mutedForeground),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? LucideIcons.circleCheck : LucideIcons.circle,
                color: selected ? t.primary : t.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
