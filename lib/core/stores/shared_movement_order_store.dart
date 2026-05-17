// lib/core/stores/shared_movement_order_store.dart
//
// ── متجر أوامر الحركة المشترك (المشرف → السائق) ──────────────────────────────
// المشرف يكتب هنا (استثناء / موافقة إذن / تحميل ضمن الخانات).
// السائق يقرأ منه عند فتح شاشة أمر الحركة.
// في التطبيق الحقيقي سيُستبدل بـ FCM push notification + API backend.

class MovementOrderRecord {
  final String id;
  final String driverIdNumber;
  final String vehiclePlate;
  final String lineId;
  final String lineNumber;
  final String lineFrom;
  final String lineTo;
  final String departureDate;
  final String departureTime;

  /// سبب إصدار الأمر:
  /// 'slot'       — ضمن خانات التحميل المسموحة للخط
  /// 'permission' — إذن موافق عليه من المشرف
  /// 'exception'  — استثناء من المشرف (طلب ركاب أو غيره)
  final String reason;

  /// هل الأمر محذوف (السائق أقرّ به وحذفه)
  bool isCleared;

  MovementOrderRecord({
    required this.id,
    required this.driverIdNumber,
    required this.vehiclePlate,
    required this.lineId,
    required this.lineNumber,
    required this.lineFrom,
    required this.lineTo,
    required this.departureDate,
    required this.departureTime,
    required this.reason,
    this.isCleared = false,
  });

  bool get isException => reason == 'exception';
  bool get isPermission => reason == 'permission';
  bool get isSlot => reason == 'slot';
}

class SharedMovementOrderStore {
  SharedMovementOrderStore._();

  static final List<MovementOrderRecord> _records = [];

  // ══════════════════════════════════════════════════════════════════════════
  // واجهة المشرف — كتابة أمر حركة
  // ══════════════════════════════════════════════════════════════════════════

  /// إصدار أمر حركة بسبب الاستثناء
  static void issueException({
    required String driverIdNumber,
    required String vehiclePlate,
    required String lineId,
    required String lineNumber,
    required String lineFrom,
    required String lineTo,
  }) {
    _upsert(
      driverIdNumber: driverIdNumber,
      vehiclePlate: vehiclePlate,
      lineId: lineId,
      lineNumber: lineNumber,
      lineFrom: lineFrom,
      lineTo: lineTo,
      reason: 'exception',
    );
  }

  /// إصدار أمر حركة بسبب الموافقة على إذن
  static void issuePermission({
    required String driverIdNumber,
    required String vehiclePlate,
    required String lineId,
    required String lineNumber,
    required String lineFrom,
    required String lineTo,
  }) {
    _upsert(
      driverIdNumber: driverIdNumber,
      vehiclePlate: vehiclePlate,
      lineId: lineId,
      lineNumber: lineNumber,
      lineFrom: lineFrom,
      lineTo: lineTo,
      reason: 'permission',
    );
  }

  /// إصدار أمر حركة لأن المركبة ضمن خانات التحميل المسموحة
  /// يُستدعى من منطق السائق (driver_repository) تلقائياً
  static void issueSlot({
    required String driverIdNumber,
    required String vehiclePlate,
    required String lineId,
    required String lineNumber,
    required String lineFrom,
    required String lineTo,
  }) {
    _upsert(
      driverIdNumber: driverIdNumber,
      vehiclePlate: vehiclePlate,
      lineId: lineId,
      lineNumber: lineNumber,
      lineFrom: lineFrom,
      lineTo: lineTo,
      reason: 'slot',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // واجهة السائق — قراءة وحذف
  // ══════════════════════════════════════════════════════════════════════════

  /// جلب أمر الحركة النشط للسائق (null إذا لم يوجد أو تم حذفه)
  static MovementOrderRecord? getActive(String driverIdNumber) {
    try {
      return _records.lastWhere(
        (r) => r.driverIdNumber == driverIdNumber && !r.isCleared,
      );
    } catch (_) {
      return null;
    }
  }

  /// السائق حذف الأمر (أقرّ به وخرج)
  static void clear(String driverIdNumber) {
    for (final r in _records) {
      if (r.driverIdNumber == driverIdNumber) {
        r.isCleared = true;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // داخلي
  // ══════════════════════════════════════════════════════════════════════════

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _nowTime() {
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'م' : 'ص';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }

  /// إضافة أو تحديث أمر حركة للسائق
  static void _upsert({
    required String driverIdNumber,
    required String vehiclePlate,
    required String lineId,
    required String lineNumber,
    required String lineFrom,
    required String lineTo,
    required String reason,
  }) {
    // إذا كان يوجد أمر نشط بنفس النوع → لا نضيف مكرر
    final existing = _records.where(
      (r) =>
          r.driverIdNumber == driverIdNumber &&
          !r.isCleared &&
          r.reason == reason,
    );
    if (existing.isNotEmpty) return;

    _records.add(
      MovementOrderRecord(
        id: 'mo-${DateTime.now().millisecondsSinceEpoch}',
        driverIdNumber: driverIdNumber,
        vehiclePlate: vehiclePlate,
        lineId: lineId,
        lineNumber: lineNumber,
        lineFrom: lineFrom,
        lineTo: lineTo,
        departureDate: _today(),
        departureTime: _nowTime(),
        reason: reason,
      ),
    );
  }
}
