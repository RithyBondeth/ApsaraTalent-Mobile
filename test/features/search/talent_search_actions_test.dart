import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:apsaratalent_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:apsaratalent_mobile/features/search/providers/search_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feed/feed_notifier_test.dart' show FakeFeedRepository;

class TalentSearchRepository implements SearchRepository {
  @override
  Future<SearchResults<FeedEmployee>> searchTalent({
    required String keyword,
    List<String> careerScopes = const [],
    int page = 1,
  }) async =>
      const SearchResults(
        items: [
          FeedEmployee(id: 'e1', fullName: 'Sok Dara', job: 'Designer'),
          FeedEmployee(id: 'e2', fullName: 'Chan Lina', job: 'Designer'),
        ],
        total: 2,
        page: 1,
        pageSize: 10,
        usedFallback: false,
      );

  @override
  Future<SearchResults<JobPosting>> searchJobs({
    required String keyword,
    List<String> careerScopes = const [],
    int page = 1,
  }) =>
      throw UnimplementedError('a company searches talent, not jobs');

  @override
  Future<JobPosting> fetchJob(String jobId) => throw UnimplementedError();
}

void main() {
  late FakeFeedRepository feed;

  setUp(() => feed = FakeFeedRepository());

  /// A company searching talent, with results for "designer" on screen.
  Future<void> search(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedViewerProvider.overrideWithValue(
            const FeedViewer(role: FeedViewerRole.company, profileId: 'c1'),
          ),
          feedRepositoryProvider.overrideWithValue(feed),
          searchRepositoryProvider.overrideWithValue(TalentSearchRepository()),
          myCareerScopesProvider.overrideWithValue(const []),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const SearchScreen()),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'designer');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Sok Dara'), findsOneWidget);
  }

  Finder inCard(String id, Finder finder) => find.descendant(
        of: find.byKey(ValueKey('talent-$id')),
        matching: finder,
      );

  testWidgets('save favourites the candidate and the card shows it',
      (tester) async {
    await search(tester);

    await tester.tap(inCard('e1', find.text('Save')));
    await tester.pumpAndSettle();

    expect(feed.favorites.keys, contains('e1'));
    expect(inCard('e1', find.text('Saved')), findsOneWidget);
    expect(inCard('e2', find.text('Save')), findsOneWidget);
  });

  testWidgets('view opens the candidate, with like offered', (tester) async {
    await search(tester);

    final view = inCard('e2', find.text('View'));
    await tester.ensureVisible(view);
    await tester.tap(view);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(BottomSheet), matching: find.text('Like')),
      findsOneWidget,
    );
  });

  testWidgets('a candidate already liked is not offered a second like',
      (tester) async {
    feed.liked = {'e1'};
    await search(tester);

    await tester.tap(find.text('Sok Dara'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(BottomSheet), matching: find.text('Like')),
      findsNothing,
    );
  });
}
