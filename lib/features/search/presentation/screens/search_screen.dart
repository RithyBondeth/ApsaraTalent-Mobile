import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/company_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/job_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

enum SearchMode { jobs, companies }

@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchMode _mode = SearchMode.jobs;
  String _query = '';

  /// Narrowing results to the viewer's career scope is **opt-in**, and it
  /// defaults off on purpose. The scope embeddings are unbackfilled, so scoped
  /// matching is really exact-string matching — switching it on by default
  /// silently hides results that a reader would expect to see.
  bool _scopeNarrowing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<SampleJob> get _jobs => SampleData.jobs
      .where((j) => _matches('${j.title} ${j.company} ${j.skills.join(' ')}'))
      .toList();

  List<SampleCompany> get _companies => SampleData.companies
      .where((c) => _matches('${c.name} ${c.industry} ${c.location}'))
      .toList();

  bool _matches(String haystack) =>
      _query.isEmpty ||
      haystack.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final showingJobs = _mode == SearchMode.jobs;
    final resultCount = showingJobs ? _jobs.length : _companies.length;

    return AppScreen(
      children: [
        PageBanner(
          eyebrow: 'Search',
          title: showingJobs ? 'Find a role' : 'Find a company',
          subtitle:
              'Search across titles, skills and industries. Results are ranked '
              'by match, not by recency.',
        ),

        AppInput(
          controller: _controller,
          hintText: showingJobs
              ? 'Role, skill or company'
              : 'Company or industry',
          prefixIcon: LucideIcons.search,
          suffixIcon: _query.isEmpty ? null : LucideIcons.x,
          onSuffixTap: () {
            _controller.clear();
            setState(() => _query = '');
          },
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
        ),

        // Mode Section
        Row(
          children: [
            Expanded(
              child: _ModeTab(
                label: 'Jobs',
                icon: LucideIcons.briefcase,
                selected: showingJobs,
                onTap: () => setState(() => _mode = SearchMode.jobs),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: _ModeTab(
                label: 'Companies',
                icon: LucideIcons.building2,
                selected: !showingJobs,
                onTap: () => setState(() => _mode = SearchMode.companies),
              ),
            ),
          ],
        ),

        // Scope Section
        AppSurface(
          elevation: SurfaceElevation.xs,
          padding: const EdgeInsets.symmetric(
            horizontal: AppShape.space3,
            vertical: AppShape.space2,
          ),
          child: Row(
            children: [
              Icon(LucideIcons.filter, size: 16, color: t.mutedForeground),
              const SizedBox(width: AppShape.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Narrow to my career scope',
                      style: AppTypography.tag.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Off by default — narrowing can hide near matches',
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _scopeNarrowing,
                onChanged: (value) => setState(() => _scopeNarrowing = value),
              ),
            ],
          ),
        ),

        Row(
          children: [
            Text(
              resultCount == 1 ? '1 result' : '$resultCount results',
              style: AppTypography.tiny.copyWith(color: t.mutedForeground),
            ),
          ],
        ),

        if (resultCount == 0)
          PageState(
            variant: PageStateVariant.empty,
            // A glyph that names *this* absence. Every empty state sharing one
            // inbox icon is how "no messages", "no interviews" and "no results"
            // become indistinguishable at a glance.
            icon: LucideIcons.searchX,
            title: 'Nothing matched "$_query"',
            description: showingJobs
                ? 'Try a broader term, or search by a skill rather than a job '
                    'title.'
                : 'Try an industry rather than a company name.',
            actionLabel: 'Clear search',
            onAction: () {
              _controller.clear();
              setState(() => _query = '');
            },
          )
        else if (showingJobs)
          for (final job in _jobs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space3),
              child: JobCard(
                job: job,
                onTap: () => context.router.push(JobDetailRoute(job: job)),
              ),
            )
        else
          for (final company in _companies)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space3),
              child: CompanyCard(company: company),
            ),
      ],
    );
  }
}

/// A segmented control. Square, and the selected half is a filled-primary tile
/// casting its own hue — the same treatment as the active nav item.
class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final foreground = selected ? t.primaryForeground : t.foreground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: AppShape.controlHeightSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? t.primary : t.background,
          border: Border.all(
            color: selected ? t.primary : t.input,
            width: AppShape.hairline,
          ),
          boxShadow: selected ? context.elevation.primaryXs : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppShape.space2),
            Text(
              label,
              style: AppTypography.button.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
