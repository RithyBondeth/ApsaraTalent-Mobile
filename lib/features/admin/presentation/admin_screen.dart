import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/features/admin/data/admin_repository.dart';
import 'package:apsaratalent_mobile/features/admin/providers/admin_provider.dart';
import 'package:apsaratalent_mobile/features/admin/presentation/admin_user_screen.dart';
import 'package:apsaratalent_mobile/features/admin/presentation/admin_widgets.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  AdminSection _section = AdminSection.overview;
  Future<Object>? _data;
  final _search = TextEditingController();
  final _target = TextEditingController();
  String? _role, _status, _category;
  String _visibility = 'visible';
  int _page = 1;
  bool _saving = false;
  Object? _actionError;
  @override
  void dispose() {
    _search.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<Object> _load() {
    final repository = ref.read(adminRepositoryProvider);
    return _section == AdminSection.overview
        ? repository.overview()
        : repository.list(_section,
            page: _page,
            search: _search.text,
            role: _role,
            status: _status,
            category: _category,
            visibility: _visibility,
            targetUserId: _target.text);
  }

  void _reload({bool resetPage = false}) {
    setState(() {
      if (resetPage) _page = 1;
      _data = _load();
    });
  }

  Future<void> _refresh() async {
    _reload();
    await _data;
  }

  void _select(AdminSection section) {
    setState(() {
      _section = section;
      _page = 1;
      _status = null;
      _role = null;
      _category = null;
      _visibility = 'visible';
      _search.clear();
      _target.clear();
      _actionError = null;
      _data = _load();
    });
  }

  Future<void> _mutate(Future<void> Function() action) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _actionError = null;
    });
    try {
      await action();
      if (mounted) _reload();
    } catch (error) {
      if (mounted) setState(() => _actionError = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    if (session.isLoading) {
      return const AppScreen(
          children: [Center(child: CircularProgressIndicator())]);
    }
    final user = session.value?.user;
    if (user?.role != EUserRole.admin) {
      return const AppScreen(children: [AdminAccessDenied()]);
    }
    _data ??= _load();
    return AppScreen(
      appBar: AppBar(title: Text(context.tr('Administration')), actions: [
        IconButton(
            tooltip: context.tr('Settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.push(const SettingRoute())),
      ]),
      onRefresh: _refresh,
      children: [
        const PageBanner(
            eyebrow: 'Administration',
            title: 'Platform management',
            subtitle:
                'Manage accounts, review reports and keep the platform safe.'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final section in AdminSection.values)
            ChoiceChip(
                label: Text(context.tr(section.label)),
                selected: _section == section,
                onSelected: _saving ? null : (_) => _select(section)),
        ]),
        if (_section == AdminSection.users || _section == AdminSection.jobs)
          AppInput(
              controller: _search,
              labelText: context.tr('Search'),
              hintText: context.tr(_section == AdminSection.users
                  ? 'Email or phone'
                  : 'Job title or company'),
              onSubmitted: (_) => _reload(resetPage: true),
              suffixIcon: Icons.search,
              onSuffixTap: () => _reload(resetPage: true)),
        if (_section == AdminSection.audit)
          AppInput(
              controller: _target,
              labelText: context.tr('Target user ID (optional)'),
              onSubmitted: (_) => _reload(resetPage: true),
              suffixIcon: Icons.search,
              onSuffixTap: () => _reload(resetPage: true)),
        if (_section == AdminSection.users) ...[
          AdminFilter(
              label: 'Role',
              value: _role,
              values: const ['employee', 'company', 'admin'],
              onChanged: (v) {
                _role = v;
                _reload(resetPage: true);
              }),
          AdminFilter(
              label: 'Account status',
              value: _status,
              values: const ['active', 'suspended', 'banned'],
              onChanged: (v) {
                _status = v;
                _reload(resetPage: true);
              }),
        ],
        if (_section == AdminSection.jobs)
          AdminFilter(
              label: 'Visibility',
              value: _visibility,
              allowAll: false,
              values: const ['visible', 'hidden', 'all'],
              onChanged: (v) {
                _visibility = v!;
                _reload(resetPage: true);
              }),
        if (_section == AdminSection.reports ||
            _section == AdminSection.problems)
          AdminFilter(
              label: 'Report status',
              value: _status,
              values: const ['pending', 'reviewed', 'resolved', 'dismissed'],
              onChanged: (v) {
                _status = v;
                _reload(resetPage: true);
              }),
        if (_section == AdminSection.problems)
          AdminFilter(
              label: 'Category',
              value: _category,
              values: const ['bug', 'account', 'payment', 'content', 'other'],
              onChanged: (v) {
                _category = v;
                _reload(resetPage: true);
              }),
        if (_actionError != null)
          AdminError(
              error: _actionError!,
              onRetry: () {
                setState(() => _actionError = null);
              }),
        FutureBuilder<Object>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AdminError(error: snapshot.error!, onRetry: _reload);
              }
              if (_section == AdminSection.overview) {
                final data = snapshot.data! as Map<String, dynamic>;
                const labels = {
                  'totalUsers': 'Total users',
                  'employees': 'Candidates',
                  'companies': 'Companies',
                  'suspendedUsers': 'Suspended accounts',
                  'bannedUsers': 'Banned accounts',
                  'pendingReports': 'Pending reports',
                  'newUsersLast7Days': 'New users · 7 days',
                  'liveJobs': 'Live jobs',
                  'hiddenJobs': 'Hidden jobs'
                };
                return Column(children: [
                  for (final entry in labels.entries)
                    ListTile(
                        title: Text(context.tr(entry.value)),
                        trailing: Text('${data[entry.key] ?? '—'}'))
                ]);
              }
              final page = snapshot.data! as AdminPage;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (page.items.isEmpty)
                      Text(context.tr('No results for these filters.')),
                    for (final row in page.items)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _row(row)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('Page {page} · {total} results',
                              {'page': page.page, 'total': page.total})),
                          IconButton(
                              tooltip: context.tr('Previous page'),
                              icon: const Icon(Icons.chevron_left),
                              onPressed: !_saving && _page > 1
                                  ? () {
                                      _page--;
                                      _reload();
                                    }
                                  : null),
                          IconButton(
                              tooltip: context.tr('Next page'),
                              icon: const Icon(Icons.chevron_right),
                              onPressed: !_saving && page.hasNext
                                  ? () {
                                      _page++;
                                      _reload();
                                    }
                                  : null),
                        ]),
                  ]);
            }),
      ],
    );
  }

  Widget _row(Map<String, dynamic> row) {
    switch (_section) {
      case AdminSection.users:
        return AppSurface(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) =>
                      AdminUserScreen(userId: row['id'] as String)));
              if (mounted) _reload();
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${row['name']}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('${row['email'] ?? row['phone'] ?? ''}'),
              Text(
                  '${adminLabel(context, row['role'])} · ${adminLabel(context, row['status'])}'),
              Text(context.tr(
                  '{count} open reports', {'count': row['openReportCount']})),
              Text(context.tr('View account details')),
            ]));
      case AdminSection.jobs:
        final hidden = row['hiddenAt'] != null;
        return AppSurface(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text('${row['title']}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('${row['companyName']} · ${row['location'] ?? ''}'),
              AdminFacts(data: row, fields: const {
                'type': 'Job type',
                'createdAt': 'Created',
                'expireDate': 'Expires',
                'hiddenAt': 'Hidden at',
                'hiddenReason': 'Reason',
                'companyOpenReportCount': 'Company open reports'
              }),
              AppButton(
                  label: hidden ? 'Restore posting' : 'Hide posting',
                  loading: _saving,
                  onPressed: _saving
                      ? null
                      : () async {
                          if (hidden) {
                            if (await adminConfirm(context, 'Restore posting',
                                    '${row['title']}') &&
                                mounted) {
                              await _mutate(() => ref
                                  .read(adminRepositoryProvider)
                                  .restoreJob(row['id'] as String));
                            }
                          } else {
                            final decision = await showAdminDecision(context,
                                title: 'Hide posting',
                                initialStatus: 'hidden',
                                statuses: const ['hidden'],
                                reasonRequired: true);
                            if (decision != null && mounted) {
                              await _mutate(() => ref
                                  .read(adminRepositoryProvider)
                                  .hideJob(row['id'] as String, decision.note));
                            }
                          }
                        }),
            ]));
      case AdminSection.reports:
      case AdminSection.problems:
        final problem = _section == AdminSection.problems;
        return AppSurface(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text(adminLabel(context, row[problem ? 'category' : 'reason']),
                  style: Theme.of(context).textTheme.titleMedium),
              Text(adminLabel(context, row['status'])),
              if (row['details'] != null) Text('${row['details']}'),
              if (row['reporter'] is Map)
                AdminParty(
                    label: 'Reporter',
                    party: Map<String, dynamic>.from(row['reporter'] as Map)),
              if (row['reported'] is Map)
                AdminParty(
                    label: 'Reported account',
                    party: Map<String, dynamic>.from(row['reported'] as Map),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => AdminUserScreen(
                                userId: (row['reported'] as Map)['id']
                                    as String)))),
              AdminFacts(data: row, fields: const {
                'createdAt': 'Created',
                'pageUrl': 'Page URL',
                'userAgent': 'User agent',
                'resolutionNote': 'Resolution note'
              }),
              AppButton(
                  label: 'Update report',
                  loading: _saving,
                  onPressed: _saving
                      ? null
                      : () async {
                          final decision = await showAdminDecision(context,
                              title: 'Update report',
                              initialStatus: row['status'] as String,
                              statuses: const [
                                'pending',
                                'reviewed',
                                'resolved',
                                'dismissed'
                              ]);
                          if (decision != null && mounted) {
                            await _mutate(() => ref
                                .read(adminRepositoryProvider)
                                .updateReport(row['id'] as String,
                                    problem: problem,
                                    status: decision.status,
                                    note: decision.note));
                          }
                        }),
            ]));
      case AdminSection.audit:
        return AdminAuditCard(entry: row);
      case AdminSection.overview:
        return const SizedBox.shrink();
    }
  }
}
