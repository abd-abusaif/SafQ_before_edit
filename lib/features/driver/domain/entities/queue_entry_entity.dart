// features/driver/domain/entities/queue_entry_entity.dart

class QueueEntryEntity {
  final int queuePosition; // رقم الدور
  final String driverName; // اسم السائق
  final String lineFrom; // من
  final String lineTo; // إلى
  final String entryTime; // وقت الدخول
  final String? exitTime; // وقت الخروج
  final int registrationNumber; // رقم تسجيل الدور
  final DateTime? loadingValidityDate; // تاريخ التحميل المسموح

  const QueueEntryEntity({
    required this.queuePosition,
    required this.driverName,
    required this.lineFrom,
    required this.lineTo,
    required this.entryTime,
    this.exitTime,
    required this.registrationNumber,
    this.loadingValidityDate,
  });
}
