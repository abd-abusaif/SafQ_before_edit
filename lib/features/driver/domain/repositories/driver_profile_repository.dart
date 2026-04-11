import '../entities/driver_profile_entity.dart';

abstract class DriverProfileRepository {
  Future<DriverInfoEntity> getDriverInfo(String idNumber);
  Future<LineInfoEntity> getLineInfo(String idNumber);
  Future<VehicleInfoEntity> getVehicleInfo(String idNumber);
}
