import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
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
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );

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
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value, int index) {
    ref.read(otpProvider.notifier).updateDigit(index, value);

    if (value.isNotEmpty && value.length == 1) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final otpState = ref.read(otpProvider);
    final combinedOTP = otpState.otp;
    widget.onChanged?.call(combinedOTP);

    if (combinedOTP.length == widget.length) {
      widget.onCompleted?.call(combinedOTP);
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
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.backspace) {
                    final currentValue = _controllers[index].text;
                    if (currentValue.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  }
                }
                return KeyEventResult.handled;
              },
              child: TextFormField(
                controller: _controllers[index],
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
            ),
          ),
        ),
      ),
    );
  }
}
