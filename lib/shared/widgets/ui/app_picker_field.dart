import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A field that opens a picker instead of a keyboard — a select, a date, a
/// multi-select. It draws the same box as `AppInput` (the `input` boundary,
/// the destructive edge on error, the label above and the message below) so a
/// form mixing both reads as one set of controls.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.hintText,
    required this.onTap,
    this.labelText,
    this.value,
    this.prefixIcon,
    this.errorText,
  });

  final String hintText;
  final VoidCallback onTap;
  final String? labelText;

  /// What is currently chosen, as text. Null shows [hintText].
  final String? value;
  final IconData? prefixIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: AppTypography.label.copyWith(color: t.foreground)),
          const SizedBox(height: AppShape.space2),
        ],
        Semantics(
          button: true,
          label: labelText ?? hintText,
          value: value,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              // Matches AppInput: its 3px focus ring sits outside the box, so
              // the transparent 3px here keeps the two fields the same width.
              margin: const EdgeInsets.all(3),
              height: AppShape.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppShape.space3),
              decoration: BoxDecoration(
                color: t.background,
                border: Border.all(
                  color: hasError ? t.destructive : t.input,
                  width: AppShape.hairline,
                ),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 18, color: t.mutedForeground),
                    const SizedBox(width: AppShape.space2),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? value! : hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasValue
                          ? AppTypography.field.copyWith(color: t.foreground)
                          : AppTypography.small.copyWith(
                              color: t.mutedForeground.withValues(alpha: 0.7),
                            ),
                    ),
                  ),
                  Icon(LucideIcons.chevronDown, size: 18, color: t.mutedForeground),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppShape.space1),
          Text(errorText!, style: AppTypography.tiny.copyWith(color: t.destructive)),
        ],
      ],
    );
  }
}

/// A choice in a picker sheet.
class PickerItem<T> {
  const PickerItem(this.label, this.value);

  final String label;
  final T value;
}

/// Shows a single-choice list in a bottom sheet and returns the chosen value,
/// or null if dismissed. Lists longer than [searchThreshold] get a filter box.
Future<T?> showPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<PickerItem<T>> items,
  T? selected,
  int searchThreshold = 12,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.tokens.card,
    barrierColor: context.tokens.scrim.withValues(alpha: 0.6),
    builder: (_) => _PickerSheet<T>(
      title: title,
      items: items,
      selected: {if (selected != null) selected},
      multi: false,
      searchable: items.length > searchThreshold,
    ),
  );
}

/// Shows a multi-choice list in a bottom sheet and returns the full selection,
/// or null if dismissed without confirming.
Future<Set<T>?> showMultiPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<PickerItem<T>> items,
  required Set<T> selected,
  int? max,
}) {
  return showModalBottomSheet<Set<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.tokens.card,
    barrierColor: context.tokens.scrim.withValues(alpha: 0.6),
    builder: (_) => _PickerSheet<T>(
      title: title,
      items: items,
      selected: selected,
      multi: true,
      searchable: true,
      max: max,
    ),
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.multi,
    required this.searchable,
    this.max,
  });

  final String title;
  final List<PickerItem<T>> items;
  final Set<T> selected;
  final bool multi;
  final bool searchable;
  final int? max;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late final Set<T> _selected = {...widget.selected};
  String _query = '';

  List<PickerItem<T>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
  }

  void _tap(PickerItem<T> item) {
    if (!widget.multi) {
      Navigator.of(context).pop(item.value);
      return;
    }
    setState(() {
      if (_selected.contains(item.value)) {
        _selected.remove(item.value);
      } else if (widget.max == null || _selected.length < widget.max!) {
        _selected.add(item.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final visible = _visible;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The dialog's ink top edge, which `Sheet` shares on the web.
              Container(height: AppShape.accentSurface, color: t.foreground),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppShape.space4, AppShape.space4, AppShape.space2, AppShape.space2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTypography.h4.copyWith(color: t.foreground),
                      ),
                    ),
                    if (widget.multi)
                      Text(
                        widget.max == null
                            ? '${_selected.length} selected'
                            : '${_selected.length}/${widget.max}',
                        style: AppTypography.tiny.copyWith(color: t.mutedForeground),
                      ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(LucideIcons.x, size: 20, color: t.foreground),
                    ),
                  ],
                ),
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppShape.space4),
                  child: TextField(
                    autofocus: false,
                    onChanged: (v) => setState(() => _query = v),
                    style: AppTypography.field.copyWith(color: t.foreground),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(LucideIcons.search, size: 18, color: t.mutedForeground),
                    ),
                  ),
                ),
              const SizedBox(height: AppShape.space2),
              Divider(height: AppShape.hairline, color: t.border),
              Flexible(
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppShape.space6),
                        child: Text(
                          'Nothing matches "$_query"',
                          textAlign: TextAlign.center,
                          style: AppTypography.small.copyWith(color: t.mutedForeground),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: AppShape.hairline, color: t.border),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          final isOn = _selected.contains(item.value);
                          return InkWell(
                            onTap: () => _tap(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppShape.space4,
                                vertical: AppShape.space3,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: AppTypography.small.copyWith(
                                        color: t.foreground,
                                        fontWeight:
                                            isOn ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isOn)
                                    Icon(LucideIcons.check, size: 18, color: t.primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (widget.multi) ...[
                Divider(height: AppShape.hairline, color: t.border),
                Padding(
                  padding: const EdgeInsets.all(AppShape.space4),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppShape.controlHeightMd),
                      shape: const RoundedRectangleBorder(),
                      backgroundColor: t.primary,
                      foregroundColor: t.primaryForeground,
                    ),
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text(
                      'Done',
                      style: AppTypography.button.copyWith(color: t.primaryForeground),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
