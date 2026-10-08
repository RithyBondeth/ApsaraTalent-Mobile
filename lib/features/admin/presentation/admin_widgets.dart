import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const adminLabels = <String, String>{
  'active': 'Active',
  'suspended': 'Suspended',
  'banned': 'Banned',
  'employee': 'Candidate',
  'company': 'Company',
  'admin': 'Administrator',
  'pending': 'Pending',
  'reviewed': 'Reviewed',
  'resolved': 'Resolved',
  'dismissed': 'Dismissed',
  'visible': 'Visible',
  'hidden': 'Hidden',
  'all': 'All',
  'bug': 'App bug',
  'account': 'Account',
  'payment': 'Payment',
  'content': 'Content',
  'other': 'Other',
  'user_suspended': 'Account suspended',
  'user_banned': 'Account banned',
  'user_reinstated': 'Account reinstated',
  'report_status_changed': 'Report status changed',
  'job_hidden': 'Posting hidden',
  'job_restored': 'Posting restored',
  'spam': 'Spam',
  'harassment': 'Harassment',
  'fake_profile': 'Fake profile',
  'inappropriate_content': 'Inappropriate content',
  'scam': 'Scam',
};
String adminLabel(BuildContext context, dynamic value) =>
    context.tr(adminLabels[value] ?? '${value ?? '—'}');

class AdminAccessDenied extends StatelessWidget {
  const AdminAccessDenied({super.key});
  @override
  Widget build(BuildContext context) =>
      Text(context.tr('Only administrators can open this workspace.'));
}

class AdminError extends StatelessWidget {
  const AdminError({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => AppSurface(
          child: Column(children: [
        Text(context.tr(error is ApiException
            ? (error as ApiException).message
            : 'Could not load administrative data.')),
        AppButton(label: 'Try again', onPressed: onRetry),
      ]));
}

class AdminFilter extends StatelessWidget {
  const AdminFilter(
      {super.key,
      required this.label,
      required this.value,
      required this.values,
      required this.onChanged,
      this.allowAll = true});
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  final bool allowAll;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        key: ValueKey('$label:$value'),
        initialValue: value ?? '',
        decoration: InputDecoration(labelText: context.tr(label)),
        items: [
          if (allowAll)
            DropdownMenuItem(value: '', child: Text(context.tr('All'))),
          for (final item in values)
            DropdownMenuItem(
                value: item, child: Text(adminLabel(context, item))),
        ],
        onChanged: (v) => onChanged(v == '' ? null : v),
      );
}

class AdminFacts extends StatelessWidget {
  const AdminFacts({super.key, required this.data, required this.fields});
  final Map<String, dynamic> data;
  final Map<String, String> fields;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final entry in fields.entries)
          if (data[entry.key] != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: SelectableText(
                    '${context.tr(entry.value)}: ${_display(context, data[entry.key])}')),
      ]);
  String _display(BuildContext context, dynamic value) {
    if (value is bool) return context.tr(value ? 'Yes' : 'No');
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) return date.toLocal().toString().split('.').first;
    }
    return '$value';
  }
}

class AdminParty extends StatelessWidget {
  const AdminParty(
      {super.key, required this.label, required this.party, this.onTap});
  final String label;
  final Map<String, dynamic> party;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
          '${context.tr(label)}: ${party['name'] ?? party['email'] ?? party['id']}'),
      subtitle: Text(
          '${party['email'] ?? ''} · ${adminLabel(context, party['role'])}'),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap);
}

class AdminAuditCard extends StatelessWidget {
  const AdminAuditCard({super.key, required this.entry});
  final Map<String, dynamic> entry;
  @override
  Widget build(BuildContext context) => AppSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(adminLabel(context, entry['action']),
            style: Theme.of(context).textTheme.titleMedium),
        AdminFacts(data: entry, fields: const {
          'actorEmail': 'Administrator',
          'createdAt': 'Created',
          'targetUserId': 'Target user ID',
          'targetReportId': 'Report ID',
          'reason': 'Reason'
        }),
        if (entry['metadata'] is Map)
          AdminFacts(
              data: Map<String, dynamic>.from(entry['metadata'] as Map),
              fields: {
                for (final key in (entry['metadata'] as Map).keys)
                  '$key': '$key'
              }),
      ]));
}

Future<bool> adminConfirm(
        BuildContext context, String title, String details) async =>
    await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(context.tr(title)),
                content: Text(details),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Confirm'))),
                ])) ??
    false;

class AdminDecision {
  const AdminDecision(this.status, this.note, this.until);
  final String status, note;
  final DateTime? until;
}

Future<AdminDecision?> showAdminDecision(BuildContext context,
        {required String title,
        required String initialStatus,
        required List<String> statuses,
        bool reasonRequired = false,
        bool allowSuspension = false}) =>
    showDialog<AdminDecision>(
        context: context,
        builder: (_) => _DecisionDialog(
            title: title,
            initialStatus: initialStatus,
            statuses: statuses,
            reasonRequired: reasonRequired,
            allowSuspension: allowSuspension));

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog(
      {required this.title,
      required this.initialStatus,
      required this.statuses,
      required this.reasonRequired,
      required this.allowSuspension});
  final String title, initialStatus;
  final List<String> statuses;
  final bool reasonRequired, allowSuspension;
  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  late String _status = widget.initialStatus;
  final _note = TextEditingController();
  DateTime? _until;
  bool _submitted = false;
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _valid => !widget.reasonRequired || _note.text.trim().length >= 10;
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.tr(widget.title)),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          AdminFilter(
              label: 'Status',
              value: _status,
              values: widget.statuses,
              allowAll: false,
              onChanged: (v) => setState(() {
                    _status = v!;
                    if (_status != 'suspended') _until = null;
                  })),
          const SizedBox(height: 16),
          AppInput(
              controller: _note,
              labelText: context
                  .tr(widget.reasonRequired ? 'Reason' : 'Note (optional)'),
              maxLines: 4,
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
              errorText: _submitted && !_valid
                  ? context.tr('Give a reason between 10 and 500 characters.')
                  : null),
          if (widget.allowSuspension && _status == 'suspended') ...[
            TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final day = await showDatePicker(
                      context: context,
                      initialDate: _until ?? now.add(const Duration(days: 7)),
                      firstDate: DateTime(now.year, now.month, now.day + 1),
                      lastDate: DateTime(now.year + 10));
                  if (day != null && mounted) setState(() => _until = day);
                },
                child: Text(_until == null
                    ? context.tr('Set suspension end date (optional)')
                    : _until!.toLocal().toString().split(' ').first)),
            if (_until != null)
              TextButton(
                  onPressed: () => setState(() => _until = null),
                  child: Text(context.tr('Remove end date'))),
          ],
          if (widget.reasonRequired)
            Text(context.tr(
                'The reason is shown to the affected account and recorded in the audit history.')),
        ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('Cancel'))),
          FilledButton(
              onPressed: () {
                setState(() => _submitted = true);
                if (_valid) {
                  Navigator.pop(context,
                      AdminDecision(_status, _note.text.trim(), _until));
                }
              },
              child: Text(context.tr('Confirm'))),
        ],
      );
}
