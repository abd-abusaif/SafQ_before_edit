// lib/core/stores/shared_permission_store.dart
//
// ── متجر الأذونات المشترك (السائق ↔ المشرف) ─────────────────────────────────
// السائق يضيف الأذونات هنا، والمشرف يقرأ منه ويوافق/يرفض.
// في التطبيق الحقيقي سيتم الاستعاضة عنه بـ API Backend.

import '../../features/driver/domain/entities/permission_entity.dart';
import '../../features/supervisor/domain/entities/supervisor_permission_entity.dart';

class SharedPermissionStore {
  SharedPermissionStore._();

  // ── بيانات ابتدائية تجريبية ──────────────────────────────────────────────
  static final List<_UnifiedPermission> _records = [
    _UnifiedPermission(
      id: 'sp1',
      driverIdNumber: '409581394',
      driverName: 'عبدالرحمن أبو سيف',
      vehiclePlate: '6 2181-30',
      lineName: 'الخليل / دورا',
      reason: 'موعد طبي طارئ في مستشفى الخليل الحكومي',
      duration: 'يوم واحد',
      requestDate: '2026-04-15',
      status: 'approved',
      rejectionNote: null,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    _UnifiedPermission(
      id: 'sp2',
      driverIdNumber: '409581394',
      driverName: 'عبدالرحمن أبو سيف',
      vehiclePlate: '6 2181-30',
      lineName: 'الخليل / دورا',
      reason: 'إجراءات تجديد رخصة القيادة في مديرية المرور',
      duration: 'نصف يوم',
      requestDate: '2026-04-18',
      status: 'rejected',
      rejectionNote: 'الوقت المحدد غير متاح، يرجى إعادة الطلب لاحقاً',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _UnifiedPermission(
      id: 'sp3',
      driverIdNumber: '409581394',
      driverName: 'عبدالرحمن أبو سيف',
      vehiclePlate: '6 2181-30',
      lineName: 'الخليل / دورا',
      reason: 'مراسم عزاء عائلية',
      duration: 'يومان',
      requestDate: '2026-05-01',
      status: 'pending',
      rejectionNote: null,
      createdAt: DateTime.now(),
    ),
    // ── سائق آخر (يظهر فقط لدى المشرف) ─────────────────────────────────
    _UnifiedPermission(
      id: 'sp4',
      driverIdNumber: '9031122334',
      driverName: 'محمود علي حسن',
      vehiclePlate: 'ز ح ط 9012',
      lineName: 'الخليل / دورا',
      reason: 'تجديد وثيقة تأمين المركبة',
      duration: 'يوم واحد',
      requestDate: '2026-05-02',
      status: 'pending',
      rejectionNote: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // واجهة السائق
  // ══════════════════════════════════════════════════════════════════════════

  /// جلب أذونات سائق بعينه (بـ idNumber)
  static List<PermissionEntity> getDriverPermissions(String idNumber) {
    return _records
        .where((r) => r.driverIdNumber == idNumber)
        .map((r) => r.toPermissionEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// السائق يرسل إذناً جديداً
  static void submitPermission({
    required String idNumber,
    required String driverName,
    required String vehiclePlate,
    required String lineName,
    required String reason,
    required String requestDate,
    String duration = 'يوم واحد',
  }) {
    _records.add(
      _UnifiedPermission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverIdNumber: idNumber,
        driverName: driverName,
        vehiclePlate: vehiclePlate,
        lineName: lineName,
        reason: reason,
        duration: duration,
        requestDate: requestDate,
        status: 'pending',
        rejectionNote: null,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // واجهة المشرف
  // ══════════════════════════════════════════════════════════════════════════

  /// جلب الأذونات المعلّقة (لجميع السائقين ضمن خطوط المشرف)
  static List<SupervisorPermissionEntity> getPending() {
    return _records
        .where((r) => r.status == 'pending')
        .map((r) => r.toSupervisorEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// جلب الأذونات المؤرشفة (موافق عليها + مرفوضة)
  static List<SupervisorPermissionEntity> getArchived() {
    return _records
        .where((r) => r.status != 'pending')
        .map((r) => r.toSupervisorEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// المشرف يوافق على إذن
  static void approve(String id) {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _records[idx];
      _records[idx] = _UnifiedPermission(
        id: old.id,
        driverIdNumber: old.driverIdNumber,
        driverName: old.driverName,
        vehiclePlate: old.vehiclePlate,
        lineName: old.lineName,
        reason: old.reason,
        duration: old.duration,
        requestDate: old.requestDate,
        status: 'approved',
        rejectionNote: null,
        createdAt: old.createdAt,
      );
    }
  }

  /// المشرف يرفض إذناً مع ملاحظة
  static void reject(String id, String note) {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _records[idx];
      _records[idx] = _UnifiedPermission(
        id: old.id,
        driverIdNumber: old.driverIdNumber,
        driverName: old.driverName,
        vehiclePlate: old.vehiclePlate,
        lineName: old.lineName,
        reason: old.reason,
        duration: old.duration,
        requestDate: old.requestDate,
        status: 'rejected',
        rejectionNote: note,
        createdAt: old.createdAt,
      );
    }
  }

  /// السائق يحذف طلباته المكتملة (مقبولة + مرفوضة) — الـ pending تبقى
  static void deleteCompletedForDriver(String idNumber) {
    _records.removeWhere(
      (r) => r.driverIdNumber == idNumber && r.status != 'pending',
    );
  }
}

// ── النموذج الداخلي الموحّد ─────────────────────────────────────────────────
class _UnifiedPermission {
  final String id;
  final String driverIdNumber;
  final String driverName;
  final String vehiclePlate;
  final String lineName;
  final String reason;
  final String duration;
  final String requestDate;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionNote;
  final DateTime createdAt;

  const _UnifiedPermission({
    required this.id,
    required this.driverIdNumber,
    required this.driverName,
    required this.vehiclePlate,
    required this.lineName,
    required this.reason,
    required this.duration,
    required this.requestDate,
    required this.status,
    required this.rejectionNote,
    required this.createdAt,
  });

  PermissionEntity toPermissionEntity() => PermissionEntity(
    id: id,
    reason: reason,
    requestDate: requestDate,
    status: status,
    rejectionReason: rejectionNote,
    createdAt: createdAt,
  );

  SupervisorPermissionEntity toSupervisorEntity() => SupervisorPermissionEntity(
    id: id,
    driverName: driverName,
    vehiclePlate: vehiclePlate,
    lineName: lineName,
    duration: duration,
    permissionType: reason,
    requestDate: requestDate,
    status: status,
    rejectionNote: rejectionNote,
    createdAt: createdAt,
  );
}
