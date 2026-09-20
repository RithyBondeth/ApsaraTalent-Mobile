import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/widgets/feed_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// `/user/employee/all-favorites` nests a trimmed company: no `benefits`,
  /// `values` or `careerScopes`, unlike `/user/company/all`. The favourites
  /// screen renders these, so the card has to survive them being absent.
  final trimmed = FeedCompany.fromJson(const {
    'id': 'c9',
    'name': 'Sabay Digital',
    'industry': 'Media',
    'location': 'Phnom Penh',
    'companySize': 120,
    'foundedYear': 2007,
    'openPositions': [
      {'title': 'Digital Marketing Manager', 'type': 'full_time'},
    ],
  });

  Future<void> pump(WidgetTester tester, {required bool withLike}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: FeedProfileCard(
                profile: trimmed,
                saved: true,
                busy: false,
                onTap: () {},
                onSave: () {},
                onLike: withLike ? () {} : null,
                onView: () {},
              ),
            ),
          ),
        ),
      );

  testWidgets('a trimmed favourite record still renders its card',
      (tester) async {
    await pump(tester, withLike: false);

    expect(tester.takeException(), isNull);
    expect(find.text('Sabay Digital'), findsOneWidget);
    expect(find.text('Digital Marketing Manager'), findsOneWidget);
  });

  testWidgets('the like button is left out where liking is not offered',
      (tester) async {
    await pump(tester, withLike: false);
    expect(find.text('Like'), findsNothing);
    // Saving is still offered — it is how a favourite is removed.
    expect(find.text('Saved'), findsOneWidget);

    await pump(tester, withLike: true);
    expect(find.text('Like'), findsOneWidget);
  });
}
