import 'package:flutter/material.dart';

class CompanyCardWidget extends StatelessWidget {
  const CompanyCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        color: Colors.red,
        child: Column(
          children: [
            Text('Employee Card'),
          ],
        ),
      ),
    );
  }
}
