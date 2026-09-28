import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:apsaratalent_mobile/core/constants/apis/notification_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'push_bootstrap.dart';

abstract class PushMessagingClient {
  Future<bool> authorize();
  Future<String?> token();
  Future<void> deleteToken();
}

class FirebasePushMessagingClient implements PushMessagingClient {
  FirebasePushMessagingClient([FirebaseMessaging? messaging])
      : messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging messaging;

  @override
  Future<bool> authorize() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return false;
    }
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
    if ((Platform.isIOS || Platform.isMacOS) &&
        await messaging.getAPNSToken() == null) {
      return false;
    }
    return true;
  }

  @override
  Future<String?> token() => messaging.getToken();

  @override
  Future<void> deleteToken() => messaging.deleteToken();
}

class PushTokenService {
  PushTokenService(this.api, {PushMessagingClient? messaging})
      : messaging = messaging ?? FirebasePushMessagingClient();

  final ApiClient api;
  final PushMessagingClient messaging;
  String? _registeredToken;

  Future<void> register() async {
    if (!PushBootstrap.available) return;
    if (!await messaging.authorize()) return;
    final token = await messaging.token();
    if (token == null || token.isEmpty) return;
    await registerToken(token);
  }

  Future<void> registerToken(String token) async {
    if (!PushBootstrap.available || token == _registeredToken) return;
    await api.put(apiNotificationDeviceToken, data: {'token': token});
    _registeredToken = token;
  }

  Future<void> unregister() async {
    if (!PushBootstrap.available) return;
    String? token = _registeredToken;
    try {
      token ??= await messaging.token();
      if (token != null && token.isNotEmpty) {
        await api.delete(apiNotificationDeviceToken, data: {'token': token});
      }
    } catch (_) {
      // Sign-out must continue offline. Deleting the local FCM token below
      // invalidates the stale server registration at Firebase.
    }
    try {
      await messaging.deleteToken();
    } catch (_) {
      // Firebase may not have issued a token for this installation.
    }
    _registeredToken = null;
  }
}
