import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/providers/saved_search_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(savedSearchesProvider);
    return AppScreen(
      appBar: AppBar(title: Text(context.tr('Saved searches'))),
      onRefresh: () => ref.read(savedSearchesProvider.notifier).refresh(),
      children: searches.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => [
          for (var i = 0; i < 3; i++) const _SavedSearchSkeleton(),
        ],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your saved searches could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(savedSearchesProvider),
          ),
        ],
        data: (state) => _content(context, ref, state),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    SavedSearchesState state,
  ) =>
      [
        PageBanner(
          eyebrow: 'Job alerts',
          title: 'Return to the searches that matter',
          subtitle:
              'Open a saved search with the same filters, or choose how often '
              'new matches reach your inbox.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.bookmark,
              value: '${state.items.length}',
              label: state.items.length == 1 ? 'search' : 'searches',
            ),
          ],
        ),
        if (state.items.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.bookmark,
            title: 'No saved searches',
            description:
                'Run a job search, then use Save search to keep its filters.',
          )
        else
          for (final search in state.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space3),
              child: _SavedSearchCard(
                key: ValueKey(search.id),
                search: search,
                preview: state.previews[search.id],
                previewFailed: state.previewFailedIds.contains(search.id),
                busy: state.isPending(search.id),
                onOpen: () => context.router.pop(search),
                onFrequency: (frequency) => _run(
                  context,
                  () => ref
                      .read(savedSearchesProvider.notifier)
                      .setFrequency(search, frequency),
                ),
                onDelete: () => _confirmDelete(context, ref, search),
              ),
            ),
        const SizedBox(height: AppShape.space6),
      ];

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavedSearch search,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete saved search?')),
        content: Text(
          context.tr("“{0}” and its email schedule will be removed.",
              {'0': search.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('Keep it')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      () => ref.read(savedSearchesProvider.notifier).remove(search),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _SavedSearchCard extends StatelessWidget {
  const _SavedSearchCard({
    super.key,
    required this.search,
    required this.preview,
    required this.previewFailed,
    required this.busy,
    required this.onOpen,
    required this.onFrequency,
    required this.onDelete,
  });

  final SavedSearch search;
  final SavedSearchPreview? preview;
  final bool previewFailed;
  final bool busy;
  final VoidCallback onOpen;
  final ValueChanged<SearchFrequency> onFrequency;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final filters = <String>[
      if ((search.keyword ?? '').isNotEmpty) '“${search.keyword}”',
      if (search.careerScopes.isNotEmpty)
        '${search.careerScopes.length} career ${search.careerScopes.length == 1 ? 'scope' : 'scopes'}',
      if (search.hasOtherFilters) 'additional web filters',
    ];
    final matchText = switch ((preview, previewFailed)) {
      (SavedSearchPreview(:final total, :final newCount), _) => newCount > 0
          ? '$total current matches · $newCount new'
          : '$total current ${total == 1 ? 'match' : 'matches'}',
      (_, true) => 'Match count unavailable',
      _ => 'Checking current matches…',
    };

    return AppSurface(
      onTap: busy ? null : onOpen,
      elevation: SurfaceElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.search, size: 18, color: t.mutedForeground),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      search.name,
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filters.isEmpty ? 'All open roles' : filters.join(' · '),
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  size: 18, color: t.mutedForeground),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Text(
            matchText,
            style: AppTypography.tiny.copyWith(color: t.mutedForeground),
          ),
          const SizedBox(height: AppShape.space3),
          Row(
            children: [
              Expanded(
                child: PopupMenuButton<SearchFrequency>(
                  enabled: !busy,
                  onSelected: onFrequency,
                  itemBuilder: (context) => [
                    for (final option in SearchFrequency.values)
                      PopupMenuItem(
                        value: option,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.label),
                            Text(
                              option.description,
                              style: AppTypography.tiny.copyWith(
                                color: t.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  child: Row(
                    children: [
                      Icon(LucideIcons.mail,
                          size: 16, color: t.mutedForeground),
                      const SizedBox(width: AppShape.space2),
                      Text(
                        context.tr("{0} emails", {'0': search.frequency.label}),
                        style: AppTypography.tiny.copyWith(color: t.foreground),
                      ),
                      const SizedBox(width: AppShape.space1),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 14,
                        color: t.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: context.tr("Delete {0}", {'0': search.name}),
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedSearchSkeleton extends StatelessWidget {
  const _SavedSearchSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppShape.space3),
        child: AppSkeleton(height: 150),
      );
}
