class SupervisorVehicleEntity {
  final String driverName;
  final String vehiclePlate;
  final String lineFrom;
  final String lineTo;
  final String entryTime;
  final int queuePosition;
  final bool isApproved;
  final String? rejectionReason;

  const SupervisorVehicleEntity({
    required this.driverName,
    required this.vehiclePlate,
    required this.lineFrom,
    required this.lineTo,
    required this.entryTime,
    required this.queuePosition,
    required this.isApproved,
    this.rejectionReason,
  });

  factory SupervisorVehicleEntity.fromJson(Map<String, dynamic> json) {
    return SupervisorVehicleEntity(
      driverName: json['driver_name'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      lineFrom: json['line_from'] ?? '',
      lineTo: json['line_to'] ?? '',
      entryTime: json['entry_time'] ?? '',
      queuePosition: json['queue_position'] ?? 0,
      isApproved: json['is_approved'] ?? false,
      rejectionReason: json['rejection_reason'],
    );
  }
}
