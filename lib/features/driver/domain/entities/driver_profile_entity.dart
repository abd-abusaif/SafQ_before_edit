// features/driver/domain/entities/driver_profile_entity.dart

// ── معلومات السائق ────────────────────────────────────────────────────────────
class DriverInfoEntity {
  final String fullName;
  final String firstName;
  final String idNumber;
  final String phone1;
  final String? phone2;
  final String licenseNumber;
  final String licenseGrade;
  final String licenseExpiry;
  final String medicalExpiry;

  const DriverInfoEntity({
    required this.fullName,
    required this.firstName,
    required this.idNumber,
    required this.phone1,
    this.phone2,
    required this.licenseNumber,
    required this.licenseGrade,
    required this.licenseExpiry,
    required this.medicalExpiry,
  });

  factory DriverInfoEntity.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] ?? '';
    final parts = fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : fullName;
    return DriverInfoEntity(
      fullName: fullName,
      firstName: json['first_name'] ?? firstName,
      idNumber: json['id_number'] ?? '',
      phone1: json['phone1'] ?? '',
      phone2: json['phone2'],
      licenseNumber: json['license_number'] ?? '',
      licenseGrade: json['license_grade'] ?? '',
      licenseExpiry: json['license_expiry'] ?? '',
      medicalExpiry: json['medical_expiry'] ?? '',
    );
  }
}

// ── معلومات الخط ──────────────────────────────────────────────────────────────
class LineInfoEntity {
  final String lineNumber;
  final String lineName;
  final String lineFrom;
  final String lineTo;
  final String route;
  final String passengerFare;

  const LineInfoEntity({
    required this.lineNumber,
    required this.lineName,
    required this.lineFrom,
    required this.lineTo,
    required this.route,
    required this.passengerFare,
  });

  factory LineInfoEntity.fromJson(Map<String, dynamic> json) {
    return LineInfoEntity(
      lineNumber: json['line_number'] ?? '',
      lineName: json['line_name'] ?? '',
      lineFrom: json['line_from'] ?? '',
      lineTo: json['line_to'] ?? '',
      route: json['route'] ?? '',
      passengerFare: json['passenger_fare'] ?? '',
    );
  }
}

// ── معلومات المالك ────────────────────────────────────────────────────────────
class OwnerInfoEntity {
  final String ownerName;
  final String ownerId;
  final String ownerPhone;

  const OwnerInfoEntity({
    required this.ownerName,
    required this.ownerId,
    required this.ownerPhone,
  });

  factory OwnerInfoEntity.fromJson(Map<String, dynamic> json) {
    return OwnerInfoEntity(
      ownerName: json['owner_name'] ?? '',
      ownerId: json['owner_id'] ?? '',
      ownerPhone: json['owner_phone'] ?? '',
    );
  }
}

// ── معلومات المركبة ───────────────────────────────────────────────────────────
class VehicleInfoEntity {
  final String vehicleNumber;
  final String vehicleCode;
  final String chassisNumber;
  final String company;
  final String model;
  final String productionYear;
  final String seats;
  final String operationExpiry;
  final String vehicleLicExpiry;
  final String insuranceExpiry;
  final bool loadingAllowed;

  const VehicleInfoEntity({
    required this.vehicleNumber,
    required this.vehicleCode,
    required this.chassisNumber,
    required this.company,
    required this.model,
    required this.productionYear,
    required this.seats,
    required this.operationExpiry,
    required this.vehicleLicExpiry,
    required this.insuranceExpiry,
    required this.loadingAllowed,
  });

  factory VehicleInfoEntity.fromJson(Map<String, dynamic> json) {
    return VehicleInfoEntity(
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleCode: json['vehicle_code'] ?? '',
      chassisNumber: json['chassis_number'] ?? '',
      company: json['company'] ?? '',
      model: json['model'] ?? '',
      productionYear: json['production_year']?.toString() ?? '',
      seats: json['seats']?.toString() ?? '',
      operationExpiry: json['operation_expiry'] ?? '',
      vehicleLicExpiry: json['vehicle_lic_expiry'] ?? '',
      insuranceExpiry: json['insurance_expiry'] ?? '',
      loadingAllowed: json['loading_allowed'] ?? true,
    );
  }
}
