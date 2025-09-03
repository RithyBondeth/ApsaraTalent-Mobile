import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomInputWidget extends StatelessWidget {
  const CustomInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(LucideIcons.mail),
        hintText: 'Email',
      ),
    );
  }
}
