import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/features/admin/presentation/admin_widgets.dart';
import 'package:apsaratalent_mobile/features/admin/providers/admin_provider.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUserScreen extends ConsumerStatefulWidget {
  const AdminUserScreen({super.key, required this.userId});
  final String userId;
  @override
  ConsumerState<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends ConsumerState<AdminUserScreen> {
  Future<ApiAdminUserDetailDTO>? _data;
  Object? _error;
  bool _saving = false;
  void _reload() => setState(
      () => _data = ref.read(adminRepositoryProvider).user(widget.userId));
  Future<void> _refresh() async {
    _reload();
    await _data;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    if (session.isLoading) {
      return const AppScreen(
          children: [Center(child: CircularProgressIndicator())]);
    }
    final actor = session.value?.user;
    if (actor?.role != EUserRole.admin) {
      return const AppScreen(children: [AdminAccessDenied()]);
    }
    _data ??= ref.read(adminRepositoryProvider).user(widget.userId);
    return AppScreen(
        appBar: AppBar(title: Text(context.tr('Account details'))),
        onRefresh: _refresh,
        children: [
          if (_error != null)
            AdminError(
                error: _error!, onRetry: () => setState(() => _error = null)),
          FutureBuilder<ApiAdminUserDetailDTO>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return AdminError(error: snapshot.error!, onRetry: _reload);
                }
                final user = snapshot.data!;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppAvatar(name: user.name, imageUrl: user.avatar),
                      Text(user.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                          '${adminLabel(context, user.role)} · ${adminLabel(context, user.status)}'),
                      AdminFacts(data: user.toJson(), fields: const {
                        'id': 'User ID',
                        'email': 'Email',
                        'phone': 'Phone',
                        'isEmailVerified': 'Email verified',
                        'profileCompleted': 'Profile complete',
                        'storedStatus': 'Stored account status',
                        'suspendedUntil': 'Suspended until',
                        'statusReason': 'Reason',
                        'createdAt': 'Created',
                        'lastLoginAt': 'Last login',
                        'lastLoginMethod': 'Login method',
                        'openReportCount': 'Open reports'
                      }),
                      const SizedBox(height: 16),
                      if (user.id != actor?.id && user.role != 'admin')
                        AppButton(
                            label: 'Change account status',
                            loading: _saving,
                            onPressed: _saving
                                ? null
                                : () async {
                                    final decision = await showAdminDecision(
                                        context,
                                        title: 'Change account status',
                                        initialStatus: user.status,
                                        statuses: const [
                                          'active',
                                          'suspended',
                                          'banned'
                                        ],
                                        reasonRequired: true,
                                        allowSuspension: true);
                                    if (decision == null || !mounted) return;
                                    setState(() {
                                      _saving = true;
                                      _error = null;
                                    });
                                    try {
                                      await ref
                                          .read(adminRepositoryProvider)
                                          .updateUser(user.id,
                                              status: decision.status,
                                              reason: decision.note,
                                              suspendedUntil: decision.until);
                                      if (mounted) _reload();
                                    } catch (error) {
                                      if (mounted) {
                                        setState(() => _error = error);
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _saving = false);
                                      }
                                    }
                                  }),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Reports against this account'),
                      if (user.reportsAgainst.isEmpty)
                        Text(context.tr('No reports against this account.')),
                      for (final report in user.reportsAgainst)
                        AppSurface(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  '${adminLabel(context, report.reason)} · ${adminLabel(context, report.status)}'),
                              if (report.details != null) Text(report.details!),
                              if (report.reporter != null)
                                AdminParty(
                                    label: 'Reporter', party: report.reporter!),
                              AdminFacts(
                                  data: report.toJson(),
                                  fields: const {'createdAt': 'Created'}),
                            ])),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Status history'),
                      if (user.statusHistory.isEmpty)
                        Text(context.tr('No status changes yet.')),
                      for (final entry in user.statusHistory)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AdminAuditCard(entry: entry.toJson())),
                    ]);
              }),
        ]);
  }
}
