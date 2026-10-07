import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/setting/providers/account_settings_provider.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});
  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  bool _exporting = false;
  bool _changingDeletion = false;
  DateTime? _scheduledFor;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final data =
          await ref.read(accountSettingsRepositoryProvider).exportData();
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save your Apsara Talent data',
        fileName: data.fileName,
        bytes: data.bytes,
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (!mounted || saved == null) return;
      _message('Export saved to ${saved.path.isEmpty ? saved : saved.path}.');
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('The export could not be saved. Please try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _requestDeletion() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Schedule account deletion?')),
        content: Text(
          context.tr(
              'Your account stays available for 30 days. After that, it and its associated data will be permanently deleted. You can cancel during the grace period.'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Keep account'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('Schedule deletion'))),
        ],
      ),
    );
    if (accepted != true) return;
    setState(() => _changingDeletion = true);
    try {
      final result =
          await ref.read(accountSettingsRepositoryProvider).requestDeletion();
      await ref.read(authSessionProvider.notifier).refreshUser();
      if (!mounted) return;
      setState(() => _scheduledFor = result.scheduledFor);
      _message(result.message);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _changingDeletion = false);
    }
  }

  Future<void> _cancelDeletion() async {
    setState(() => _changingDeletion = true);
    try {
      final message =
          await ref.read(accountSettingsRepositoryProvider).cancelDeletion();
      await ref.read(authSessionProvider.notifier).refreshUser();
      if (!mounted) return;
      setState(() => _scheduledFor = null);
      _message(message);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _changingDeletion = false);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final requestedAt =
        ref.watch(authSessionProvider).value?.user?.deletionRequestedAt;
    final scheduled =
        _scheduledFor ?? requestedAt?.add(const Duration(days: 30));
    return AppScreen(
      appBar: AppBar(title: Text(context.tr('Account data'))),
      children: [
        const PageBanner(
          eyebrow: 'Your account',
          title: 'Data and account lifecycle',
          subtitle:
              'Take a copy of your information or manage account deletion.',
        ),
        const SectionTitle(title: 'Data export'),
        AppSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(LucideIcons.download, color: context.tokens.mutedForeground),
          const SizedBox(height: AppShape.space3),
          Text(context.tr('Download your data'),
              style: AppTypography.label
                  .copyWith(color: context.tokens.foreground)),
          const SizedBox(height: AppShape.space1),
          Text(
            context.tr(
                'Creates a JSON file with your profile, applications, interviews, matches, saved items, notifications, support reports, and login history. Exports are limited to once every 24 hours.'),
            style: AppTypography.small
                .copyWith(color: context.tokens.mutedForeground),
          ),
          const SizedBox(height: AppShape.space4),
          AppButton(
              label: 'Create and save export',
              icon: LucideIcons.download,
              fullWidth: true,
              loading: _exporting,
              onPressed: _export),
        ])),
        const SectionTitle(title: 'Account deletion'),
        AppSurface(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              if (scheduled != null) ...[
                Text(context.tr('Deletion scheduled'),
                    style: AppTypography.label
                        .copyWith(color: context.tokens.destructive)),
                const SizedBox(height: AppShape.space2),
                Text(
                  context.tr(
                      "Your account is scheduled for permanent deletion on {0}. You can continue using it and cancel before then.",
                      {'0': _date(scheduled)}),
                  style: AppTypography.small
                      .copyWith(color: context.tokens.mutedForeground),
                ),
                const SizedBox(height: AppShape.space4),
                AppButton(
                    label: 'Cancel account deletion',
                    icon: LucideIcons.undo2,
                    fullWidth: true,
                    loading: _changingDeletion,
                    onPressed: _cancelDeletion),
              ] else ...[
                Text(context.tr('Delete your account'),
                    style: AppTypography.label
                        .copyWith(color: context.tokens.foreground)),
                const SizedBox(height: AppShape.space2),
                Text(
                  context.tr(
                      'Deletion starts a 30-day grace period. You can cancel at any time during that period.'),
                  style: AppTypography.small
                      .copyWith(color: context.tokens.mutedForeground),
                ),
                const SizedBox(height: AppShape.space4),
                AppButton(
                    label: 'Schedule account deletion',
                    icon: LucideIcons.trash2,
                    variant: AppButtonVariant.destructive,
                    fullWidth: true,
                    loading: _changingDeletion,
                    onPressed: _requestDeletion),
              ],
            ])),
      ],
    );
  }
}

String _date(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final local = date.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}
