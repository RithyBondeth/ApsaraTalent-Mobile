import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/setting/providers/account_settings_provider.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ProfilePrivacyScreen extends ConsumerWidget {
  const ProfilePrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profilePrivacyProvider);
    return AppScreen(
      appBar: AppBar(title: Text(context.tr('Profile privacy'))),
      onRefresh: () => ref.read(profilePrivacyProvider.notifier).refresh(),
      children: [
        const PageBanner(
          eyebrow: 'Privacy',
          title: 'Control how you browse',
          subtitle:
              'Choose whether your identity appears when you view other profiles.',
        ),
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error is ApiException
                ? error.message
                : 'Could not load privacy settings.',
            onRetry: () => ref.invalidate(profilePrivacyProvider),
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSurface(
                child: Row(children: [
                  Icon(LucideIcons.eyeOff,
                      color: context.tokens.mutedForeground),
                  const SizedBox(width: AppShape.space3),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Browse privately'),
                          style: AppTypography.label
                              .copyWith(color: context.tokens.foreground)),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(data.browsePrivately
                            ? 'Other members will not see your identity in their profile viewers.'
                            : 'Other members may see that you viewed their profile.'),
                        style: AppTypography.tiny
                            .copyWith(color: context.tokens.mutedForeground),
                      ),
                    ],
                  )),
                  Switch(
                    value: data.browsePrivately,
                    onChanged: (value) async {
                      try {
                        await ref
                            .read(profilePrivacyProvider.notifier)
                            .setPrivate(value);
                      } on ApiException catch (error) {
                        if (context.mounted) _message(context, error.message);
                      }
                    },
                  ),
                ]),
              ),
              const SizedBox(height: AppShape.space4),
              const SectionTitle(title: 'Your visibility'),
              Row(children: [
                Expanded(
                    child: _Metric(
                        value: data.profileViews7d, label: 'Views · 7 days')),
                const SizedBox(width: AppShape.space3),
                Expanded(
                    child: _Metric(
                        value: data.profileViews30d, label: 'Views · 30 days')),
              ]),
              const SizedBox(height: AppShape.space3),
              _Metric(
                  value: data.searchAppearances30d,
                  label: 'Search appearances · 30 days'),
              const SizedBox(height: AppShape.space4),
              const SectionTitle(title: 'Recent viewers'),
              if (data.recentViewers.isEmpty)
                AppSurface(
                    child: Text(context.tr('No recent profile viewers yet.'),
                        style: AppTypography.small
                            .copyWith(color: context.tokens.mutedForeground)))
              else
                AppSurface(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    for (var i = 0; i < data.recentViewers.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(AppShape.space4),
                        child: Row(children: [
                          AppAvatar(
                              name: data.recentViewers[i].name,
                              imageUrl: data.recentViewers[i].avatarUrl),
                          const SizedBox(width: AppShape.space3),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(data.recentViewers[i].name,
                                    style: AppTypography.label.copyWith(
                                        color: context.tokens.foreground)),
                                if (data.recentViewers[i].role case final role?)
                                  Text(role,
                                      style: AppTypography.tiny.copyWith(
                                          color:
                                              context.tokens.mutedForeground)),
                              ])),
                          Text(_relativeDate(data.recentViewers[i].viewedAt),
                              style: AppTypography.tiny.copyWith(
                                  color: context.tokens.mutedForeground)),
                        ]),
                      ),
                      if (i != data.recentViewers.length - 1)
                        Divider(height: 1, color: context.tokens.border),
                    ],
                  ]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => AppSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$value',
            style: AppTypography.h3.copyWith(color: context.tokens.foreground)),
        Text(label,
            style: AppTypography.tiny
                .copyWith(color: context.tokens.mutedForeground)),
      ]));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => AppSurface(
          child: Column(children: [
        Text(message,
            textAlign: TextAlign.center,
            style: AppTypography.small
                .copyWith(color: context.tokens.mutedForeground)),
        const SizedBox(height: AppShape.space3),
        AppButton(label: 'Try again', onPressed: onRetry),
      ]));
}

String _relativeDate(DateTime? value) {
  if (value == null) return '';
  final days = DateTime.now().difference(value.toLocal()).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return '$days days ago';
}

void _message(BuildContext context, String value) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
