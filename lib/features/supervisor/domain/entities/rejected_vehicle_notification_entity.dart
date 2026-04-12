// features/supervisor/domain/entities/rejected_vehicle_notification_entity.dart

/// إشعار مركبة محظورة — يصل للمشرف والأمن والأدمن
class RejectedVehicleNotificationEntity {
  final String id;
  final String driverName;
  final String vehiclePlate;
  final String lineName;
  final String entryTime;
  final bool isHandled; // false=أحمر | true=أخضر (تم التعامل)

  const RejectedVehicleNotificationEntity({
    required this.id,
    required this.driverName,
    required this.vehiclePlate,
    required this.lineName,
    required this.entryTime,
    required this.isHandled,
  });

  RejectedVehicleNotificationEntity copyWith({bool? isHandled}) {
    return RejectedVehicleNotificationEntity(
      id: id,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      lineName: lineName,
      entryTime: entryTime,
      isHandled: isHandled ?? this.isHandled,
    );
  }

  factory RejectedVehicleNotificationEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return RejectedVehicleNotificationEntity(
      id: json['id'] ?? '',
      driverName: json['driver_name'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      lineName: json['line_name'] ?? '',
      entryTime: json['entry_time'] ?? '',
      isHandled: json['is_handled'] ?? false,
    );
  }
}
