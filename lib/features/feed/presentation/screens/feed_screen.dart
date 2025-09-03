import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Page'),
      ),
    );
  }
}
