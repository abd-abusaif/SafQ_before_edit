// features/driver/domain/entities/movement_order_entity.dart

class MovementOrderEntity {
  final String id;
  final String vehicleNumber; // رقم المركبة
  final String lineNumber; // رقم الخط
  final String lineFrom; // من
  final String lineTo; // إلى
  final String departureDate; // تاريخ المغادرة (YYYY-MM-DD)
  final String departureTime; // وقت المغادرة
  final bool isException; // صادر عن استثناء من المشرف

  const MovementOrderEntity({
    required this.id,
    required this.vehicleNumber,
    required this.lineNumber,
    required this.lineFrom,
    required this.lineTo,
    required this.departureDate,
    required this.departureTime,
    this.isException = false,
  });

  factory MovementOrderEntity.fromJson(Map<String, dynamic> json) {
    return MovementOrderEntity(
      id: json['id'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      lineNumber: json['line_number'] ?? '',
      lineFrom: json['line_from'] ?? '',
      lineTo: json['line_to'] ?? '',
      departureDate: json['departure_date'] ?? '',
      departureTime: json['departure_time'] ?? '',
      isException: json['is_exception'] ?? false,
    );
  }
}
