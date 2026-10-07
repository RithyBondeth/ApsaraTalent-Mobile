import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_actions.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_card.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/providers/saved_search_notifier.dart';
import 'package:apsaratalent_mobile/features/search/providers/search_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/job_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Search, which side depends on the viewer: an employee looks for jobs, a
/// company looks for talent.
///
/// There is no company search in the gateway — `/user/company/all` takes
/// pagination only — so browsing companies stays the feed's job.
@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  static const _loadMoreThreshold = 400.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    if (state == null) {
      return AppScreen(
        children: const [
          PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.search,
            title: 'No search on this account',
            description: 'Search is for talent and companies. Finish signing '
                'up to use it.',
          ),
        ],
      );
    }

    final jobs = state.mode == SearchMode.jobs;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (state.error == null &&
            notification.metrics.axis == Axis.vertical &&
            notification.metrics.extentAfter < _loadMoreThreshold) {
          notifier.loadMore();
        }
        return false;
      },
      child: AppScreen(
        children: [
          PageBanner(
            eyebrow: 'Search',
            title: jobs ? 'Find a role' : 'Find talent',
            subtitle: jobs
                ? 'Titles, descriptions and skills across every open posting.'
                : 'Names, roles and skills across every candidate.',
          ),
          AppInput(
            controller: _controller,
            hintText: context
                .tr(jobs ? 'Role, skill or keyword' : 'Name, role or skill'),
            prefixIcon: LucideIcons.search,
            suffixIcon: state.keyword.isEmpty ? null : LucideIcons.x,
            onSuffixTap: () {
              _controller.clear();
              notifier.onKeyword('');
            },
            textInputAction: TextInputAction.search,
            onChanged: notifier.onKeyword,
            onSubmitted: (_) => notifier.run(),
          ),
          if (jobs)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Saved searches',
                    icon: LucideIcons.bookmark,
                    variant: AppButtonVariant.outline,
                    onPressed: () => _openSavedSearches(context),
                  ),
                ),
                const SizedBox(width: AppShape.space2),
                Expanded(
                  child: AppButton(
                    label: 'Save search',
                    icon: LucideIcons.bookmarkPlus,
                    onPressed: state.keyword.trim().isEmpty
                        ? null
                        : () => _saveSearch(context, state),
                  ),
                ),
              ],
            ),
          _ScopeToggle(state: state, onChanged: notifier.setNarrowing),
          ..._results(context, state),
          const SizedBox(height: AppShape.space6),
        ],
      ),
    );
  }

  Future<void> _openSavedSearches(BuildContext context) async {
    final saved = await context.router.push<SavedSearch>(
      const SavedSearchesRoute(),
    );
    if (saved == null || !mounted) return;
    _controller.text = saved.keyword ?? '';
    await ref.read(searchProvider.notifier).applySavedSearch(saved);
  }

  Future<void> _saveSearch(BuildContext context, SearchState search) async {
    final name = TextEditingController(text: search.keyword.trim());
    var frequency = SearchFrequency.weekly;
    var saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('Save this search')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                controller: name,
                labelText: context.tr('Name'),
                hintText: context.tr('e.g. Senior design roles'),
                errorText: error,
                enabled: !saving,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppShape.space4),
              DropdownButtonFormField<SearchFrequency>(
                initialValue: frequency,
                decoration:
                    InputDecoration(labelText: context.tr('Email updates')),
                items: [
                  for (final option in SearchFrequency.values)
                    DropdownMenuItem(
                      value: option,
                      child: Text(option.label),
                    ),
                ],
                onChanged: saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setDialogState(() => frequency = value);
                        }
                      },
              ),
              const SizedBox(height: AppShape.space2),
              Text(
                frequency.description,
                style: AppTypography.tiny.copyWith(
                  color: context.tokens.mutedForeground,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(context).pop(),
              child: Text(context.tr('Cancel')),
            ),
            TextButton(
              onPressed: saving
                  ? null
                  : () async {
                      final value = name.text.trim();
                      if (value.isEmpty) {
                        setDialogState(
                            () => error = 'Give this search a name.');
                        return;
                      }
                      setDialogState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await ref.read(savedSearchesProvider.notifier).save(
                              name: value,
                              keyword: search.keyword,
                              careerScopes: search.careerScopes,
                              frequency: frequency,
                            );
                        if (context.mounted) Navigator.of(context).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(this.context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                  content:
                                      Text(this.context.tr('Search saved.'))),
                            );
                        }
                      } on ApiException catch (e) {
                        if (context.mounted) {
                          setDialogState(() {
                            saving = false;
                            error = e.message;
                          });
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.tr('Save')),
            ),
          ],
        ),
      ),
    );
    name.dispose();
  }

  List<Widget> _results(BuildContext context, SearchState state) {
    if (state.keyword.trim().isEmpty) {
      return [
        PageState(
          variant: PageStateVariant.empty,
          icon: LucideIcons.search,
          compact: true,
          title: state.mode == SearchMode.jobs
              ? 'Search for a role'
              : 'Search for talent',
          description: 'Results appear as you type.',
        ),
      ];
    }

    if (state.error case final error?) {
      return [
        PageState(
          variant: PageStateVariant.error,
          title: 'That search could not run',
          description: error,
          actionLabel: 'Try again',
          onAction: () => ref.read(searchProvider.notifier).run(),
        ),
      ];
    }

    if (state.isSearching && state.isEmpty) {
      return [for (var i = 0; i < 3; i++) const FeedProfileCardSkeleton()];
    }

    if (state.isEmpty) {
      return [
        PageState(
          variant: PageStateVariant.empty,
          icon: LucideIcons.searchX,
          compact: true,
          title: 'Nothing matched',
          description: 'Try a different word, or fewer of them.',
        ),
      ];
    }

    // Saved and pending state live on the feed, so a save made here shows
    // there too. Only a company searches talent, so only it needs the feed.
    final feed =
        state.mode == SearchMode.talent ? ref.watch(feedProvider).value : null;

    return [
      if (state.usedFallback) const _FallbackNotice(),
      _ResultCount(state: state),
      if (state.mode == SearchMode.jobs)
        for (final job in state.jobs)
          JobCard(
            key: ValueKey('job-${job.id}'),
            job: job,
            onTap: () => context.router.push(JobDetailRoute(jobId: job.id)),
          )
      else
        for (final person in state.talent)
          FeedProfileCard(
            key: ValueKey('talent-${person.id}'),
            profile: person,
            saved: feed?.isSaved(person.id) ?? false,
            busy: feed?.isPending(person.id) ?? false,
            onTap: () => openFeedProfile(context, ref, person),
            onSave: () => saveFeedProfile(context, ref, person),
            onView: () => openFeedProfile(context, ref, person),
          ),
      if (state.isLoadingMore) const FeedProfileCardSkeleton(),
    ];
  }
}

/// Narrowing is opt-in, and the label says what it actually does.
class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.state, required this.onChanged});

  final SearchState state;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      elevation: SurfaceElevation.xs,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Only my career scopes'),
                  style: AppTypography.label.copyWith(color: t.foreground),
                ),
                const SizedBox(height: 2),
                Text(
                  // Not "semantically similar scopes": none of the career
                  // scopes carry embeddings, so the API's similarity branch
                  // never matches and only an identical name does. Promising
                  // more than exact matching would be a lie the results then
                  // quietly contradict.
                  context.tr('Matches scope names exactly'),
                  style: AppTypography.tiny.copyWith(
                    color: t.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: state.isNarrowed, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// The API narrowed, found nothing, and retried without the filter. Saying so
/// is the whole point: results that look narrowed but are not would be acted
/// on as if they were.
class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Not a PageState: those are for an empty or failed page, and this sits
    // above results that did arrive.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        elevation: SurfaceElevation.xs,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.info, size: 16, color: t.mutedForeground),
            const SizedBox(width: AppShape.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Nothing in your career scopes'),
                    style: AppTypography.label.copyWith(color: t.foreground),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(
                        'Showing every match instead, so these are not narrowed.'),
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final noun = state.mode == SearchMode.jobs ? 'role' : 'candidate';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space2),
      child: Text(
        context.tr(state.total == 1 ? '1 $noun' : '${state.total} ${noun}s'),
        style: AppTypography.tiny.copyWith(color: t.mutedForeground),
      ),
    );
  }
}
