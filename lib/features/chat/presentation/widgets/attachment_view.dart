import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/chat_models.dart';
import '../../providers/chat_controller.dart';

class AttachmentView extends ConsumerStatefulWidget {
  const AttachmentView({super.key, required this.message});
  final ChatMessage message;
  @override
  ConsumerState<AttachmentView> createState() => _AttachmentState();
}

class _AttachmentState extends ConsumerState<AttachmentView> {
  bool _busy = false;
  Uint8List? _image;
  String? _error;
  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_image != null)
        ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: Image.memory(_image!, fit: BoxFit.contain)),
      TextButton.icon(
          onPressed: _busy ? null : _open,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(message.type == 'image'
                  ? Icons.image_outlined
                  : message.type == 'audio'
                      ? Icons.play_circle_outline
                      : Icons.attach_file),
          label: Text(message.filename ?? 'Open attachment',
              maxLines: 2, overflow: TextOverflow.ellipsis)),
      if (_error != null) Text(_error!),
    ]);
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = await ref
          .read(chatRepositoryProvider)
          .download(widget.message.attachment!);
      if (!mounted) return;
      if (widget.message.type == 'image') {
        setState(() => _image = bytes);
      } else {
        final dir = await getTemporaryDirectory();
        // A per-attachment directory avoids filename collisions, and only the
        // sanitized basename from the response reaches the filesystem.
        final safeName = (widget.message.filename ?? 'attachment')
            .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final folder = await Directory(
                '${dir.path}/chat-${widget.message.id.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '')}')
            .create();
        final file = await File('${folder.path}/$safeName').writeAsBytes(bytes);
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          throw Exception('No application could open this attachment.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error =
            e is Exception && e.toString().contains('No application')
                ? 'No application could open this file.'
                : ChatController.messageFor(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
