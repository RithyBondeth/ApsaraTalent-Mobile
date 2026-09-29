import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

abstract class SocialAuthBrowser {
  Future<String> authenticate(String url);
}

class SystemSocialAuthBrowser implements SocialAuthBrowser {
  const SystemSocialAuthBrowser();

  @override
  Future<String> authenticate(String url) => FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'apsaratalent',
      );
}
