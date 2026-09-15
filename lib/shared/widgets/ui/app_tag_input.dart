import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_input.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Free-text tags — skills, typed one at a time and shown as removable chips.
///
/// The chips are the neutral tag, not a coloured one: a skill name is neither a
/// state nor a kind, so it carries no hue (the same rule as the web's `Tag`).
class AppTagInput extends StatefulWidget {
  const AppTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.labelText,
    this.hintText = 'Type and press add',
    this.errorText,
    this.max = 20,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? labelText;
  final String hintText;
  final String? errorText;
  final int max;

  @override
  State<AppTagInput> createState() => _AppTagInputState();
}

class _AppTagInputState extends State<AppTagInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final value = _controller.text.trim();
    if (value.isEmpty || widget.tags.length >= widget.max) return;
    // Case-insensitive, so "react" doesn't sit beside "React".
    final exists = widget.tags.any((t) => t.toLowerCase() == value.toLowerCase());
    _controller.clear();
    if (!exists) widget.onChanged([...widget.tags, value]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final full = widget.tags.length >= widget.max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          controller: _controller,
          labelText: widget.labelText,
          hintText: full ? 'Limit of ${widget.max} reached' : widget.hintText,
          enabled: !full,
          textInputAction: TextInputAction.done,
          suffixIcon: LucideIcons.plus,
          onSuffixTap: _add,
          onSubmitted: (_) => _add(),
          errorText: widget.errorText,
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: AppShape.space2),
          Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              for (final tag in widget.tags)
                InputChip(
                  label: Text(tag, style: AppTypography.tag.copyWith(color: t.foreground)),
                  onDeleted: () => widget.onChanged(
                    widget.tags.where((x) => x != tag).toList(),
                  ),
                  deleteIcon: Icon(LucideIcons.x, size: 14, color: t.mutedForeground),
                  deleteButtonTooltipMessage: 'Remove $tag',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
