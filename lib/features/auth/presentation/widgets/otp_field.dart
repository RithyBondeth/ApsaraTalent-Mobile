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
/// The boxes are drawn, not typed into. One invisible [TextField] underneath
/// owns focus and the whole code. Six fields that hand focus to each other
/// lose keystrokes on iOS: every hand-off closes and reopens the platform
/// input connection, and a digit that arrives in between is dropped — which
/// is exactly how fast typing, paste and one-time-code autofill deliver.
///
/// Each box is square with an `input`-token boundary; the box the next digit
/// lands in turns `ring` while the field has focus, so it agrees with
/// `AppInput` rather than inventing its own resting state.
class OtpField extends ConsumerStatefulWidget {
  const OtpField({super.key, this.length = 6, this.onCompleted});

  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  ConsumerState<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends ConsumerState<OtpField> {
  late final TextEditingController _controller =
      TextEditingController(text: ref.read(otpProvider).otp);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  void _onChanged(String value) {
    // Keep the caret at the end: the code is entered and erased from the
    // right, never edited in the middle of a box the user cannot see into.
    if (_controller.selection.baseOffset != value.length) {
      _controller.selection = TextSelection.collapsed(offset: value.length);
    }
    ref.read(otpProvider.notifier).setCode(value);

    if (value.length == widget.length) {
      _focusNode.unfocus();
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resend and a rejected code clear the notifier; the controller has to
    // follow or the old code stays on screen.
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.otp != _controller.text) {
        _controller.value = TextEditingValue(
          text: next.otp,
          selection: TextSelection.collapsed(offset: next.otp.length),
        );
        if (next.otp.isEmpty) _focusNode.requestFocus();
      }
    });

    final code = ref.watch(otpProvider.select((s) => s.otp));
    final active = _focusNode.hasFocus
        ? code.length.clamp(0, widget.length - 1)
        : -1;

    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < widget.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == widget.length - 1 ? 0 : AppShape.space2,
                  ),
                  child: _OtpBox(
                    digit: i < code.length ? code[i] : '',
                    active: i == active,
                    showCaret: i == active && code.length < widget.length,
                  ),
                ),
              ),
          ],
        ),
        Positioned.fill(
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                selectionColor: Colors.transparent,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              maxLength: widget.length,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              showCursor: false,
              // Transparent, not hidden: an offstage field cannot take focus,
              // autofill, or the paste menu.
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              // `filled: false` matters: the app theme fills every input, and
              // this one sits on top of the boxes it would otherwise paint over.
              decoration: const InputDecoration(
                filled: false,
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              expands: true,
              maxLines: null,
              onChanged: _onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.active,
    required this.showCaret,
  });

  final String digit;
  final bool active;
  final bool showCaret;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.background,
        border: Border.all(
          color: active ? t.ring : t.input,
          width: AppShape.hairline,
        ),
      ),
      child: showCaret
          ? Container(width: 2, height: 24, color: t.primary)
          : Text(digit, style: AppTypography.h4.copyWith(color: t.foreground)),
    );
  }
}
