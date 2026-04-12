// features/supervisor/domain/entities/line_detail_entity.dart

/// مركبة مسجّلة على خط معين (من الأدمن)
class LineVehicleEntity {
  final String vehiclePlate;
  final String operatingLicense;
  final String driverName;
  final String driverIdNumber;
  final String driverPhone;
  final String lineName;

  const LineVehicleEntity({
    required this.vehiclePlate,
    required this.operatingLicense,
    required this.driverName,
    required this.driverIdNumber,
    required this.driverPhone,
    required this.lineName,
  });

  factory LineVehicleEntity.fromJson(Map<String, dynamic> json) {
    return LineVehicleEntity(
      vehiclePlate: json['vehicle_plate'] ?? '',
      operatingLicense: json['operating_license'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverIdNumber: json['driver_id_number'] ?? '',
      driverPhone: json['driver_phone'] ?? '',
      lineName: json['line_name'] ?? '',
    );
  }
}

/// تفاصيل خط: أجرة الراكب + قائمة المركبات
class LineDetailEntity {
  final String lineId;
  final String lineName;
  final String passengerFare;
  final List<LineVehicleEntity> vehicles;

  const LineDetailEntity({
    required this.lineId,
    required this.lineName,
    required this.passengerFare,
    required this.vehicles,
  });
}
