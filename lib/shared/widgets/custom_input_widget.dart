import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomInputWidget extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? errorText;
  const CustomInputWidget({
    super.key,
    this.prefixIcon,
    required this.hintText,
    this.isPassword = false,
    this.onChanged,
    this.controller,
    this.errorText,
  });

  @override
  State<CustomInputWidget> createState() => _CustomInputWidgetState();
}

class _CustomInputWidgetState extends State<CustomInputWidget> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? _isObscured : false,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon!,
                color: context.mutedForeground,
              )
            : null,
        hintText: widget.hintText,
        errorText: widget.errorText,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: _toggleObscureText,
                icon: Icon(
                  _isObscured ? LucideIcons.eyeClosed : LucideIcons.eye,
                  color: context.mutedForeground,
                ),
              )
            : null,
      ),
    );
  }
}
