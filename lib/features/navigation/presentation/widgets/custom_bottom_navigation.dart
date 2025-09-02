import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final TabsRouter tabsRouter;
  const CustomBottomNavigationBar({super.key, required this.tabsRouter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.home),
              Text('Home'),
            ],
          ),
          Column(
            children: [
              Icon(Icons.map),
              Text('Map'),
            ],
          )
        ],
      ),
    );
  }
}
