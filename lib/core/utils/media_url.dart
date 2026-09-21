import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';

/// Turns a media path from the API into something `Image.network` can load.
///
/// Some payloads answer an absolute URL and some a server-relative path —
/// `/user/moderation/blocked` returns `/avatars/default.png`. A relative path
/// handed straight to `Image.network` throws, which the avatar catches and
/// quietly renders initials instead, so the picture simply never appears and
/// nothing reports why.
String? resolveMediaUrl(String? path) {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiClient.normalizeBaseUrl(AppConfigService.apiBaseUrl);
  if (base.isEmpty) return null;
  return trimmed.startsWith('/') ? '$base$trimmed' : '$base/$trimmed';
}
