// features/supervisor/domain/entities/supervisor_stats_entity.dart

class SupervisorStatsEntity {
  final int activeVehicles;
  final int waitingVehicles;
  final int completedTrips;

  const SupervisorStatsEntity({
    required this.activeVehicles,
    required this.waitingVehicles,
    required this.completedTrips,
  });

  factory SupervisorStatsEntity.fromJson(Map<String, dynamic> json) {
    return SupervisorStatsEntity(
      activeVehicles: json['active_vehicles'] ?? 0,
      waitingVehicles: json['waiting_vehicles'] ?? 0,
      completedTrips: json['completed_trips'] ?? 0,
    );
  }
}
