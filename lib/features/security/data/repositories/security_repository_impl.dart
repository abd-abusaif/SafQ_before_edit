// features/security/data/repositories/security_repository_impl.dart

import '../../domain/entities/security_vehicle_entity.dart';
import '../../domain/repositories/security_repository.dart';

// ── Shared notification store ─────────────────────────────────────────────────
// في الإنتاج: push notification (FCM/WebSocket) يُحدَّث من الـ API
// حين يضغط المشرف "تم التعامل" → API → push → تحديث هنا
class SecurityNotificationStore {
  static final List<SecurityVehicleEntity> _rejected = [
    SecurityVehicleEntity(
      id: 'n1',
      driverName: 'خالد إبراهيم',
      vehiclePlate: 'د هـ و 5678',
      lineFrom: 'الخليل',
      lineTo: 'دورا',
      entryTime: '7:20 ص',
      queuePosition: 2,
      isApproved: false,
      rejectionReason: 'رخصة السيارة منتهية',
      entryDateTime: DateTime.now().subtract(const Duration(minutes: 10)),
      isHandled: false,
    ),
    SecurityVehicleEntity(
      id: 'n2',
      driverName: 'سامر يوسف',
      vehiclePlate: 'ك ل م 3344',
      lineFrom: 'الخليل',
      lineTo: 'بيت لحم',
      entryTime: '8:05 ص',
      queuePosition: 5,
      isApproved: false,
      rejectionReason: 'حظر بسبب مخالفة سابقة',
      entryDateTime: DateTime.now().subtract(const Duration(minutes: 20)),
      isHandled: true, // تم التعامل من المشرف
    ),
  ];

  static List<SecurityVehicleEntity> get all => List.unmodifiable(_rejected);

  static void markHandled(String id) {
    final idx = _rejected.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _rejected[idx] = _rejected[idx].copyWith(isHandled: true);
    }
  }
}

// ── Repository Implementation ────────────────────────────────────────────────
class SecurityRepositoryImpl implements SecurityRepository {
  // ── قائمة المركبات المسجّلة دخولاً (مقبولة فقط للشاشة الرئيسية) ─────────
  @override
  Future<List<SecurityVehicleEntity>> getVehicles(String idNumber) async {
    // API: GET /api/security/vehicles/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SecurityVehicleEntity(
        id: '1',
        driverName: 'أحمد محمد',
        vehiclePlate: 'أ ب ج 1234',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 ص',
        queuePosition: 1,
        isApproved: true,
        entryDateTime: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
      SecurityVehicleEntity(
        id: '3',
        driverName: 'محمود علي',
        vehiclePlate: 'ز ح ط 9012',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 ص',
        queuePosition: 3,
        isApproved: true,
        entryDateTime: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
      SecurityVehicleEntity(
        id: '4',
        driverName: 'يوسف حسن',
        vehiclePlate: 'م ن س 6677',
        lineFrom: 'الخليل',
        lineTo: 'بيت لحم',
        entryTime: '7:40 ص',
        queuePosition: 4,
        isApproved: true,
        entryDateTime: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  // ── إشعارات المركبات المرفوضة/المحظورة ───────────────────────────────────
  @override
  Future<List<SecurityVehicleEntity>> getRejectedNotifications(
    String idNumber,
  ) async {
    // API: GET /api/security/rejected/$idNumber
    // في الإنتاج: WebSocket أو polling
    await Future.delayed(const Duration(milliseconds: 400));
    return SecurityNotificationStore.all;
  }

  // ── تم التعامل مع الحالة (يُستدعى بعد push من المشرف) ───────────────────
  @override
  Future<void> markAsHandled(String vehicleId) async {
    // API: POST /api/security/handled/$vehicleId
    await Future.delayed(const Duration(milliseconds: 300));
    SecurityNotificationStore.markHandled(vehicleId);
  }
}
