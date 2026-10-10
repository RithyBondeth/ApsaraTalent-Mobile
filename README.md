# Apsara Talent Mobile

Flutter client for Apsara Talent, with shared account resumes, discovery, applications, messaging, dashboards, administration, and English/Khmer support.

## Develop and verify

```sh
flutter pub get
flutter analyze
flutter test
dart run tool/check_localization.dart
node scripts/contracts/generate-clients.mjs --check
flutter run --dart-define=APP_ENV=development
```

Use the sibling workspace's `local-test/mobile_main.dart` to connect to its disposable gateway on port 13000. Android emulators map loopback to `10.0.2.2` automatically.

## Android production identity and push

1. Copy `android/key.properties.example` to `android/key.properties`. Set the existing Play application ID and upload keystore path, alias, and passwords. Paths are relative to `android/`; an absolute keystore path also works. CI can instead supply `APSARA_ANDROID_APP_ID`, `APSARA_UPLOAD_STORE_FILE`, `APSARA_UPLOAD_STORE_PASSWORD`, `APSARA_UPLOAD_KEY_ALIAS`, and `APSARA_UPLOAD_KEY_PASSWORD`.
2. Install the matching Firebase Android app's `google-services.json` at `android/app/google-services.json`. The Google Services plugin selects the client matching the application ID.
3. Build with `flutter build appbundle --release --dart-define=APP_ENV=production`. The release gate rejects placeholder IDs, missing upload signing, and missing Firebase configuration. Release builds never fall back to the debug signing key.

Keep all signing material and machine-local configuration out of Git. Configure Firebase Cloud Messaging credentials on the backend separately.

## iOS production identity and push

1. Copy `ios/Flutter/ReleaseIdentity.xcconfig.example` to `ios/Flutter/ReleaseIdentity.xcconfig`. Set the existing App Store bundle ID and Apple development team.
2. Install its Firebase `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`. The build checks its bundle ID and copies it into the app bundle. Device Release/Profile builds require registered identity, team, and Firebase configuration.
3. In the Apple developer account enable Push Notifications and Associated Domains for that app, and install the appropriate signing certificate/provisioning profile. Upload the Apple APNs key to the same Firebase project.
4. Build with `flutter build ipa --release --dart-define=APP_ENV=production`. Debug entitlements use development APNs and release entitlements use production APNs.

Debug simulators can run without Firebase or a signing identity. A successful simulator build does not validate store signing or push delivery.

## HTTPS app links

Both platforms declare `talent.apsara.social` for public job links (`/jobs/<id>`), `/unsubscribe?token=...`, and `/reset-password?token=...`. Flutter routes these links; the existing custom scheme continues to handle OAuth callbacks. The web deployment must publish association files using the **same** registered IDs, the Play app-signing SHA-256 fingerprint, and the Apple application identifier prefix; see the web README.

After installing a correctly signed build, verify associations on the device:

```sh
adb shell pm verify-app-links --re-verify <registered-application-id>
adb shell pm get-app-links <registered-application-id>
adb shell am start -W -a android.intent.action.VIEW -d 'https://talent.apsara.social/jobs/<real-job-id>'
```

On iPhone, open a job link from Notes/Mail, then test reset and unsubscribe links without exposing real tokens in logs. A user can choose to open links in the browser; typing a URL into Safari is not a universal-link acceptance test.

## Real cross-platform acceptance

Start the sibling workspace's isolated stack on web port 14000. From the web repository run `ACCEPTANCE_DEVICE=<simulator-or-emulator-id> npm run test:acceptance:local`. The browser runner invokes `integration_test/local_journeys_test.dart` with a unique disposable resume and checks browser → native → browser edits, design preservation, conflict protection, dashboard entry, and Khmer navigation.

This opt-in test is restricted to the loopback fixture. Normal `flutter test` remains independent of live services. Before store submission, test a provisioned iPhone and a physical Android device for push delivery/opening in foreground/background/terminated states, OAuth provider callbacks, camera/files, voice notes and calls. These external integrations require real provider configuration and are not established by local fixture tests.
