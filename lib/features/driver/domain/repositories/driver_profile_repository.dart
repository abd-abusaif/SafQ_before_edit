// features/driver/domain/repositories/driver_profile_repository.dart

import '../entities/driver_profile_entity.dart';

abstract class DriverProfileRepository {
  Future<DriverInfoEntity> getDriverInfo(String idNumber);
  Future<LineInfoEntity> getLineInfo(String idNumber);
  Future<OwnerInfoEntity> getOwnerInfo(String idNumber);
  Future<VehicleInfoEntity> getVehicleInfo(String idNumber);
}
