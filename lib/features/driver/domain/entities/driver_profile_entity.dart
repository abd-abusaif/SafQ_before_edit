// ← معلومات السائق
class DriverInfoEntity {
  final String fullName;
  final String idNumber;
  final String phone1;
  final String? phone2; // ← رقم هاتف 2 (اختياري)
  final String licenseNumber;
  final String licenseGrade; // ← درجة الرخصة
  final String licenseExpiry;
  final String medicalExpiry;

  const DriverInfoEntity({
    required this.fullName,
    required this.idNumber,
    required this.phone1,
    this.phone2,
    required this.licenseNumber,
    required this.licenseGrade,
    required this.licenseExpiry,
    required this.medicalExpiry,
  });

  factory DriverInfoEntity.fromJson(Map<String, dynamic> json) {
    return DriverInfoEntity(
      fullName: json['full_name'] ?? '',
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

// ← معلومات الخط
class LineInfoEntity {
  final String lineNumber; // ← رقم مجرى الخط
  final String lineName; // ← اسم الخط (بيت لحم - الخليل)
  final String passengerFare; // ← أجرة الراكب

  const LineInfoEntity({
    required this.lineNumber,
    required this.lineName,
    required this.passengerFare,
  });

  factory LineInfoEntity.fromJson(Map<String, dynamic> json) {
    return LineInfoEntity(
      lineNumber: json['line_number'] ?? '',
      lineName: json['line_name'] ?? '',
      passengerFare: json['passenger_fare'] ?? '',
    );
  }
}

// ← معلومات المركبة
class VehicleInfoEntity {
  final String vehicleNumber; // ← رقم المركبة
  final String vehicleCode; // ← رقم كود السيارة
  final String model; // ← الموديل
  final String driverType; // ← نوع السائق
  final String seats; // ← عدد المقاعد
  final String operationExpiry; // ← انتهاء رخصة التشغيل
  final String vehicleLicExpiry; // ← انتهاء رخصة السيارة
  final String insuranceExpiry; // ← انتهاء تأمين السيارة
  final String? chassisNumber; // ← رقم الشاصي (يضيفه الأدمن)

  const VehicleInfoEntity({
    required this.vehicleNumber,
    required this.vehicleCode,
    required this.model,
    required this.driverType,
    required this.seats,
    required this.operationExpiry,
    required this.vehicleLicExpiry,
    required this.insuranceExpiry,
    this.chassisNumber,
  });

  factory VehicleInfoEntity.fromJson(Map<String, dynamic> json) {
    return VehicleInfoEntity(
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleCode: json['vehicle_code'] ?? '',
      model: json['model'] ?? '',
      driverType: json['driver_type'] ?? '',
      seats: json['seats']?.toString() ?? '',
      operationExpiry: json['operation_expiry'] ?? '',
      vehicleLicExpiry: json['vehicle_lic_expiry'] ?? '',
      insuranceExpiry: json['insurance_expiry'] ?? '',
      chassisNumber: json['chassis_number'],
    );
  }
}
