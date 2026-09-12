import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:dio/dio.dart';
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

  final signedIn = {
    'message': 'Successfully Logged in',
    'user': {'id': 'user-1', 'role': 'employee', 'email': 'a@b.dev'},
  };

  test('login sends `identifier`, which is what the API validates', () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, signedIn, setCookies: authCookies('access', 'refresh')));

    await repositoryFor(http).login('a@b.dev', 'pw', remember: false);

    expect(http.requests.single.path, '/auth/login');
    expect(http.requests.single.data, {'identifier': 'a@b.dev', 'password': 'pw'});
  });

  test('login keeps the session from Set-Cookie, remembered on request',
      () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, signedIn, setCookies: authCookies('access', 'refresh')));

    await repositoryFor(http).login('a@b.dev', 'pw', remember: true);

    expect(store.tokens,
        const AuthTokens(accessToken: 'access', refreshToken: 'refresh'));
    expect(await SessionStore().restore(), isNotNull);
  });

  test('a two-factor step stores nothing and returns its token', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'message': 'Two-factor authentication required',
          'requiresTwoFactor': true,
          'twoFactorToken': '2fa-token',
        }));

    final response =
        await repositoryFor(http).login('a@b.dev', 'pw', remember: true);

    expect(response.requiresTwoFactor, isTrue);
    expect(response.twoFactorToken, '2fa-token');
    expect(store.hasSession, isFalse);
  });

  test('two-factor verification sends the token and code, then keeps the session',
      () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, signedIn, setCookies: authCookies('access', 'refresh')));

    await repositoryFor(http)
        .verifyTwoFactor('2fa-token', '123456', remember: false);

    expect(http.requests.single.path, '/auth/2fa/verify-login');
    expect(http.requests.single.data, {'twoFactorToken': '2fa-token', 'otp': '123456'});
    expect(store.hasSession, isTrue);
  });

  test('a "success" with no session cookies is a failure, not a signed-in user',
      () async {
    final http = FakeHttp((_) async => jsonResponse(200, signedIn));

    await expectLater(
      repositoryFor(http).login('a@b.dev', 'pw', remember: false),
      throwsA(isA<ApiException>()),
    );
    expect(store.hasSession, isFalse);
  });

  test('logout clears the session even when the API cannot be reached',
      () async {
    await store.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
      remember: true,
    );
    final http = FakeHttp((r) async => throw DioException.connectionError(
          requestOptions: r,
          reason: 'offline',
        ));

    await repositoryFor(http).logout();

    expect(store.hasSession, isFalse);
    expect(await SessionStore().restore(), isNull);
  });

  test('current user flattens an employee and a company to one shape',
      () async {
    await store.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
      remember: false,
    );

    final employee = await repositoryFor(FakeHttp((_) async => jsonResponse(200, {
          'id': 'u1',
          'role': 'employee',
          'email': 'sophea@seed.dev',
          'employee': {'firstname': 'Sophea', 'lastname': 'Chan', 'job': 'Frontend Developer'},
        }))).getCurrentUser();
    expect(employee.displayName, 'Sophea Chan');
    expect(employee.headline, 'Frontend Developer');
    expect(employee.role, EUserRole.employee);

    final company = await repositoryFor(FakeHttp((_) async => jsonResponse(200, {
          'id': 'u2',
          'role': 'company',
          'email': 'hr@sabay.dev',
          'company': {'name': 'Sabay Digital', 'industry': 'Technology'},
        }))).getCurrentUser();
    expect(company.displayName, 'Sabay Digital');
    expect(company.headline, 'Technology');

    final unnamed = await repositoryFor(FakeHttp((_) async => jsonResponse(200, {
          'id': 'u3',
          'role': 'employee',
          'email': 'new@seed.dev',
          'employee': {'firstname': '', 'lastname': null},
        }))).getCurrentUser();
    expect(unnamed.displayName, 'new@seed.dev');
  });
}
