import 'dart:convert';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:dio/dio.dart';
import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/setting/providers/locale_provider.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final publicContentProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final source =
      jsonDecode(await rootBundle.loadString('assets/public_content.json'))
          as Map;
  return Map<String, dynamic>.from(source['documents'] as Map);
});

final communityStatsProvider =
    FutureProvider<ApiLandingStatsResponseDTO>((ref) async {
  final response = await GatewayApi(ref.watch(apiClientProvider))
      .publicUserControllerGetLandingStats(
          options: Options(extra: SessionInterceptor.publicRequest));
  return ApiLandingStatsResponseDTO.fromJson(
      Map<String, dynamic>.from(response.data as Map));
});

/// The web's exact English/Khmer resource and legal content is bundled locally.
/// Both snapshots are regenerated together by resources:export -- --mobile.
@RoutePage()
class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key, this.document});
  final String? document;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final catalog = ref.watch(publicContentProvider);
    return AppScreen(
        appBar: AppBar(title: Text(context.tr('Help and resources'))),
        children: [
          catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => AppButton(
                  label: 'Try again',
                  onPressed: () => ref.invalidate(publicContentProvider)),
              data: (docs) {
                final selected = docs[document];
                if (selected == null) {
                  return Column(children: [
                    const SectionTitle(title: 'Our community'),
                    ref.watch(communityStatsProvider).when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => AppButton(
                              label: 'Try again',
                              onPressed: () =>
                                  ref.invalidate(communityStatsProvider)),
                          data: (stats) => AppSurface(
                              child: Column(children: [
                            Text('${context.tr('Members')}: ${stats.users}'),
                            Text(
                                '${context.tr('Companies')}: ${stats.companies}'),
                            Text('${context.tr('Talent')}: ${stats.employees}'),
                          ])),
                        ),
                    if (ref.watch(authSessionProvider).value?.isAuthenticated !=
                        true)
                      AppButton(
                          label: 'Create account',
                          onPressed: () =>
                              context.router.push(const SignupRoleRoute())),
                    for (final entry in docs.entries)
                      ListTile(
                          title: Text('${entry.value[locale]['pageTitle']}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ResourcesScreen(document: entry.key)))),
                  ]);
                }
                final content =
                    Map<String, dynamic>.from(selected[locale] as Map);
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${content['pageTitle']}',
                          style: Theme.of(context).textTheme.headlineMedium),
                      ..._render(context, content),
                      if (document == 'terms' || document == 'privacy') ...[
                        AppButton(
                            label: document == 'terms'
                                ? 'Privacy Policy'
                                : 'Terms of Service',
                            variant: AppButtonVariant.outline,
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => ResourcesScreen(
                                        document: document == 'terms'
                                            ? 'privacy'
                                            : 'terms')))),
                        AppButton(
                            label: 'Contact us',
                            onPressed: () => _email(
                                context,
                                document == 'terms'
                                    ? 'legal@apsaratalent.com'
                                    : 'privacy@apsaratalent.com')),
                      ],
                      if (document == 'support') ...[
                        AppButton(
                            label: 'Email support',
                            onPressed: () =>
                                _email(context, 'support@apsaratalent.com')),
                        AppButton(
                            label: 'Report a problem',
                            variant: AppButtonVariant.outline,
                            onPressed: () => context.router.push(ref
                                        .read(authSessionProvider)
                                        .value
                                        ?.isAuthenticated ==
                                    true
                                ? const SupportReportRoute()
                                : const LoginRoute())),
                      ],
                    ]);
              }),
        ]);
  }

  List<Widget> _render(BuildContext context, dynamic value, {String key = ''}) {
    if (value is String) {
      if (value.trim().isEmpty) return [];
      return [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SelectableText(value,
                style: key.toLowerCase().endsWith('title') ||
                        key.endsWith('Heading')
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.bodyMedium))
      ];
    }
    if (value is List) {
      return [for (final item in value) ..._render(context, item)];
    }
    if (value is Map) {
      if (value['q'] is String && value['a'] is String) {
        return [
          ExpansionTile(title: Text(value['q'] as String), children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(value['a'] as String)),
          ])
        ];
      }
      const navigation = {
        'back',
        'pageTitle',
        'toc',
        'tocHeading',
        'id',
        'statSections',
        'statUpdated',
        'statReading',
        'readingTime'
      };
      return [
        for (final entry in value.entries)
          if (!navigation.contains(entry.key))
            ..._render(context, entry.value, key: '${entry.key}')
      ];
    }
    return [];
  }

  Future<void> _email(BuildContext context, String email) async {
    bool opened;
    try {
      opened = await launchUrl(Uri(scheme: 'mailto', path: email));
    } on PlatformException {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(email)));
    }
  }
}
