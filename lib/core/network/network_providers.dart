import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in user's tokens. One instance for the life of the app: the API
/// client, the refresher and the auth feature must all see the same pair.
final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(sessionStore: ref.watch(sessionStoreProvider));
});
