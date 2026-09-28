import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/ai_match_tools_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiMatchToolsRepositoryProvider = Provider<AiMatchToolsRepository>(
  (ref) => AiMatchToolsRepository(ref.watch(apiClientProvider)),
);
