import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import '../../data/resume_repository.dart';

class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key, required this.repository});
  final ResumeRepository repository;
  @override
  State<MyResumesScreen> createState() => _MyResumesScreenState();
}

class _MyResumesScreenState extends State<MyResumesScreen> {
  List<Map<String, dynamic>>? _items;
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final items = await widget.repository.drafts();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object e) {
    if (mounted) {
      setState(() => _error = e is ApiException
          ? e.message
          : 'Could not load resumes. Please try again.');
    }
  }

  Future<void> _action(Map<String, dynamic> item, String action) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(context.tr('Delete resume?')),
                content: Text(context.tr(
                    "Delete “{0}” from your account?", {'0': item['name']})),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Delete')))
                ],
              ));
      if (confirmed != true || !mounted) return;
    }
    String? name;
    if (action == 'rename') {
      name = await showDialog<String>(
          context: context,
          builder: (_) => _NameDialog(name: '${item['name']}'));
      if (name == null || !mounted) return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (action == 'delete') {
        await widget.repository.deleteDraft(item['id'] as String);
      } else {
        final record = await widget.repository.draft(item['id'] as String);
        if (action == 'open') {
          if (mounted) Navigator.pop(context, record);
          return;
        }
        final originalName = '${item['name']}';
        final copyName =
            '${originalName.substring(0, originalName.length.clamp(0, 113))} (copy)';
        await widget.repository.saveDraft(
          name ?? copyName,
          Map<String, dynamic>.from(record['content'] as Map),
          id: action == 'rename' ? record['id'] as String : null,
          revision: action == 'rename' ? record['revision'] as int : null,
        );
      }
      await _load();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.tr('My resumes'))),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _busy
                ? null
                : () => Navigator.pop(context, <String, dynamic>{'new': true}),
            icon: const Icon(Icons.add),
            label: Text(context.tr('New resume'))),
        body: RefreshIndicator(
            onRefresh: _load,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              if (_busy) const LinearProgressIndicator(),
              if (_error != null) ...[
                Text(_error!),
                TextButton(
                    onPressed: _busy ? null : _load,
                    child: Text(context.tr('Retry')))
              ],
              if (_items?.isEmpty == true)
                Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(context.tr(
                        'Your saved resumes will appear here. Create one to get started.'))),
              for (final item in _items ?? <Map<String, dynamic>>[])
                ListTile(
                    title: Text('${item['name']}'),
                    subtitle: Text(context.tr("Updated {0}", {
                      '0': DateTime.tryParse('${item['updatedAt']}')
                              ?.toLocal()
                              .toString()
                              .split('.')
                              .first ??
                          ''
                    })),
                    onTap: _busy ? null : () => _action(item, 'open'),
                    trailing: PopupMenuButton<String>(
                        enabled: !_busy,
                        onSelected: (action) => _action(item, action),
                        itemBuilder: (_) => [
                              PopupMenuItem(
                                  value: 'rename',
                                  child: Text(context.tr('Rename'))),
                              PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text(context.tr('Duplicate'))),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: Text(context.tr('Delete'))),
                            ])),
              const SizedBox(height: 90),
            ])),
      );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.name});
  final String name;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final controller = TextEditingController(text: widget.name);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(context.tr('Rename resume')),
          content: TextField(
              controller: controller,
              maxLength: 120,
              autofocus: true,
              onChanged: (_) => setState(() {})),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('Cancel'))),
            TextButton(
                onPressed: controller.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, controller.text.trim()),
                child: Text(context.tr('Save')))
          ]);
}
