/// The secret a user adds to an authenticator app to turn on 2FA.
class TwoFactorSetup {
  const TwoFactorSetup({required this.secret, required this.otpAuthUrl});

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) => TwoFactorSetup(
        secret: '${json['secret'] ?? ''}',
        // The API names it `qrCodeUrl`, but it is the `otpauth://` URI itself,
        // not an image — which is what a phone wants anyway, since the camera
        // that would scan a QR code is the one showing it.
        otpAuthUrl: '${json['qrCodeUrl'] ?? ''}',
      );

  final String secret;
  final String otpAuthUrl;

  /// The secret split into fours, for reading off one screen and typing into
  /// another.
  String get groupedSecret => secret
      .replaceAllMapped(RegExp('.{1,4}'), (m) => '${m.group(0)} ')
      .trim();
}
