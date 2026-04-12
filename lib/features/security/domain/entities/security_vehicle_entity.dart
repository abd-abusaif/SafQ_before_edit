// features/security/domain/entities/security_vehicle_entity.dart

class SecurityVehicleEntity {
  final String id;
  final String driverName;
  final String vehiclePlate;
  final String lineFrom;
  final String lineTo;
  final String entryTime;
  final int queuePosition;
  final bool isApproved;
  final String? rejectionReason;
  final DateTime entryDateTime;
  final bool isHandled; // false=أحمر (يحتاج تدخل) | true=أخضر (تم التعامل)

  const SecurityVehicleEntity({
    required this.id,
    required this.driverName,
    required this.vehiclePlate,
    required this.lineFrom,
    required this.lineTo,
    required this.entryTime,
    required this.queuePosition,
    required this.isApproved,
    this.rejectionReason,
    required this.entryDateTime,
    this.isHandled = false,
  });

  SecurityVehicleEntity copyWith({bool? isHandled}) {
    return SecurityVehicleEntity(
      id: id,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      lineFrom: lineFrom,
      lineTo: lineTo,
      entryTime: entryTime,
      queuePosition: queuePosition,
      isApproved: isApproved,
      rejectionReason: rejectionReason,
      entryDateTime: entryDateTime,
      isHandled: isHandled ?? this.isHandled,
    );
  }

  factory SecurityVehicleEntity.fromJson(Map<String, dynamic> json) {
    return SecurityVehicleEntity(
      id: json['id'] ?? '',
      driverName: json['driver_name'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      lineFrom: json['line_from'] ?? '',
      lineTo: json['line_to'] ?? '',
      entryTime: json['entry_time'] ?? '',
      queuePosition: json['queue_position'] ?? 0,
      isApproved: json['is_approved'] ?? false,
      rejectionReason: json['rejection_reason'],
      entryDateTime:
          DateTime.tryParse(json['entry_date_time'] ?? '') ?? DateTime.now(),
      isHandled: json['is_handled'] ?? false,
    );
  }
}
