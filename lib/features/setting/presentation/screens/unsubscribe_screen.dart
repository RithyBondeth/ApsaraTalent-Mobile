import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/setting/providers/notification_preferences_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UnsubscribeScreen extends ConsumerStatefulWidget {
  const UnsubscribeScreen({super.key, @QueryParam('token') this.token = ''});
  final String token;
  @override
  ConsumerState<UnsubscribeScreen> createState() => _UnsubscribeScreenState();
}

class _UnsubscribeScreenState extends ConsumerState<UnsubscribeScreen> {
  bool _busy = false, _done = false;
  String? _error;
  Future<void> _unsubscribe() async {
    if (_busy || widget.token.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await GatewayApi(ref.read(apiClientProvider))
          .notificationPreferenceControllerUnsubscribe(
              body: ApiUnsubscribeBodyDTO(token: widget.token),
              options: Options(extra: SessionInterceptor.publicRequest));
      ref.invalidate(notificationPreferencesProvider);
      if (mounted) setState(() => _done = true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'Could not unsubscribe. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppScreen(
          appBar: AppBar(title: Text(context.tr('Email preferences'))),
          children: [
            if (widget.token.isEmpty) ...[
              Text(context.tr('This unsubscribe link is invalid.')),
              Text(context.tr(
                  'Open the link from the email footer to manage this subscription.')),
            ] else if (_done) ...[
              Text(context.tr('You have unsubscribed.')),
              Text(context.tr(
                  'You can turn these emails back on in notification settings.')),
              AppButton(
                  label: 'Manage notification settings',
                  onPressed: () => context.router
                      .push(const NotificationPreferencesRoute())),
            ] else ...[
              Text(context.tr('Unsubscribe from these emails?')),
              Text(context.tr(
                  'Confirm to stop this email category. Security and account emails stay enabled.')),
              if (_error != null) Text(context.tr(_error!)),
              AppButton(
                  label: 'Unsubscribe',
                  loading: _busy,
                  onPressed: _busy ? null : _unsubscribe),
            ],
          ]);
}
