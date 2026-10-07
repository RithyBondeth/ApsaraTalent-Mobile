import 'package:apsaratalent_mobile/core/configs/environment.dart';
import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EEnvironmentType resolve(String define, {bool debug = false}) =>
      AppEnvironmentConfig.resolve(define, debug: debug);

  group('without APP_ENV', () {
    test('a debug build talks to the local API', () {
      expect(resolve('', debug: true), EEnvironmentType.development);
    });

    test('anything else is production', () {
      // Profile and release builds run on real devices, where the local
      // loopback API does not exist.
      expect(resolve('', debug: false), EEnvironmentType.production);
    });
  });

  group('with APP_ENV', () {
    test('it wins over the build mode, either way', () {
      expect(resolve('staging', debug: true), EEnvironmentType.staging);
      expect(
          resolve('development', debug: false), EEnvironmentType.development);
      expect(resolve('production', debug: true), EEnvironmentType.production);
    });

    test('case and surrounding space are forgiven', () {
      expect(resolve(' Staging '), EEnvironmentType.staging);
    });

    test('a misspelt value throws instead of guessing', () {
      expect(() => resolve('prod'), throwsArgumentError);
      expect(() => resolve('prodution', debug: true), throwsArgumentError);
    });
  });

  test('production reads .env, which points at the deployed API', () {
    addTearDown(() =>
        AppEnvironmentConfig.setEnvironment(EEnvironmentType.development));

    AppEnvironmentConfig.setEnvironment(EEnvironmentType.production);
    expect(AppEnvironmentConfig.envFileName, '.env');

    AppEnvironmentConfig.setEnvironment(EEnvironmentType.development);
    expect(AppEnvironmentConfig.envFileName, '.env.development');
  });
}
