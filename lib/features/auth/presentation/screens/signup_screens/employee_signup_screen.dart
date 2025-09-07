import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EmployeeSignupScreen extends StatelessWidget {
  const EmployeeSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Signup Screen'),
      ),
    );
  }
}
