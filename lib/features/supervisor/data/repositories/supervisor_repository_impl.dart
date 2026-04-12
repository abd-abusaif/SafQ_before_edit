// features/supervisor/data/repositories/supervisor_repository_impl.dart

import '../../domain/entities/supervisor_entity.dart';
import '../../domain/entities/supervisor_stats_entity.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';
import '../../domain/entities/supervisor_permission_entity.dart';
import '../../domain/entities/rejected_vehicle_notification_entity.dart';
import '../../domain/entities/line_detail_entity.dart';
import '../../domain/repositories/supervisor_repository.dart';

// ── Shared store للإشعارات (محاكاة push notification) ──────────────────────
class _NotificationStore {
  static final List<RejectedVehicleNotificationEntity> _list = [
    const RejectedVehicleNotificationEntity(
      id: 'n1',
      driverName: 'خالد إبراهيم',
      vehiclePlate: 'د هـ و 5678',
      lineName: 'الخليل / دورا',
      entryTime: '7:20 ص',
      isHandled: false,
    ),
    const RejectedVehicleNotificationEntity(
      id: 'n2',
      driverName: 'سامر يوسف',
      vehiclePlate: 'ك ل م 3344',
      lineName: 'الخليل / بيت لحم',
      entryTime: '8:05 ص',
      isHandled: true,
    ),
  ];

  static List<RejectedVehicleNotificationEntity> get all =>
      List.unmodifiable(_list);

  static void markHandled(String id) {
    final idx = _list.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _list[idx] = _list[idx].copyWith(isHandled: true);
    }
  }
}

// ── Shared store للأذونات ────────────────────────────────────────────────────
class _PermissionStore {
  static final List<SupervisorPermissionEntity> _list = [
    SupervisorPermissionEntity(
      id: 'p1',
      driverName: 'أحمد محمد السعيد',
      vehiclePlate: 'أ ب ج 1234',
      lineName: 'الخليل / دورا',
      duration: 'يوم واحد',
      permissionType: 'موعد طبي طارئ',
      requestDate: '2026-04-11',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    SupervisorPermissionEntity(
      id: 'p2',
      driverName: 'محمود علي حسن',
      vehiclePlate: 'ز ح ط 9012',
      lineName: 'الخليل / دورا',
      duration: 'نصف يوم',
      permissionType: 'تجديد رخصة القيادة',
      requestDate: '2026-04-12',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SupervisorPermissionEntity(
      id: 'p3',
      driverName: 'يوسف حسن عمر',
      vehiclePlate: 'م ن س 6677',
      lineName: 'الخليل / بيت لحم',
      duration: 'يومان',
      permissionType: 'مراسم عزاء عائلية',
      requestDate: '2026-04-10',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SupervisorPermissionEntity(
      id: 'p4',
      driverName: 'سامر يوسف',
      vehiclePlate: 'ك ل م 3344',
      lineName: 'الخليل / بيت لحم',
      duration: '3 أيام',
      permissionType: 'إجازة اضطرارية',
      requestDate: '2026-04-09',
      status: 'rejected',
      rejectionNote: 'لا يوجد سائق بديل في هذا التوقيت',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<SupervisorPermissionEntity> get pending =>
      _list.where((p) => p.status == 'pending').toList();

  static List<SupervisorPermissionEntity> get archived =>
      _list.where((p) => p.status != 'pending').toList();

  static void approve(String id) {
    final idx = _list.indexWhere((p) => p.id == id);
    if (idx != -1) _list[idx] = _list[idx].copyWith(status: 'approved');
  }

  static void reject(String id, String note) {
    final idx = _list.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _list[idx] = _list[idx].copyWith(status: 'rejected', rejectionNote: note);
    }
  }
}

// ── Repository Implementation ────────────────────────────────────────────────
class SupervisorRepositoryImpl implements SupervisorRepository {
  // ── الخطوط ──────────────────────────────────────────────────────────────
  @override
  Future<List<SupervisorLineEntity>> getMyLines(String idNumber) async {
    // API: GET /api/supervisor/lines/$idNumber
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SupervisorLineEntity(id: '1', name: 'الخليل / دورا'),
      SupervisorLineEntity(id: '2', name: 'الخليل / بيت لحم'),
    ];
  }

  // ── إجمالي المركبات النشطة ──────────────────────────────────────────────
  @override
  Future<int> getTotalActiveVehicles(String idNumber) async {
    // API: GET /api/supervisor/active-vehicles/$idNumber
    await Future.delayed(const Duration(milliseconds: 300));
    return 22;
  }

  // ── جدول الخطوط (الشاشة الرئيسية) ─────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> getLinesTable(String idNumber) async {
    // API: GET /api/supervisor/lines-table/$idNumber
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {'line_number': '01', 'line_name': 'الخليل / دورا', 'vehicle_count': 14},
      {
        'line_number': '02',
        'line_name': 'الخليل / بيت لحم',
        'vehicle_count': 8,
      },
    ];
  }

  // ── إحصائيات الخط ───────────────────────────────────────────────────────
  @override
  Future<SupervisorStatsEntity> getStats(String idNumber, String lineId) async {
    // API: GET /api/supervisor/stats/$idNumber/$lineId
    await Future.delayed(const Duration(milliseconds: 400));
    return const SupervisorStatsEntity(
      activeVehicles: 14,
      waitingVehicles: 8,
      completedTrips: 22,
    );
  }

  // ── مركبات الدور لخط معين ───────────────────────────────────────────────
  @override
  Future<List<SupervisorVehicleEntity>> getQueueVehicles(
    String idNumber,
    String lineId,
  ) async {
    // API: GET /api/supervisor/queue/$idNumber/$lineId
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const SupervisorVehicleEntity(
        driverName: 'أحمد محمد',
        vehiclePlate: 'أ ب ج 1234',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 ص',
        queuePosition: 1,
        isApproved: true,
      ),
      const SupervisorVehicleEntity(
        driverName: 'محمود علي',
        vehiclePlate: 'ز ح ط 9012',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 ص',
        queuePosition: 2,
        isApproved: true,
      ),
      const SupervisorVehicleEntity(
        driverName: 'يوسف حسن',
        vehiclePlate: 'م ن س 6677',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:40 ص',
        queuePosition: 3,
        isApproved: true,
      ),
    ];
  }

  // ── الملف الشخصي ────────────────────────────────────────────────────────
  @override
  Future<SupervisorProfileEntity> getProfile(String idNumber) async {
    // API: GET /api/supervisor/profile/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    return SupervisorProfileEntity(
      fullName: 'محمد رامي إبراهيم عودة',
      idNumber: idNumber,
      phone: '0599112233',
      lines: const [
        SupervisorLineEntity(id: '1', name: 'الخليل / دورا'),
        SupervisorLineEntity(id: '2', name: 'الخليل / بيت لحم'),
      ],
      gateName: 'بوابة شارع بئر السبع',
    );
  }

  // ── تفاصيل خط (صفحة الخطوط) ─────────────────────────────────────────────
  @override
  Future<LineDetailEntity> getLineDetail(String idNumber, String lineId) async {
    // API: GET /api/supervisor/line-detail/$idNumber/$lineId
    await Future.delayed(const Duration(milliseconds: 500));
    return LineDetailEntity(
      lineId: lineId,
      lineName: lineId == '1' ? 'الخليل / دورا' : 'الخليل / بيت لحم',
      passengerFare: lineId == '1' ? '5 ش' : '7 ش',
      vehicles: const [
        LineVehicleEntity(
          vehiclePlate: 'أ ب ج 1234',
          operatingLicense: 'رخ-2024-001',
          driverName: 'أحمد محمد السعيد',
          driverIdNumber: '9021234567',
          driverPhone: '0599111222',
          lineName: 'الخليل / دورا',
        ),
        LineVehicleEntity(
          vehiclePlate: 'ز ح ط 9012',
          operatingLicense: 'رخ-2023-018',
          driverName: 'محمود علي حسن',
          driverIdNumber: '9031122334',
          driverPhone: '0598765432',
          lineName: 'الخليل / دورا',
        ),
        LineVehicleEntity(
          vehiclePlate: 'م ن س 6677',
          operatingLicense: 'رخ-2024-033',
          driverName: 'يوسف حسن عمر',
          driverIdNumber: '9045566778',
          driverPhone: '0597001234',
          lineName: 'الخليل / دورا',
        ),
      ],
    );
  }

  // ── الأذونات المعلّقة ────────────────────────────────────────────────────
  @override
  Future<List<SupervisorPermissionEntity>> getPendingPermissions(
    String idNumber,
  ) async {
    // API: GET /api/supervisor/permissions/$idNumber?status=pending
    await Future.delayed(const Duration(milliseconds: 400));
    return _PermissionStore.pending;
  }

  // ── الأذونات المؤرشفة (موافق عليها + مرفوضة) ───────────────────────────
  @override
  Future<List<SupervisorPermissionEntity>> getArchivedPermissions(
    String idNumber,
  ) async {
    // API: GET /api/supervisor/permissions/$idNumber?status=archived
    await Future.delayed(const Duration(milliseconds: 400));
    return _PermissionStore.archived;
  }

  // ── قبول إذن ────────────────────────────────────────────────────────────
  @override
  Future<void> approvePermission(String permissionId) async {
    // API: POST /api/supervisor/permissions/$permissionId/approve
    await Future.delayed(const Duration(milliseconds: 500));
    _PermissionStore.approve(permissionId);
  }

  // ── رفض إذن ─────────────────────────────────────────────────────────────
  @override
  Future<void> rejectPermission(String permissionId, String note) async {
    // API: POST /api/supervisor/permissions/$permissionId/reject
    // body: { "note": note }
    await Future.delayed(const Duration(milliseconds: 500));
    _PermissionStore.reject(permissionId, note);
  }

  // ── إشعارات المركبات المرفوضة ────────────────────────────────────────────
  @override
  Future<List<RejectedVehicleNotificationEntity>> getRejectedNotifications(
    String idNumber,
  ) async {
    // API: GET /api/supervisor/rejected-notifications/$idNumber
    await Future.delayed(const Duration(milliseconds: 400));
    return _NotificationStore.all;
  }

  // ── تم التعامل مع المركبة ────────────────────────────────────────────────
  @override
  Future<void> markVehicleHandled(String notificationId) async {
    // API: POST /api/supervisor/rejected-notifications/$notificationId/handled
    await Future.delayed(const Duration(milliseconds: 400));
    _NotificationStore.markHandled(notificationId);
  }
}
