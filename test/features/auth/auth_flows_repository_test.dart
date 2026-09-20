import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  late SessionStore store;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
  });

  AuthRepositoryImpl repositoryFor(FakeHttp http) => AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(ApiClient(
          sessionStore: store,
          baseUrl: 'http://api.test',
          adapter: http,
        )),
        sessionStore: store,
      );

  final created = {
    'message': 'Registered. Please verify your email.',
    'user': {'id': 'u1', 'role': 'employee', 'email': 'new@example.com'},
  };

  EmployeeRegistration employee() => EmployeeRegistration(
        email: ' new@example.com ',
        password: 'Password123!',
        firstname: 'Sok',
        lastname: 'Dara',
        username: 'sokdara',
        gender: 'male',
        dob: DateTime(1998, 3, 7, 23, 30),
        location: 'Phnom Penh',
        job: 'Backend Engineer',
        yearsOfExperience: '3 - 5 years',
        availability: 'full_time',
        careerScopes: ['Backend Development'],
        skills: ['NestJS'],
        description: 'I build APIs.',
      );

  group('registration', () {
    test('employee: the web payload shape, and a remembered session', () async {
      final http = FakeHttp((_) async =>
          jsonResponse(201, created, setCookies: authCookies('access', 'refresh')));

      await repositoryFor(http).registerEmployee(employee());

      final request = http.requests.single;
      expect(request.path, '/auth/register-employee');
      final body = request.data as Map<String, dynamic>;
      expect(body['authEmail'], isTrue);
      expect(body['email'], 'new@example.com');
      // A birthday is a date: UTC midnight, never a local time that could
      // cross midnight in another zone.
      expect(body['dob'], '1998-03-07T00:00:00.000Z');
      expect(body['skills'], [{'name': 'NestJS', 'description': 'NestJS'}]);
      expect(body['careerScopes'], [
        {'name': 'Backend Development', 'description': 'Backend Development'},
      ]);
      expect(body.containsKey('phone'), isFalse, reason: 'empty optionals are omitted');

      expect(store.hasSession, isTrue);
      expect(await SessionStore().restore(), isNotNull,
          reason: 'a new account survives a restart before it is verified');
    });

    test('company: open positions go in `jobs`, the key the API reads', () async {
      final http = FakeHttp((_) async =>
          jsonResponse(201, created, setCookies: authCookies('access', 'refresh')));

      await repositoryFor(http).registerCompany(const CompanyRegistration(
        email: 'hr@example.com',
        password: 'Password123!',
        name: 'Angkor Labs',
        description: 'We build things.',
        industry: 'Technology',
        location: 'Siem Reap',
        companySize: 40,
        foundedYear: 2019,
        careerScopes: ['Software Engineering'],
        websiteUrl: '',
      ));

      final body = http.requests.single.data as Map<String, dynamic>;
      expect(http.requests.single.path, '/auth/register-company');
      expect(body['companySize'], 40);
      expect(body['foundedYear'], 2019);
      expect(body.containsKey('jobs'), isTrue);
      expect(body.containsKey('openPositions'), isFalse);
      expect(body.containsKey('websiteUrl'), isFalse);
      expect(body['careerScopes'], [{'name': 'Software Engineering'}]);
    });

    test('a duplicate email surfaces the API message and stores nothing', () async {
      final http = FakeHttp((_) async =>
          jsonResponse(401, {'message': 'This credential already registered!'}));

      await expectLater(
        repositoryFor(http).registerEmployee(employee()),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('already registered'))),
      );
      expect(store.hasSession, isFalse);
    });
  });

  group('email verification', () {
    test('verify sends the address and code', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'message': 'verified'}));

      final message = await repositoryFor(http).verifyEmail('a@b.dev', '123456');

      expect(http.requests.single.path, '/auth/verify-email');
      expect(http.requests.single.data, {'email': 'a@b.dev', 'otp': '123456'});
      expect(message, 'verified');
    });

    test('resend goes to its own endpoint', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'message': 'sent'}));
      await repositoryFor(http).resendEmailOtp('a@b.dev');
      expect(http.requests.single.path, '/auth/verify-email/resend');
      expect(http.requests.single.data, {'email': 'a@b.dev'});
    });
  });

  group('password reset', () {
    test('forgot password sends `identifier`', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'message': 'sent'}));
      await repositoryFor(http).forgotPassword('012345678');
      expect(http.requests.single.path, '/auth/forgot-password');
      expect(http.requests.single.data, {'identifier': '012345678'});
    });

    test('reset puts the token in the path, encoded, and both passwords in the body', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'message': 'updated'}));

      await repositoryFor(http).resetPassword(
        token: 'ab/cd+ef',
        newPassword: 'Password123!',
        confirmPassword: 'Password123!',
      );

      final request = http.requests.single;
      expect(request.uri.path, '/auth/reset-password/ab%2Fcd%2Bef');
      expect(request.data, {'newPassword': 'Password123!', 'confirmPassword': 'Password123!'});
      expect(request.headers['Authorization'], isNull);
    });
  });

  group('phone sign-in', () {
    test('code request and verification, which stores the session', () async {
      final http = FakeHttp((r) async => r.path == '/auth/verify-otp'
          ? jsonResponse(200, created, setCookies: authCookies('access', 'refresh'))
          : jsonResponse(200, {'message': 'OTP sent'}));
      final repo = repositoryFor(http);

      await repo.requestPhoneOtp('+85512000001');
      await repo.verifyPhoneOtp('+85512000001', '654321', remember: false);

      expect(http.requests.map((r) => r.path), ['/auth/login-otp', '/auth/verify-otp']);
      expect(http.requests.last.data, {'phone': '+85512000001', 'otp': '654321'});
      expect(store.hasSession, isTrue);
    });
  });

  group('two-step verification settings', () {
    test('setup reads the secret and the otpauth URI', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {
            'message': 'scan',
            'secret': 'JBSWY3DPEHPK3PXP',
            'qrCodeUrl': 'otpauth://totp/Apsara:a@b.dev?secret=JBSWY3DPEHPK3PXP',
          }));

      final setup = await repositoryFor(http).setupTwoFactor();

      expect(setup.secret, 'JBSWY3DPEHPK3PXP');
      expect(setup.groupedSecret, 'JBSW Y3DP EHPK 3PXP');
      expect(setup.otpAuthUrl, startsWith('otpauth://'));
    });

    test('enable and disable send only the code', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'message': 'ok'}));
      final repo = repositoryFor(http);

      await repo.enableTwoFactor('111111');
      await repo.disableTwoFactor('222222');

      expect(http.requests.map((r) => r.path), ['/auth/2fa/enable', '/auth/2fa/disable']);
      expect(http.requests.map((r) => r.data), [
        {'otp': '111111'},
        {'otp': '222222'},
      ]);
    });
  });
}
