// features/supervisor/domain/repositories/supervisor_repository.dart

import '../entities/supervisor_entity.dart';
import '../entities/supervisor_stats_entity.dart';
import '../entities/supervisor_vehicle_entity.dart';
import '../entities/supervisor_permission_entity.dart';
import '../entities/rejected_vehicle_notification_entity.dart';
import '../entities/line_detail_entity.dart';

abstract class SupervisorRepository {
  // ── الشاشة الرئيسية ──────────────────────────────────────────────────────
  Future<List<SupervisorLineEntity>> getMyLines(String idNumber);
  Future<int> getTotalActiveVehicles(String idNumber);
  Future<List<Map<String, dynamic>>> getLinesTable(String idNumber);
  Future<SupervisorStatsEntity> getStats(String idNumber, String lineId);
  Future<List<SupervisorVehicleEntity>> getQueueVehicles(
    String idNumber,
    String lineId,
  );

  // ── صفحة الملف الشخصي ────────────────────────────────────────────────────
  Future<SupervisorProfileEntity> getProfile(String idNumber);

  // ── صفحة الخطوط ──────────────────────────────────────────────────────────
  Future<LineDetailEntity> getLineDetail(String idNumber, String lineId);

  // ── صفحة الأذونات ────────────────────────────────────────────────────────
  Future<List<SupervisorPermissionEntity>> getPendingPermissions(
    String idNumber,
  );
  Future<List<SupervisorPermissionEntity>> getArchivedPermissions(
    String idNumber,
  );
  Future<void> approvePermission(String permissionId);
  Future<void> rejectPermission(String permissionId, String note);

  // ── صفحة الإشعارات ───────────────────────────────────────────────────────
  Future<List<RejectedVehicleNotificationEntity>> getRejectedNotifications(
    String idNumber,
  );
  Future<void> markVehicleHandled(String notificationId);
}
