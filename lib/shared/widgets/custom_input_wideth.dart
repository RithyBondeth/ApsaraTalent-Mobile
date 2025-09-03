import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomInputWidget extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  const CustomInputWidget({
    super.key,
    required this.prefixIcon,
    required this.hintText,
    this.isPassword = false,
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
      obscureText: widget.isPassword ? _isObscured : false,
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.prefixIcon,
          color: context.mutedForeground,
        ),
        hintText: widget.hintText,
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
