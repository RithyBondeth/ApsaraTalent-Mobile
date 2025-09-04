import 'package:apsaratalent_mobile/features/auth/providers/otp_providers.dart';
import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomOTPWidget extends ConsumerStatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final bool autoFocus;
  final TextInputType keyboardType;
  final double fieldWidth;
  final double fieldHeight;
  final double spacing;

  const CustomOTPWidget({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
    this.keyboardType = TextInputType.number,
    this.fieldWidth = 50,
    this.fieldHeight = 50,
    this.spacing = 8,
  });

  @override
  ConsumerState<CustomOTPWidget> createState() => _CustomOTPWidgetState();
}

class _CustomOTPWidgetState extends ConsumerState<CustomOTPWidget> {
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Auto focus first field
    if (widget.autoFocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value, int index) {
    // Update the provider for this field
    ref.read(getOTPFieldProvider(index).notifier).state = value;

    if (value.isNotEmpty && value.length == 1) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, unfocus
        _focusNodes[index].unfocus();
      }
    }

    // Check if OTP is complete and call callbacks
    final combinedOTP = ref.read(combinedOTPProvider);
    widget.onChanged?.call(combinedOTP);

    if (combinedOTP.length == widget.length) {
      widget.onCompleted?.call(combinedOTP);
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        final currentValue = ref.read(getOTPFieldProvider(index));
        if (currentValue.isEmpty && index > 0) {
          // Move to previous field on backspace if current is empty
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: SizedBox(
            width: widget.fieldWidth,
            height: widget.fieldHeight,
            child: Consumer(
              builder: (context, ref, child) {
                final fieldValue = ref.watch(getOTPFieldProvider(index));

                return KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(event, index),
                  child: TextFormField(
                    initialValue: fieldValue,
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: widget.keyboardType,
                    maxLength: 1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: context.border,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: context.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: context.destructive,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: context.destructive,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: context.card,
                    ),
                    onChanged: (value) => _onTextChanged(value, index),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        widget.keyboardType == TextInputType.number
                            ? RegExp(r'[0-9]')
                            : RegExp(r'[a-zA-Z0-9]'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
