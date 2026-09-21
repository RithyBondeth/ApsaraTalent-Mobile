import 'package:apsaratalent_mobile/core/utils/media_url.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    dotenv.loadFromString(envString: 'API_BASE_URL=http://127.0.0.1:3000');
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('a server-relative path is resolved against the API base', () {
    // `/user/moderation/blocked` answers `/avatars/default.png`, which
    // Image.network cannot load on its own.
    expect(
      resolveMediaUrl('/avatars/default.png'),
      'http://127.0.0.1:3000/avatars/default.png',
    );
  });

  test('a path without a leading slash still resolves', () {
    expect(
      resolveMediaUrl('avatars/default.png'),
      'http://127.0.0.1:3000/avatars/default.png',
    );
  });

  test('an absolute URL is left exactly as it is', () {
    const url = 'https://cdn.example.com/a.png';
    expect(resolveMediaUrl(url), url);
    expect(resolveMediaUrl('http://cdn.example.com/a.png'),
        'http://cdn.example.com/a.png');
  });

  test('nothing in means nothing out', () {
    expect(resolveMediaUrl(null), isNull);
    expect(resolveMediaUrl(''), isNull);
    expect(resolveMediaUrl('   '), isNull);
  });
}
