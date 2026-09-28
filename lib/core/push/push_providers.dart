import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'push_token_service.dart';

final pushTokenServiceProvider = Provider<PushTokenService>(
  (ref) => PushTokenService(ref.watch(apiClientProvider)),
);
