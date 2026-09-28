import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Local builds intentionally run without Firebase platform credentials.
  }
}

class PushBootstrap {
  PushBootstrap._();

  static bool available = false;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    try {
      await Firebase.initializeApp();
      available = true;
    } catch (_) {
      // Firebase becomes available once google-services.json and
      // GoogleService-Info.plist are installed for the target environment.
    }
  }
}
