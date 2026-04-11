// domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String idNumber, // identification number
    required String password,
    required String role,
  });

  Future<void> logout();
}
