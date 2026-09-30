import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/career_scope/data/career_scope_repository.dart';

final careerScopeRepositoryProvider =
    Provider((ref) => CareerScopeRepository(ref.watch(apiClientProvider)));
final careerScopesProvider = FutureProvider.autoDispose<List<CareerScope>>(
    (ref) => ref.watch(careerScopeRepositoryProvider).all());
