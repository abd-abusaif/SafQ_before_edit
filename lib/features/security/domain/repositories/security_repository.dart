// features/security/domain/repositories/security_repository.dart

import '../entities/security_vehicle_entity.dart';

abstract class SecurityRepository {
  /// قائمة المركبات المسجّلة دخولاً (الشاشة الرئيسية)
  Future<List<SecurityVehicleEntity>> getVehicles(String idNumber);

  /// إشعارات المركبات المرفوضة/المحظورة (صفحة الإشعارات)
  Future<List<SecurityVehicleEntity>> getRejectedNotifications(String idNumber);

  /// تغيير حالة الإشعار إلى "تم التعامل" — يُحدَّث من المشرف عبر API
  Future<void> markAsHandled(String vehicleId);
}
