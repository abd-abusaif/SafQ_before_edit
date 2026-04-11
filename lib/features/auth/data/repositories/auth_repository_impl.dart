// data/repositories/auth_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // لاحقاً سيتم ربطه مع API حقيقي
  // final ApiService _apiService;

  @override
  Future<UserEntity> login({
    required String idNumber,
    required String password,
    required String role,
  }) async {
    // TODO: استبدل هذا بـ HTTP request حقيقي
    await Future.delayed(const Duration(seconds: 1)); // Simulate API

    switch (role) {
      case 'driver':
        return DriverEntity(
          id: idNumber,
          username: 'عبدالرحمن أبو سيف', // ← اسمك
          licenseNumber: 'LIC-001',
        );
      case 'supervisor':
        return SupervisorEntity(
          id: '2',
          username: idNumber,
          lineNumber: 'Line-5',
        );
      case 'security':
        return SecurityEntity(id: '3', username: idNumber, gateId: 'Gate-A');
      default:
        throw Exception('Invalid role');
    }
  }

  @override
  Future<void> logout() async {
    // TODO: clear token
  }
}
