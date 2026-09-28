import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.job = 'Sales Manager'});

  String job;
  bool fail = false;
  int calls = 0;
  FeedViewer? lastViewer;

  Map<String, dynamic>? lastChanges;
  String? lastMediaAction;

  /// Mirrors the API: only the keys sent are applied.
  @override
  Future<UserProfile> updateProfile(
    FeedViewer viewer,
    Map<String, dynamic> changes,
  ) async {
    calls++;
    lastChanges = changes;
    if (fail) throw ApiException(message: 'save failed');
    if (changes.containsKey('job')) job = '${changes['job']}';
    return EmployeeProfile(
      id: viewer.profileId,
      fullName: 'Chenda Nhem',
      job: job,
    );
  }

  @override
  Future<UserProfile> fetchProfile(FeedViewer viewer) async {
    calls++;
    lastViewer = viewer;
    if (fail) throw ApiException(message: 'profile down');
    return EmployeeProfile(
        id: viewer.profileId, fullName: 'Chenda Nhem', job: job);
  }

  @override
  Future<void> uploadAvatar(FeedViewer viewer, ProfileUpload file) async {
    lastMediaAction = 'upload-avatar:${file.filename}';
  }

  @override
  Future<void> removeAvatar(FeedViewer viewer) async {
    lastMediaAction = 'remove-avatar';
  }

  @override
  Future<void> uploadEmployeeDocument(
      String employeeId, EmployeeDocumentType type, ProfileUpload file) async {
    lastMediaAction = 'upload-${type.apiValue}:${file.filename}';
  }

  @override
  Future<void> removeEmployeeDocument(
      String employeeId, EmployeeDocumentType type) async {
    lastMediaAction = 'remove-${type.apiValue}';
  }

  @override
  Future<Uint8List> downloadEmployeeDocument(
          String employeeId, EmployeeDocumentType type) async =>
      Uint8List.fromList([1, 2, 3]);

  @override
  Future<void> uploadCompanyCover(String companyId, ProfileUpload file) async {
    lastMediaAction = 'upload-cover:${file.filename}';
  }

  @override
  Future<void> removeCompanyCover(String companyId) async {
    lastMediaAction = 'remove-cover';
  }

  @override
  Future<void> uploadCompanyImages(
      String companyId, List<ProfileUpload> files) async {
    lastMediaAction = 'upload-images:${files.length}';
  }

  @override
  Future<void> removeCompanyImage(String companyId, String imageId) async {
    lastMediaAction = 'remove-image:$imageId';
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

  group('saving', () {
    test('sends only the keys given', () async {
      // The API Object.assigns whatever arrives, so an unchanged field must
      // not be restated — for `job` it would re-trigger the server's
      // embedding work for nothing.
      final container = containerFor(viewer);
      await container.read(profileProvider.future);

      await container
          .read(profileProvider.notifier)
          .save({'job': 'Head of Sales'});

      expect(repository.lastChanges, {'job': 'Head of Sales'});
      expect(container.read(profileProvider).value!.headline, 'Head of Sales');
    });

    test('an empty change set asks the API for nothing', () async {
      final container = containerFor(viewer);
      await container.read(profileProvider.future);
      final before = repository.calls;

      await container.read(profileProvider.notifier).save({});

      expect(repository.calls, before);
    });

    test('a null value is sent, because clearing a field is a change',
        () async {
      // An emptied text field clears the value; it is not the same as leaving
      // the field out.
      final container = containerFor(viewer);
      await container.read(profileProvider.future);

      await container
          .read(profileProvider.notifier)
          .save({'portfolioUrl': null});

      expect(repository.lastChanges, containsPair('portfolioUrl', null));
    });

    test('a failed save rethrows and leaves the profile as it was', () async {
      final container = containerFor(viewer);
      await container.read(profileProvider.future);
      repository.fail = true;

      await expectLater(
        container.read(profileProvider.notifier).save({'job': 'Nope'}),
        throwsA(isA<ApiException>()),
      );

      expect(container.read(profileProvider).value!.headline, 'Sales Manager');
    });
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

  test('a media mutation refreshes the profile after the upload', () async {
    final container = containerFor(viewer);
    await container.read(profileProvider.future);
    final before = repository.calls;

    await container.read(profileProvider.notifier).uploadAvatar(
          ProfileUpload(
            filename: 'avatar.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        );

    expect(repository.lastMediaAction, 'upload-avatar:avatar.png');
    expect(repository.calls, before + 1);
  });
}
