import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/social_auth_browser.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/social_auth_result.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/auth_login_method_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialAuthBrowserProvider = Provider<SocialAuthBrowser>(
  (_) => const SystemSocialAuthBrowser(),
);

final socialAuthProvider =
    AsyncNotifierProvider<SocialAuthNotifier, SocialAuthResult?>(
        SocialAuthNotifier.new);

class SocialAuthNotifier extends AsyncNotifier<SocialAuthResult?> {
  @override
  Future<SocialAuthResult?> build() async => null;

  Future<void> signIn(EAuthLoginMethod provider) async {
    if (!const {
      EAuthLoginMethod.google,
      EAuthLoginMethod.github,
      EAuthLoginMethod.facebook,
      EAuthLoginMethod.linkedin,
    }.contains(provider)) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final remember = ref.read(rememberMeProvider);
      final base = Uri.parse(AppConfigService.apiBaseUrl);
      final loginUri = base.resolve('/social/${provider.value}/login');
      final callback = Uri.parse(
        await ref.read(socialAuthBrowserProvider).authenticate(
              loginUri.replace(queryParameters: {
                'remember': '$remember',
                'mobile': 'true',
                'redirect_uri': 'apsaratalent://oauth/callback',
              }).toString(),
            ),
      );
      _validateCallback(callback);

      switch (callback.queryParameters['status']) {
        case 'success':
          final code = callback.queryParameters['code'];
          if (code == null || code.isEmpty) {
            throw ApiException(
                message: 'The provider returned no sign-in code.');
          }
          await ref
              .read(authRepositoryProvider)
              .exchangeSocialCode(code, remember: remember);
          await ref.read(authSessionProvider.notifier).establish();
          return const SocialAuthResult.authenticated();
        case 'new_user':
          return SocialAuthResult.newUser(
            SocialAuthProfile(
              provider: callback.queryParameters['provider'] ?? provider.value,
              email: callback.queryParameters['email'],
              firstName: callback.queryParameters['firstname'],
              lastName: callback.queryParameters['lastname'],
              picture: callback.queryParameters['picture'],
            ),
          );
        default:
          throw ApiException(
            message: callback.queryParameters['error'] ??
                'Authentication was cancelled or failed.',
          );
      }
    });
  }

  void clear() => state = const AsyncData(null);

  static void _validateCallback(Uri callback) {
    if (callback.scheme != 'apsaratalent' ||
        callback.host != 'oauth' ||
        callback.path != '/callback') {
      throw ApiException(message: 'The provider returned an invalid callback.');
    }
  }
}
