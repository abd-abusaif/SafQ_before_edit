// features/driver/domain/entities/queue_entry_entity.dart

class QueueEntryEntity {
  final int queuePosition;
  final String driverName;
  final String vehicleNumber; // رقم المركبة
  final String lineFrom;
  final String lineTo;

  /// معرّف الخط — يُستخدم لجلب عدد الخانات المسموحة لهذا الخط
  /// API: line_id
  final String lineId;

  final String entryTime; // وقت دخول المركبة عند تسجيلها (RFID)
  final String? exitTime;
  final int registrationNumber;
  final DateTime? loadingValidityDate;

  const QueueEntryEntity({
    required this.queuePosition,
    required this.driverName,
    required this.vehicleNumber,
    required this.lineFrom,
    required this.lineTo,
    this.lineId = '',
    required this.entryTime,
    this.exitTime,
    required this.registrationNumber,
    this.loadingValidityDate,
  });

  factory QueueEntryEntity.fromJson(Map<String, dynamic> json) {
    return QueueEntryEntity(
      queuePosition: json['queue_position'] ?? 0,
      driverName: json['driver_name'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      lineFrom: json['line_from'] ?? '',
      lineTo: json['line_to'] ?? '',
      lineId: json['line_id'] ?? '',
      entryTime: json['entry_time'] ?? '',
      exitTime: json['exit_time'],
      registrationNumber: json['registration_number'] ?? 0,
      loadingValidityDate: json['loading_validity_date'] != null
          ? DateTime.tryParse(json['loading_validity_date'])
          : null,
    );
  }
}
