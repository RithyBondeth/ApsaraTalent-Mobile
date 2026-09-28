import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:apsaratalent_mobile/features/call/providers/call_controller.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_models.dart';
import '../../providers/chat_controller.dart';
import '../widgets/attachment_view.dart';

@RoutePage()
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversation});
  final Conversation conversation;
  @override
  ConsumerState<ConversationScreen> createState() => _ConversationState();
}

class _ConversationState extends ConsumerState<ConversationScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _recorder = AudioRecorder();
  ChatController? _chat;
  ChatMessage? _reply;
  ChatAttachment? _attachment;
  Timer? _typingTimer, _recordLimit;
  bool _uploading = false, _recording = false;
  String? _recordPath;
  int _messageCount = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chat = ref.read(chatControllerProvider);
      _chat!.open(widget.conversation);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _recordLimit?.cancel();
    _recorder.dispose();
    final path = _recordPath;
    if (path != null) {
      unawaited(File(path).exists().then((exists) async {
        if (exists) await File(path).delete();
      }));
    }
    // Avoid changing providers during the route's teardown/build phase.
    final chat = _chat;
    Future.microtask(() {
      if (chat?.active?.id == widget.conversation.id) chat?.closeConversation();
    });
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final messages = chat.active?.id == widget.conversation.id
        ? chat.messages
        : <ChatMessage>[];
    if (_messageCount != messages.length) {
      final nearBottom =
          !_scroll.hasClients || _scroll.position.extentAfter < 150;
      _messageCount = messages.length;
      if (nearBottom || chat.historyLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.conversation.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
                !chat.connected
                    ? 'Reconnecting…'
                    : chat.typing.contains(widget.conversation.id)
                        ? 'Typing…'
                        : chat.online.contains(widget.conversation.id)
                            ? 'Online'
                            : 'Offline',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
          actions: [
            IconButton(
                tooltip: 'Voice call',
                onPressed: chat.connected && !_recording
                    ? () => _run(() => ref
                        .read(callControllerProvider)
                        .start(widget.conversation))
                    : null,
                icon: const Icon(Icons.call_outlined))
          ]),
      body: SafeArea(
          child: Column(children: [
        if (chat.error != null)
          MaterialBanner(content: Text(chat.error!), actions: [
            TextButton(
                onPressed: chat.loadHistory, child: const Text('Reload')),
          ]),
        if (chat.historyLoading) const LinearProgressIndicator(),
        if (chat.historyLimited)
          const Padding(
              padding: EdgeInsets.all(8),
              child: Text('The server history limit has been reached.')),
        Expanded(
            child: messages.isEmpty && !chat.historyLoading
                ? const Center(
                    child: Text('Say hello to start the conversation.'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _bubble(messages[index], chat))),
        if (_reply != null)
          ListTile(
              dense: true,
              title: const Text('Replying to'),
              subtitle: Text(_reply!.content,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                  tooltip: 'Cancel reply',
                  onPressed: () => setState(() => _reply = null),
                  icon: const Icon(Icons.close))),
        if (_attachment != null)
          ListTile(
              dense: true,
              title: Text(_attachment!.filename),
              trailing: IconButton(
                  tooltip: 'Remove attachment',
                  onPressed: () => setState(() => _attachment = null),
                  icon: const Icon(Icons.close))),
        if (_uploading) const LinearProgressIndicator(),
        if (_recording)
          Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                const Expanded(child: Text('Recording voice message…')),
                TextButton(
                    onPressed: () => _stopRecording(cancel: true),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => _stopRecording(),
                    child: const Text('Attach recording')),
              ])),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              IconButton(
                  tooltip: 'Attach file',
                  onPressed: chat.connected &&
                          !_uploading &&
                          !_recording &&
                          !chat.sending
                      ? _pick
                      : null,
                  icon: const Icon(Icons.attach_file)),
              Expanded(
                  child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 5000,
                      decoration: const InputDecoration(
                          hintText: 'Write a message', counterText: ''),
                      onChanged: (_) {
                        chat.setTyping(true);
                        _typingTimer?.cancel();
                        _typingTimer = Timer(const Duration(seconds: 2),
                            () => chat.setTyping(false));
                      })),
              IconButton(
                  tooltip: 'Record voice message',
                  onPressed: chat.connected &&
                          !_uploading &&
                          !_recording &&
                          !chat.sending
                      ? _record
                      : null,
                  icon: const Icon(Icons.mic_none)),
              IconButton(
                  tooltip: 'Send message',
                  onPressed: chat.connected &&
                          !_uploading &&
                          !_recording &&
                          !chat.sending
                      ? _send
                      : null,
                  icon: chat.sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send)),
            ])),
      ])),
    );
  }

  Widget _bubble(ChatMessage message, ChatController chat) {
    final mine = message.senderId == chat.me;
    final colors = Theme.of(context).colorScheme;
    final reply =
        chat.messages.where((m) => m.id == message.replyToId).firstOrNull;
    return Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * .82),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: mine
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                border: Border.all(color: colors.outlineVariant)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isDeleted)
                    const Text('Message deleted',
                        style: TextStyle(fontStyle: FontStyle.italic))
                  else ...[
                    if (message.replyToId != null)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                              '↳ ${reply?.isDeleted == true ? 'Message deleted' : reply?.content ?? 'Earlier message'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall)),
                    if (message.content.isNotEmpty)
                      SelectableText(message.content),
                    if (message.attachment != null)
                      AttachmentView(
                          key: ValueKey(message.id), message: message),
                    if (message.reactions.isNotEmpty)
                      Text(message.reactions.values.join(' ')),
                  ],
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        '${message.sentAt.toLocal().hour.toString().padLeft(2, '0')}:${message.sentAt.toLocal().minute.toString().padLeft(2, '0')}${message.isEdited ? ' · edited' : ''}',
                        style: Theme.of(context).textTheme.labelSmall),
                    if (mine)
                      Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 15,
                              semanticLabel: message.isRead ? 'Read' : 'Sent')),
                    if (!message.isDeleted)
                      PopupMenuButton<String>(
                          tooltip: 'Message actions',
                          onSelected: (action) => _action(action, message),
                          itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'reply', child: Text('Reply')),
                                const PopupMenuItem(
                                    value: 'react', child: Text('React')),
                                if (message.reactions.containsKey(chat.me))
                                  const PopupMenuItem(
                                      value: 'unreact',
                                      child: Text('Remove reaction')),
                                if (mine && message.type == 'text')
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                if (mine)
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                              ]),
                  ]),
                ])));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ChatController.messageFor(e))));
      }
    }
  }

  Future<void> _send() => _run(() async {
        final text = _text.text;
        if (text.trim().isEmpty && _attachment == null) return;
        await ref
            .read(chatControllerProvider)
            .send(text, attachment: _attachment, replyToId: _reply?.id);
        if (!mounted) return;
        // Preserve anything typed while awaiting the server acknowledgement.
        if (_text.text == text) _text.clear();
        setState(() {
          _attachment = null;
          _reply = null;
        });
        ref.read(chatControllerProvider).setTyping(false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      });
  Future<void> _pick() => _run(() async {
        final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ChatRepository.mimeTypes.keys.toList(),
        );
        if (file == null || !mounted) return;
        final size = await file.length();
        if (size == null) {
          throw const FormatException('Could not read the selected file.');
        }
        if (size > 10 * 1024 * 1024) {
          throw const FormatException('File exceeds 10 MB.');
        }
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        setState(() => _uploading = true);
        try {
          final attachment =
              await ref.read(chatRepositoryProvider).upload(file.name, bytes);
          if (mounted) setState(() => _attachment = attachment);
        } finally {
          if (mounted) setState(() => _uploading = false);
        }
      });
  Future<void> _record() => _run(() async {
        if (ref.read(callControllerProvider).active) return;
        if (!await _recorder.hasPermission()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Allow microphone access in device settings to record.')));
          }
          return;
        }
        final dir = await getTemporaryDirectory();
        if (!mounted) return;
        _recordPath =
            '${dir.path}/voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
        await _recorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
            path: _recordPath!);
        if (!mounted) {
          await _recorder.cancel();
          return;
        }
        setState(() => _recording = true);
        _recordLimit =
            Timer(const Duration(minutes: 5), () => _stopRecording());
      });
  Future<void> _stopRecording({bool cancel = false}) => _run(() async {
        _recordLimit?.cancel();
        final path = await _recorder.stop();
        if (mounted) {
          setState(() {
            _recording = false;
            _uploading = !cancel;
          });
        }
        try {
          if (!cancel && path != null && mounted) {
            final attachment = await ref
                .read(chatRepositoryProvider)
                .upload('voice-message.m4a', await File(path).readAsBytes());
            if (mounted) setState(() => _attachment = attachment);
          }
        } finally {
          if (path != null && await File(path).exists()) {
            await File(path).delete();
          }
          _recordPath = null;
          if (mounted) setState(() => _uploading = false);
        }
      });
  Future<void> _action(String action, ChatMessage message) async {
    final chat = ref.read(chatControllerProvider);
    if (action == 'reply') {
      setState(() => _reply = message);
      return;
    }
    if (action == 'unreact') {
      await _run(() => chat.react(message, null));
      return;
    }
    if (action == 'react') {
      final emoji = await showDialog<String>(
          context: context,
          builder: (context) =>
              SimpleDialog(title: const Text('React to message'), children: [
                Wrap(alignment: WrapAlignment.center, children: [
                  for (final e in ['👍', '❤️', '😂', '🎉', '🙏', '😮'])
                    TextButton(
                        onPressed: () => Navigator.pop(context, e),
                        child: Text(e, style: const TextStyle(fontSize: 28)))
                ])
              ]));
      if (emoji != null && mounted) {
        await _run(() => chat.react(message, emoji));
      }
      return;
    }
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Delete this message?'),
                  content: const Text('It will be removed for both people.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'))
                  ]));
      if (confirmed == true && mounted) await _run(() => chat.remove(message));
      return;
    }
    if (action == 'edit') {
      final editor = TextEditingController(text: message.content);
      final value = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Edit message'),
                  content: TextField(
                      controller: editor, maxLength: 5000, maxLines: 5),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, editor.text),
                        child: const Text('Save'))
                  ]));
      // Dialog route animations may still reference the controller this frame.
      Future.delayed(const Duration(milliseconds: 300), editor.dispose);
      if (value != null && mounted) await _run(() => chat.edit(message, value));
      return;
    }
  }
}
