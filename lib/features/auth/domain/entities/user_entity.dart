// domain/entities/user_entity.dart

// Base class - مبدأ الوراثة
abstract class UserEntity {
  final String id;
  final String username;
  final String role; // 'driver' | 'supervisor' | 'security'

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
  });
}

class DriverEntity extends UserEntity {
  final String licenseNumber;
  const DriverEntity({
    required super.id,
    required super.username,
    required this.licenseNumber,
  }) : super(role: 'driver');
}

class SupervisorEntity extends UserEntity {
  final String lineNumber;
  const SupervisorEntity({
    required super.id,
    required super.username,
    required this.lineNumber,
  }) : super(role: 'supervisor');
}

class SecurityEntity extends UserEntity {
  final String gateId;
  const SecurityEntity({
    required super.id,
    required super.username,
    required this.gateId,
  }) : super(role: 'security');
}
