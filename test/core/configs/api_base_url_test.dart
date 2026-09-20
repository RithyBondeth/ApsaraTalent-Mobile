import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  void load(String url) => dotenv.loadFromString(envString: 'API_BASE_URL=$url');

  group('on Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('a loopback host becomes the emulator route to the machine', () {
      // 127.0.0.1 inside an emulator is the emulator, not the host running
      // the API, so a development build would reach nothing.
      load('http://127.0.0.1:3000');
      expect(AppConfigService.apiBaseUrl, 'http://10.0.2.2:3000');

      load('http://localhost:3000');
      expect(AppConfigService.apiBaseUrl, 'http://10.0.2.2:3000');
    });

    test('a deployed URL is left alone', () {
      // .env and .env.staging point at Railway. The rewrite must never reach
      // them, whatever the platform.
      const railway = 'https://apsaratalent-api-prod.up.railway.app/';
      load(railway);
      expect(AppConfigService.apiBaseUrl, railway);
    });

    test('a host that merely starts with the loopback name is left alone', () {
      load('https://localhost-staging.example.com/api');
      expect(AppConfigService.apiBaseUrl, 'https://localhost-staging.example.com/api');
    });
  });

  group('on iOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

    test('loopback is kept, because the simulator shares the host network', () {
      load('http://127.0.0.1:3000');
      expect(AppConfigService.apiBaseUrl, 'http://127.0.0.1:3000');
    });
  });
}
