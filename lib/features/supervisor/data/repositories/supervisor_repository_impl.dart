// features/supervisor/data/repositories/supervisor_repository_impl.dart

import '../../domain/entities/supervisor_entity.dart';
import '../../domain/entities/supervisor_stats_entity.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';
import '../../domain/entities/supervisor_permission_entity.dart';
import '../../domain/entities/rejected_vehicle_notification_entity.dart';
import '../../domain/entities/line_detail_entity.dart';
import '../../domain/entities/external_request_entity.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../../../../core/stores/shared_permission_store.dart';
import '../../../../core/stores/shared_movement_order_store.dart';

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

// ── ملاحظة: الأذونات تُدار الآن عبر SharedPermissionStore المشترك ────────────
// السائق يرسل الإذن ← SharedPermissionStore ← المشرف يقرأه ويوافق/يرفض
// راجع: lib/core/stores/shared_permission_store.dart

// ── Shared store للطلبات الخارجية (Passengers ↔ SafQ) ──────────────────────
class _ExternalRequestStore {
  static final List<ExternalRequestEntity> _list = [
    ExternalRequestEntity(
      id: 'er1',
      requesterName: 'سامر أبو عيشة',
      requesterPhone: '0599441122',
      type: ExternalRequestType.passengers,
      location: 'حي الشيخ',
      destination: 'دورا',
      passengersCount: 3,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ExternalRequestEntity(
      id: 'er2',
      requesterName: 'منى الجعبري',
      requesterPhone: '0598776655',
      type: ExternalRequestType.parcel,
      location: 'وسط البلد',
      destination: 'الخليل الجديد',
      parcelName: 'طرد متوسط',
      parcelDetails: 'ملابس ومستلزمات منزلية',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static List<ExternalRequestEntity> get all => List.unmodifiable(_list);

  static void approve(String id) {
    final idx = _list.indexWhere((r) => r.id == id);
    if (idx != -1) _list[idx] = _list[idx].copyWith(status: 'approved');
  }

  static void reject(String id) {
    final idx = _list.indexWhere((r) => r.id == id);
    if (idx != -1) _list[idx] = _list[idx].copyWith(status: 'rejected');
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
      // عدد خانات التحميل المسموحة — يُحدّد من الأدمن
      // API: line.allowed_loading_slots
      allowedLoadingSlots: lineId == '1' ? 3 : 2,
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
    return SharedPermissionStore.getPending();
  }

  // ── الأذونات المؤرشفة (موافق عليها + مرفوضة) ───────────────────────────
  @override
  Future<List<SupervisorPermissionEntity>> getArchivedPermissions(
    String idNumber,
  ) async {
    // API: GET /api/supervisor/permissions/$idNumber?status=archived
    await Future.delayed(const Duration(milliseconds: 400));
    return SharedPermissionStore.getArchived();
  }

  // ── قبول إذن ────────────────────────────────────────────────────────────
  // عند الموافقة على إذن → يُصدر أمر حركة للسائق تلقائياً
  @override
  Future<void> approvePermission(String permissionId) async {
    // API: POST /api/supervisor/permissions/$permissionId/approve
    await Future.delayed(const Duration(milliseconds: 500));
    SharedPermissionStore.approve(permissionId);

    // إصدار أمر الحركة في المتجر المشترك
    final allPerms = [
      ...SharedPermissionStore.getPending(),
      ...SharedPermissionStore.getArchived(),
    ];
    final perm = allPerms.where((p) => p.id == permissionId).firstOrNull;
    if (perm != null) {
      final parts = perm.lineName.split(' / ');
      SharedMovementOrderStore.issuePermission(
        driverIdNumber: _driverIdFromPermission(permissionId),
        vehiclePlate: perm.vehiclePlate,
        lineId: '01',
        lineNumber: '01',
        lineFrom: parts.first,
        lineTo: parts.length > 1 ? parts.last : perm.lineName,
      );
    }
  }

  String _driverIdFromPermission(String permissionId) {
    const map = <String, String>{
      'sp1': '409581394',
      'sp2': '409581394',
      'sp3': '409581394',
      'sp4': '9031122334',
    };
    return map[permissionId] ?? '';
  }

  // ── رفض إذن ─────────────────────────────────────────────────────────────
  @override
  Future<void> rejectPermission(String permissionId, String note) async {
    // API: POST /api/supervisor/permissions/$permissionId/reject
    // body: { "note": note }
    await Future.delayed(const Duration(milliseconds: 500));
    SharedPermissionStore.reject(permissionId, note);
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

  // ── استثناء مركبة (أمر الحركة الاستثنائي) ───────────────────────────────
  // يُستدعى من شاشة المشرف عند الضغط على زر "استثناء"
  // يكتب أمر الحركة في المتجر المشترك فيقرأه السائق فوراً
  @override
  Future<void> grantException(String vehiclePlate) async {
    // API: POST /api/supervisor/vehicles/$vehiclePlate/exception
    await Future.delayed(const Duration(milliseconds: 500));

    // جلب بيانات المركبة من قائمة الدور لتعبئة أمر الحركة
    final vehicles = await getQueueVehicles('supervisor', '01');
    final vehicle = vehicles
        .where((v) => v.vehiclePlate == vehiclePlate)
        .firstOrNull;

    if (vehicle != null) {
      // Mock: معرف السائق — في الـ API الحقيقي يأتي مع بيانات المركبة
      // نستخدم vehiclePlate كـ key للبحث
      final driverIdNumber = _driverIdFromPlate(vehiclePlate);
      SharedMovementOrderStore.issueException(
        driverIdNumber: driverIdNumber,
        vehiclePlate: vehiclePlate,
        lineId: '01',
        lineNumber: '01',
        lineFrom: vehicle.lineFrom,
        lineTo: vehicle.lineTo,
      );
    }
  }

  /// استخرج driverIdNumber من رقم المركبة — mock محلي
  String _driverIdFromPlate(String vehiclePlate) {
    // API: GET /api/vehicles/$vehiclePlate → driver_id_number
    const map = <String, String>{
      'أ ب ج 1234': '9021234567',
      'ز ح ط 9012': '9031122334',
      'م ن س 6677': '9045566778',
      '6 2181-50': '409581394',
    };
    return map[vehiclePlate] ?? '';
  }

  // ── الطلبات الخارجية (ركاب / طرود من تطبيق Passengers) ──────────────────
  @override
  Future<List<ExternalRequestEntity>> getExternalRequests(
    String idNumber,
  ) async {
    // API: GET /api/supervisor/external-requests/$idNumber
    await Future.delayed(const Duration(milliseconds: 400));
    return _ExternalRequestStore.all;
  }

  @override
  Future<void> approveExternalRequest(String requestId) async {
    // API: POST /api/supervisor/external-requests/$requestId/approve
    // → Backend يرسل FCM notification لتطبيق Passengers
    await Future.delayed(const Duration(milliseconds: 500));
    _ExternalRequestStore.approve(requestId);
  }

  @override
  Future<void> rejectExternalRequest(String requestId) async {
    // API: POST /api/supervisor/external-requests/$requestId/reject
    // → Backend يرسل FCM notification لتطبيق Passengers
    await Future.delayed(const Duration(milliseconds: 500));
    _ExternalRequestStore.reject(requestId);
  }
}
