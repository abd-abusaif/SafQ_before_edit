import '../entities/security_vehicle_entity.dart';

abstract class SecurityRepository {
  Future<List<SecurityVehicleEntity>> getVehicles(String idNumber);
  Future<void> markAsHandled(String vehicleId);
}
