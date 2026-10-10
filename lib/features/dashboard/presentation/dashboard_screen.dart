import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/setting/providers/account_settings_provider.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final profile = ref.watch(profileProvider).value;
    final visibility = ref.watch(profilePrivacyProvider);
    final employer =
        ref.watch(authSessionProvider).value?.user?.role == EUserRole.company;
    return AppScreen(
        appBar: AppBar(title: Text(context.tr('Dashboard'))),
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          ref.invalidate(profilePrivacyProvider);
          await ref.read(dashboardProvider.future);
        },
        children: [
          const PageBanner(
              eyebrow: 'Dashboard',
              title: 'Your activity at a glance',
              subtitle:
                  'See your matches, saved profiles and activity over the last week.'),
          if (profile != null)
            AppSurface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text(context.tr('Profile completeness')),
                  LinearProgressIndicator(
                      value: profile.completion.percent / 100),
                  Text('${profile.completion.percent}%'),
                  for (final field in profile.completion.missing)
                    Text(context.tr(field)),
                  AppButton(
                      label: 'Edit profile',
                      onPressed: () =>
                          context.router.push(const ProfileEditRoute())),
                ])),
          async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppSurface(
                      child: Column(children: [
                    Text(context.tr(error is ApiException
                        ? error.message
                        : 'Could not load your dashboard.')),
                    AppButton(
                        label: 'Try again',
                        onPressed: () => ref.invalidate(dashboardProvider)),
                  ])),
              data: (data) => data == null
                  ? Text(context.tr('Complete your account to view activity.'))
                  : _Activity(data: data)),
          const SectionTitle(title: 'Profile visibility'),
          visibility.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => AppButton(
                  label: 'Try again',
                  onPressed: () => ref.invalidate(profilePrivacyProvider)),
              data: (data) => AppSurface(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        _metric(context, 'Views · 7 days', data.profileViews7d),
                        _metric(
                            context, 'Views · 30 days', data.profileViews30d),
                        _metric(context, 'Search appearances · 30 days',
                            data.searchAppearances30d),
                        const SectionTitle(title: 'Recent viewers'),
                        if (data.recentViewers.isEmpty)
                          Text(context.tr('No recent profile viewers yet.')),
                        for (final viewer in data.recentViewers)
                          ListTile(
                              leading: AppAvatar(
                                  name: viewer.name,
                                  imageUrl: viewer.avatarUrl),
                              title: Text(context.tr(viewer.name)),
                              subtitle: Text(_date(context,
                                  viewer.viewedAt?.toIso8601String() ?? ''))),
                        AppButton(
                            label: 'Profile privacy',
                            variant: AppButtonVariant.outline,
                            onPressed: () => context.router
                                .push(const ProfilePrivacyRoute())),
                      ]))),
          if (employer)
            AppButton(
                label: 'Employer analytics',
                onPressed: () => context.router.push(const ApplicationRoute())),
        ]);
  }
}

class _Activity extends StatelessWidget {
  const _Activity({required this.data});
  final ApiMatchingAnalyticsResponseDTO data;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppSurface(
            child: Column(children: [
          _metric(context, 'Likes given', data.totalLikesGiven),
          _metric(context, 'Likes received', data.totalLikesReceived),
          _metric(context, 'Matches', data.totalMatches),
          _metric(context, 'Saved profiles', data.totalFavorites),
          _metric(context, 'Match rate', '${data.matchRate}%'),
        ])),
        const SizedBox(height: 16),
        const SectionTitle(title: 'Weekly activity'),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: [
              for (final label in const [
                'Day',
                'Likes given',
                'Likes received',
                'Matches'
              ])
                DataColumn(label: Text(context.tr(label)))
            ], rows: [
              for (final day in data.weeklyActivity)
                DataRow(cells: [
                  DataCell(Text(context.tr(day.day))),
                  DataCell(Text('${day.likes}')),
                  DataCell(Text('${day.received}')),
                  DataCell(Text('${day.matches}')),
                ])
            ])),
        const SizedBox(height: 16),
        const SectionTitle(title: 'Recent matches'),
        if (data.recentMatches.isEmpty) Text(context.tr('No matches yet.')),
        for (final match in data.recentMatches)
          ListTile(
              leading: AppAvatar(name: match.name, imageUrl: match.avatar),
              title: Text(match.name),
              subtitle: Text(_date(context, match.matchedAt))),
        AppButton(
            label: 'View matches',
            variant: AppButtonVariant.outline,
            onPressed: () => context.router.push(const MatchRoute())),
      ]);
}

Widget _metric(BuildContext context, String label, Object value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Expanded(child: Text(context.tr(label))),
      Text('$value', style: Theme.of(context).textTheme.titleMedium),
    ]));
String _date(BuildContext context, String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  return date == null
      ? ''
      : MaterialLocalizations.of(context).formatMediumDate(date);
}
