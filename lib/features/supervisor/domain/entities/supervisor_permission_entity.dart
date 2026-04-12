// features/supervisor/domain/entities/supervisor_permission_entity.dart

/// إذن أرسله السائق إلى المشرف — يظهر في صفحة الأذونات لدى المشرف
class SupervisorPermissionEntity {
  final String id;
  final String driverName;
  final String vehiclePlate;
  final String lineName;
  final String duration;
  final String permissionType; // نص حر أرسله السائق
  final String requestDate;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionNote; // ملاحظة المشرف عند الرفض
  final DateTime createdAt;

  const SupervisorPermissionEntity({
    required this.id,
    required this.driverName,
    required this.vehiclePlate,
    required this.lineName,
    required this.duration,
    required this.permissionType,
    required this.requestDate,
    required this.status,
    this.rejectionNote,
    required this.createdAt,
  });

  SupervisorPermissionEntity copyWith({String? status, String? rejectionNote}) {
    return SupervisorPermissionEntity(
      id: id,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      lineName: lineName,
      duration: duration,
      permissionType: permissionType,
      requestDate: requestDate,
      status: status ?? this.status,
      rejectionNote: rejectionNote ?? this.rejectionNote,
      createdAt: createdAt,
    );
  }

  factory SupervisorPermissionEntity.fromJson(Map<String, dynamic> json) {
    return SupervisorPermissionEntity(
      id: json['id'] ?? '',
      driverName: json['driver_name'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      lineName: json['line_name'] ?? '',
      duration: json['duration'] ?? '',
      permissionType: json['permission_type'] ?? '',
      requestDate: json['request_date'] ?? '',
      status: json['status'] ?? 'pending',
      rejectionNote: json['rejection_note'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
