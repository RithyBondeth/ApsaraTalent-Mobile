import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.job = 'Sales Manager'});

  String job;
  bool fail = false;
  int calls = 0;
  FeedViewer? lastViewer;

  @override
  Future<UserProfile> fetchProfile(FeedViewer viewer) async {
    calls++;
    lastViewer = viewer;
    if (fail) throw ApiException(message: 'profile down');
    return EmployeeProfile(id: viewer.profileId, fullName: 'Chenda Nhem', job: job);
  }
}

void main() {
  const viewer = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');

  late FakeProfileRepository repository;

  ProviderContainer containerFor(FeedViewer? currentViewer) {
    final container = ProviderContainer(overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      feedViewerProvider.overrideWithValue(currentViewer),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => repository = FakeProfileRepository());

  test('loads the profile for the signed-in viewer', () async {
    final container = containerFor(viewer);

    final profile = await container.read(profileProvider.future);

    expect(profile, isA<EmployeeProfile>());
    expect(profile!.headline, 'Sales Manager');
    expect(repository.lastViewer, viewer);
  });

  test('an account with no profile asks the API for nothing', () async {
    // An admin, or a phone login that has not finished onboarding.
    final container = containerFor(null);

    final profile = await container.read(profileProvider.future);

    expect(profile, isNull);
    expect(repository.calls, 0);
  });

  test('a failed load fails the screen', () async {
    repository.fail = true;
    final container = containerFor(viewer);

    await expectLater(
      container.read(profileProvider.future),
      throwsA(isA<ApiException>()),
    );
  });

  test('refresh replaces the profile with what the API now returns', () async {
    final container = containerFor(viewer);
    await container.read(profileProvider.future);

    repository.job = 'Head of Sales';
    await container.read(profileProvider.notifier).refresh();

    expect(container.read(profileProvider).value!.headline, 'Head of Sales');
    expect(repository.calls, 2);
  });

  test('a failed refresh keeps the profile up and rethrows', () async {
    final container = containerFor(viewer);
    await container.read(profileProvider.future);

    repository.fail = true;
    await expectLater(
      container.read(profileProvider.notifier).refresh(),
      throwsA(isA<ApiException>()),
    );

    // The screen reports the error; it does not go blank.
    expect(container.read(profileProvider).value, isNotNull);
    expect(container.read(profileProvider).value!.headline, 'Sales Manager');
  });
}
