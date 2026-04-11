import '../entities/supervisor_entity.dart';
import '../entities/supervisor_stats_entity.dart';
import '../entities/supervisor_vehicle_entity.dart';

abstract class SupervisorRepository {
  Future<SupervisorStatsEntity> getStats(String idNumber, String lineId);
  Future<List<SupervisorVehicleEntity>> getVehicles(
    String idNumber,
    String lineId,
  );
  Future<List<String>> getMyLines(String idNumber);
  Future<SupervisorProfileEntity> getProfile(String idNumber);
}
