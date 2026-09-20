import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/match_meter.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.job});

  final SampleJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(title: Text(job.company)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShape.screenPadding,
                  vertical: AppShape.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppAvatar(
                                name: job.company,
                                size: AppAvatarSize.lg,
                                squared: true,
                              ),
                              const SizedBox(width: AppShape.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: AppTypography.h4.copyWith(
                                        color: t.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.company,
                                      style: AppTypography.small.copyWith(
                                        color: t.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppShape.space3),
                          Wrap(
                            spacing: AppShape.space4,
                            runSpacing: AppShape.space2,
                            children: [
                              MetaChip(
                                icon: LucideIcons.mapPin,
                                label: job.location,
                              ),
                              MetaChip(
                                icon: LucideIcons.briefcase,
                                label: job.employmentType,
                              ),
                              MetaChip(
                                icon: LucideIcons.clock,
                                label: job.postedAgo,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppShape.space3),
                          Divider(color: t.border, height: AppShape.hairline),
                          const SizedBox(height: AppShape.space3),
                          MatchMeter(score: job.matchScore),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppShape.space4),
                    const SectionTitle(title: 'Required skills'),
                    const SizedBox(height: AppShape.space3),
                    AppSurface(
                      child: Wrap(
                        spacing: AppShape.space2,
                        runSpacing: AppShape.space2,
                        children: [
                          for (final skill in job.skills) AppTag(label: skill),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppShape.space4),
                    const SectionTitle(title: 'About the role'),
                    const SizedBox(height: AppShape.space3),
                    AppSurface(
                      child: Text(
                        'A job description arrives from the API as plain text a '
                        'company typed. It is rendered with its line breaks '
                        'preserved and never through a markdown renderer — this '
                        'is untrusted input shown to anyone with the link.',
                        style: AppTypography.small.copyWith(
                          color: t.mutedForeground,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppShape.space4),
                  ],
                ),
              ),
            ),

            // Apply Section
            //
            // Pinned rather than scrolled to the bottom of the page: the whole
            // point of this screen is the one action at the end of it.
            Container(
              padding: const EdgeInsets.all(AppShape.screenPadding),
              decoration: BoxDecoration(
                color: t.background,
                border: Border(
                  top: BorderSide(color: t.border, width: AppShape.hairline),
                ),
              ),
              child: Row(
                children: [
                  AppButton.icon(
                    icon: LucideIcons.bookmark,
                    semanticLabel: 'Save this role',
                    variant: AppButtonVariant.outline,
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppShape.space3),
                  Expanded(
                    child: AppButton(
                      label: 'Apply now',
                      fullWidth: true,
                      onPressed: () {},
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
