// features/driver/domain/repositories/violation_repository.dart

import '../entities/violation_entity.dart';

abstract class ViolationRepository {
  Future<List<ViolationEntity>> getMyViolations(String idNumber);
}
