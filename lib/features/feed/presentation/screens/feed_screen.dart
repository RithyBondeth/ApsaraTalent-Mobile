import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/company_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/job_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final Set<String> _savedJobs = {};

  @override
  Widget build(BuildContext context) {
    // Who is signed in comes from the session; the feed content below is still
    // SampleData until the feed has a data layer.
    final user = ref.watch(authSessionProvider).value?.user;
    final unread =
        SampleData.notifications.where((n) => n.unread).length;

    return AppScreen(
      appBar: AppHeader(
        name: user?.displayName ?? 'Your account',
        subtitle: user?.headline ?? '',
        avatarUrl: user?.avatarUrl,
        unreadCount: unread,
        onProfileTap: () => context.router.push(const ProfileRoute()),
        onNotificationsTap: () =>
            context.router.push(const NotificationRoute()),
      ),
      onRefresh: () async {
        // No API layer yet — see SampleData. This exists so the gesture is
        // wired the moment there is something to refetch.
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      children: [
        // The banner's stats are the counts this page has already loaded.
        // Nothing here is awaiting a fetch, so they can be passed on first
        // paint; a page that fetches must withhold them until the data lands
        // rather than flashing a placeholder zero.
        PageBanner(
          eyebrow: 'Your feed',
          title: 'Roles picked for what you actually do',
          subtitle:
              'Matches are ranked against the skills and career scopes on your '
              'profile, not against your job title.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.sparkles,
              value: '${SampleData.jobs.length}',
              label: 'new matches',
            ),
            PageBannerStat(
              icon: LucideIcons.building2,
              value: '${SampleData.companies.length}',
              label: 'companies',
            ),
            PageBannerStat(
              icon: LucideIcons.send,
              value: '${SampleData.applications.length}',
              label: 'in flight',
            ),
          ],
        ),

        SectionTitle(
          title: 'Recommended roles',
          subtitle: 'Ranked by how closely they match your profile',
          actionLabel: 'Search',
          onAction: () => context.tabsRouter.setActiveIndex(1),
        ),

        for (final job in SampleData.jobs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppShape.space3),
            child: JobCard(
              job: job,
              saved: _savedJobs.contains(job.title),
              onSave: () => setState(() {
                _savedJobs.contains(job.title)
                    ? _savedJobs.remove(job.title)
                    : _savedJobs.add(job.title);
              }),
              onTap: () => context.router.push(JobDetailRoute(job: job)),
            ),
          ),

        const SectionTitle(
          title: 'Companies hiring now',
          subtitle: 'Open roles matching your career scope',
        ),

        for (final company in SampleData.companies)
          Padding(
            padding: const EdgeInsets.only(bottom: AppShape.space3),
            child: CompanyCard(company: company),
          ),
      ],
    );
  }
}
