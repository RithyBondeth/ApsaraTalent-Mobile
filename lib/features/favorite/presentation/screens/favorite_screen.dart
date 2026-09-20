import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/job_card.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  // Seeded from the sample set so the screen has something to show; the real
  // list comes from the API alongside everything else in SampleData.
  late final List<SampleJob> _saved = [...SampleData.jobs.take(2)];

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      appBar: AppBar(title: const Text('Saved')),
      children: [
        PageBanner(
          eyebrow: 'Saved',
          title: 'Roles you bookmarked',
          subtitle: 'Kept here until you apply or remove them.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.bookmark,
              value: '${_saved.length}',
              label: 'saved',
            ),
          ],
        ),

        if (_saved.isEmpty)
          PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.bookmarkX,
            title: 'Nothing saved yet',
            description:
                'Tap the bookmark on any role to keep it here for later.',
            actionLabel: 'Browse the feed',
            onAction: () => context.router.maybePop(),
          )
        else
          for (final job in _saved)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space3),
              child: JobCard(
                job: job,
                saved: true,
                onSave: () => setState(() => _saved.remove(job)),
                onTap: () => context.router.push(JobDetailRoute(job: job)),
              ),
            ),
      ],
    );
  }
}
