// Use case for loading the signed-in user
import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<CurrentUserEntity> call() => _repository.getCurrentUser();
}
