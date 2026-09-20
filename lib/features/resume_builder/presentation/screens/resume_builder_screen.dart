import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class ResumeBuilderScreen extends ConsumerWidget {
  const ResumeBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final viewer = SampleData.viewer;

    return AppScreen(
      children: [
        const PageBanner(
          eyebrow: 'Resume builder',
          title: 'Build a resume from your profile',
          subtitle:
              'Sections are drafted from what is already on your profile, then '
              'edited here before export.',
        ),

        // AI Section
        //
        // The primary-tinted surface plus accent edge is one of the few
        // sanctioned uses of the colour: it marks generated content, so a
        // reader can tell at a glance what a model wrote from what they did.
        AppSurface(
          accent: SurfaceAccent.primary,
          accentEdge: SurfaceAccentEdge.left,
          accentWidth: AppShape.accentInline,
          color: t.primary.withValues(alpha: 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.sparkles, size: 18, color: t.primary),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draft a summary from your profile',
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppShape.space1),
                    Text(
                      'Generated text is marked so you can tell it apart from '
                      'what you wrote.',
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppShape.space3),
                    AppButton(
                      label: 'Generate',
                      icon: LucideIcons.wandSparkles,
                      size: AppButtonSize.sm,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SectionTitle(
          title: 'Sections',
          subtitle: 'Tap a section to edit it',
        ),

        _ResumeSection(
          icon: LucideIcons.user,
          title: 'Personal details',
          summary: '${viewer.name} · ${viewer.location}',
          complete: true,
        ),
        _ResumeSection(
          icon: LucideIcons.fileText,
          title: 'Summary',
          summary: 'Not written yet',
          complete: false,
        ),
        _ResumeSection(
          icon: LucideIcons.briefcase,
          title: 'Work history',
          summary: 'Not written yet',
          complete: false,
        ),
        _ResumeSection(
          icon: LucideIcons.graduationCap,
          title: 'Education',
          summary: 'Not written yet',
          complete: false,
        ),
        _ResumeSection(
          icon: LucideIcons.wrench,
          title: 'Skills',
          summary: '${viewer.skills.length} skills',
          complete: true,
        ),

        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Preview resume',
          icon: LucideIcons.eye,
          variant: AppButtonVariant.outline,
          fullWidth: true,
          onPressed: () {},
        ),
        const SizedBox(height: AppShape.space6),
      ],
    );
  }
}

class _ResumeSection extends StatelessWidget {
  const _ResumeSection({
    required this.icon,
    required this.title,
    required this.summary,
    required this.complete,
  });

  final IconData icon;
  final String title;
  final String summary;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      onTap: () {},
      elevation: SurfaceElevation.sm,
      margin: const EdgeInsets.only(bottom: AppShape.space2),
      padding: const EdgeInsets.all(AppShape.space3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: t.mutedForeground),
          const SizedBox(width: AppShape.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(color: t.foreground),
                ),
                const SizedBox(height: 1),
                Text(
                  summary,
                  style: AppTypography.tiny.copyWith(color: t.mutedForeground),
                ),
              ],
            ),
          ),
          if (complete)
            const AppStatusPill(
              status: AppStatus.success,
              label: 'Done',
            )
          else
            Icon(LucideIcons.chevronRight, size: 16, color: t.mutedForeground),
        ],
      ),
    );
  }
}
