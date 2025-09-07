import 'package:apsaratalent_mobile/features/feed/presentation/widgets/company_card_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_appbar_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(),
      body: Column(
        children: [
          CompanyCardWidget(),
        ],
      ),
    );
  }
}
