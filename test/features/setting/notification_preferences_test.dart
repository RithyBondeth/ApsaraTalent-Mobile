import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/notification_preference_repository_impl.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/notification_preferences.dart';
import 'package:apsaratalent_mobile/features/setting/domain/repositories/notification_preference_repository.dart';
import 'package:apsaratalent_mobile/features/setting/providers/notification_preferences_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// The real `GET /notification/preferences` body, with every category present
/// and defaults already merged in, as the API resolves it.
Map<String, dynamic> body({
  bool emailEnabled = true,
  bool pushEnabled = true,
  bool messageEmail = false,
}) =>
    {
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'categories': {
        'application': {'email': true, 'push': true},
        'interview': {'email': true, 'push': true},
        'match': {'email': true, 'push': true},
        'message': {'email': messageEmail, 'push': true},
        'account': {'email': true, 'push': true},
      },
    };

class FakePreferenceRepository implements NotificationPreferenceRepository {
  NotificationPreferences preferences =
      NotificationPreferences.fromJson(body());
  bool fail = false;
  final List<String> writes = [];

  @override
  Future<NotificationPreferences> fetch() async => preferences;

  @override
  Future<NotificationPreferences> setMaster(
    NotificationChannel channel,
    bool enabled,
  ) async {
    writes.add('master.${channel.key}=$enabled');
    if (fail) throw ApiException(message: 'save failed');
    return preferences = preferences.copyWithMaster(channel, enabled);
  }

  @override
  Future<NotificationPreferences> setCategory(
    NotificationCategory category,
    NotificationChannel channel,
    bool enabled,
  ) async {
    writes.add('${category.key}.${channel.key}=$enabled');
    if (fail) throw ApiException(message: 'save failed');
    return preferences =
        preferences.copyWithCategory(category, channel, enabled);
  }
}

void main() {
  group('parsing', () {
    test('reads every category and both masters', () {
      final preferences = NotificationPreferences.fromJson(body());

      expect(preferences.emailEnabled, isTrue);
      expect(preferences.categories, hasLength(5));
      expect(preferences.isOn(NotificationCategory.message,
          NotificationChannel.email), isFalse);
      expect(preferences.isOn(NotificationCategory.message,
          NotificationChannel.push), isTrue);
    });

    test('a missing master resolves to on, as the API does', () {
      // The API resolves an absent row to true, so an absent key is not off.
      final preferences = NotificationPreferences.fromJson({'categories': {}});

      expect(preferences.emailEnabled, isTrue);
      expect(preferences.pushEnabled, isTrue);
    });

    test('a category the API omitted still renders', () {
      final preferences = NotificationPreferences.fromJson({
        'emailEnabled': true,
        'pushEnabled': true,
        'categories': {
          'application': {'email': true, 'push': true},
        },
      });

      // Every category is present whatever the payload carried, so the screen
      // never renders a partial list of switches.
      expect(preferences.categories, hasLength(5));
      expect(
        preferences.isOn(NotificationCategory.match, NotificationChannel.email),
        isFalse,
      );
    });
  });

  group('what a switch can actually change', () {
    test('account is never effective, on either channel', () {
      // The API delivers account notifications whatever the preferences say.
      final preferences = NotificationPreferences.fromJson(body());

      for (final channel in NotificationChannel.values) {
        expect(
          preferences.isEffective(NotificationCategory.account, channel),
          isFalse,
          reason: 'account on ${channel.key}',
        );
      }
    });

    test('account reads as on even when the API stored it off', () {
      // Verified against the API: it accepts and persists
      // `categories.account.email = false`, but `canDeliver` answers true for
      // ACCOUNT without consulting preferences. The stored value is therefore
      // not what happens, and the screen must not repeat it back.
      final preferences = NotificationPreferences.fromJson({
        'emailEnabled': true,
        'pushEnabled': true,
        'categories': {
          'account': {'email': false, 'push': true},
        },
      });

      expect(preferences.isOn(NotificationCategory.account,
          NotificationChannel.email), isFalse);
      expect(NotificationCategory.account.isAlwaysOn, isTrue);
      expect(
        preferences.isEffective(
            NotificationCategory.account, NotificationChannel.email),
        isFalse,
      );
    });

    test('a category is not effective while its master is off', () {
      final preferences =
          NotificationPreferences.fromJson(body(emailEnabled: false));

      expect(
        preferences.isEffective(
            NotificationCategory.match, NotificationChannel.email),
        isFalse,
      );
      // Push is untouched by the email master.
      expect(
        preferences.isEffective(
            NotificationCategory.match, NotificationChannel.push),
        isTrue,
      );
    });
  });

  group('repository', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    NotificationPreferenceRepositoryImpl repositoryFor(FakeHttp http) =>
        NotificationPreferenceRepositoryImpl(
          ApiClient(
            sessionStore: SessionStore(),
            baseUrl: 'http://api.test',
            adapter: http,
          ),
        );

    test('a master write sends only that key', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(200, body(emailEnabled: false)),
      );

      final result = await repositoryFor(http)
          .setMaster(NotificationChannel.email, false);

      final request = http.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/notification/preferences');
      // A partial: anything omitted is left as it was, so one toggle cannot
      // clobber a choice made on another device a second earlier.
      expect(request.data, {'emailEnabled': false});
      expect(result.emailEnabled, isFalse);
    });

    test('a category write nests just that category and channel', () async {
      final http = FakeHttp((_) async => jsonResponse(200, body()));

      await repositoryFor(http).setCategory(
        NotificationCategory.message,
        NotificationChannel.push,
        false,
      );

      expect(http.requests.single.data, {
        'categories': {
          'message': {'push': false},
        },
      });
    });

    test('a body that is not an object becomes a readable error', () async {
      final http = FakeHttp((_) async => jsonResponse(200, 'nope'));

      await expectLater(
        repositoryFor(http).fetch(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('notifier', () {
    late FakePreferenceRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakePreferenceRepository();
      container = ProviderContainer(overrides: [
        notificationPreferenceRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);
    });

    test('a toggle writes once and takes the resolved state back', () async {
      await container.read(notificationPreferencesProvider.future);

      await container
          .read(notificationPreferencesProvider.notifier)
          .setCategory(NotificationCategory.match, NotificationChannel.email,
              false);

      expect(repository.writes, ['match.email=false']);
      final state = container.read(notificationPreferencesProvider).value!;
      expect(
        state.preferences
            .isOn(NotificationCategory.match, NotificationChannel.email),
        isFalse,
      );
      expect(state.saving, isEmpty);
    });

    test('a failed write puts the switch back', () async {
      await container.read(notificationPreferencesProvider.future);
      repository.fail = true;

      await expectLater(
        container
            .read(notificationPreferencesProvider.notifier)
            .setMaster(NotificationChannel.email, false),
        throwsA(isA<ApiException>()),
      );

      final state = container.read(notificationPreferencesProvider).value!;
      expect(state.preferences.emailEnabled, isTrue);
      expect(state.saving, isEmpty);
    });

    test('a second tap on a switch already saving is ignored', () async {
      await container.read(notificationPreferencesProvider.future);
      final notifier =
          container.read(notificationPreferencesProvider.notifier);

      await Future.wait([
        notifier.setMaster(NotificationChannel.push, false),
        notifier.setMaster(NotificationChannel.push, false),
      ]);

      expect(repository.writes, ['master.push=false']);
    });
  });
}
