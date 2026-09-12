import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A six-box one-time-code field, writing through [otpProvider].
///
/// Each box is square with an `input`-token boundary that turns `ring` on
/// focus, so it agrees with `AppInput` rather than inventing its own resting
/// state.
///
/// Entry is kept strictly left to right. [OtpNotifier.updateDigit] appends
/// when the index is past the current end, so typing into box 4 of an empty
/// code would land the digit in position 0. Tapping any box therefore focuses
/// the first empty one instead.
class OtpField extends ConsumerStatefulWidget {
  const OtpField({super.key, this.length = 6, this.onCompleted});

  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  ConsumerState<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends ConsumerState<OtpField> {
  late final List<FocusNode> _focusNodes =
      List.generate(widget.length, (_) => FocusNode());
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _focusFirstEmpty() {
    final filled = ref.read(otpProvider).otp.length;
    _focusNodes[filled.clamp(0, widget.length - 1)].requestFocus();
  }

  void _onChanged(int index, String value) {
    final notifier = ref.read(otpProvider.notifier);
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length <= 1) {
      notifier.updateDigit(index, digits);
      if (digits.isNotEmpty && index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      // SMS autofill and paste both deliver the whole code into the focused
      // box in one go. Spread it forward rather than truncating to the first
      // digit, which is what a `maxLength: 1` box would do.
      var i = index;
      for (final digit in digits.split('')) {
        if (i >= widget.length) break;
        _controllers[i].value = TextEditingValue(
          text: digit,
          selection: const TextSelection.collapsed(offset: 1),
        );
        notifier.updateDigit(i, digit);
        i++;
      }
      _focusNodes[i.clamp(0, widget.length - 1)].requestFocus();
    }

    final state = ref.read(otpProvider);
    if (state.isComplete) {
      FocusScope.of(context).unfocus();
      widget.onCompleted?.call(state.otp);
    }
  }

  /// Backspace in an already-empty box steps back and clears the previous one.
  /// The soft keyboard sends no change event for an empty field, so this is
  /// caught as a key event instead.
  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      ref.read(otpProvider.notifier).updateDigit(index - 1, '');
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Resend clears the notifier; the boxes hold their own controllers, so
    // they have to be emptied to match or the old code stays on screen.
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.otp.isEmpty && (previous?.otp.isNotEmpty ?? false)) {
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes.first.requestFocus();
      }
    });

    return Row(
      children: [
        for (var i = 0; i < widget.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == widget.length - 1 ? 0 : AppShape.space2,
              ),
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onKeyEvent: (_, event) => _onKey(i, event),
                child: _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  autofocus: i == 0,
                  onTap: _focusFirstEmpty,
                  onChanged: (value) => _onChanged(i, value),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onTap,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != widget.focusNode.hasFocus) {
      setState(() => _focused = widget.focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      decoration: BoxDecoration(
        color: t.background,
        border: Border.all(
          color: _focused ? t.ring : t.input,
          width: AppShape.hairline,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onTap: widget.onTap,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        cursorColor: t.primary,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.h4.copyWith(color: t.foreground),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
