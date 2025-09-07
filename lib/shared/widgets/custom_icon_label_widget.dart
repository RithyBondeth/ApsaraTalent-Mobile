import 'package:flutter/material.dart';

class CustomIconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final TextStyle? labelStyle;
  const CustomIconLabel({
    super.key,
    required this.icon,
    this.iconSize = 15,
    required this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: iconSize),
        SizedBox(width: 5),
        Text(label, style: labelStyle),
      ],
    );
  }
}
