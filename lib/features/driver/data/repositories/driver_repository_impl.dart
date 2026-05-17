// features/driver/data/repositories/driver_repository_impl.dart

import '../../domain/entities/queue_entry_entity.dart';
import '../../domain/entities/movement_order_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../../../core/stores/shared_movement_order_store.dart';
import '../../../../core/stores/shared_permission_store.dart';

// ── Mock: بيانات الخطوط وخاناتها (يأتي من الأدمن في API الحقيقي) ────────────
// API: GET /api/lines/:lineId → { allowed_loading_slots: N }
const _lineSlots = <String, int>{
  '01': 3, // خط الخليل / دورا — 3 خانات تحميل
  '02': 2, // خط الخليل / بيت لحم — 2 خانة تحميل
};

class DriverRepositoryImpl implements DriverRepository {
  @override
  Future<List<QueueEntryEntity>> getQueueList() async {
    // API: GET /api/driver/queue
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      QueueEntryEntity(
        queuePosition: 1,
        driverName: 'أحمد محمد',
        vehicleNumber: '6 2181-10',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:15 ص',
        exitTime: '7:30 ص',
        registrationNumber: 1,
        loadingValidityDate: now.add(const Duration(days: 5)),
      ),
      QueueEntryEntity(
        queuePosition: 2,
        driverName: 'محمود علي',
        vehicleNumber: '6 2181-20',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:20 ص',
        exitTime: '7:35 ص',
        registrationNumber: 2,
        loadingValidityDate: now.add(const Duration(days: 3)),
      ),
      QueueEntryEntity(
        queuePosition: 3,
        driverName: 'خالد إبراهيم',
        vehicleNumber: '6 2181-30',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:25 ص',
        exitTime: '7:40 ص',
        registrationNumber: 3,
        loadingValidityDate: now.add(const Duration(days: 7)),
      ),
      QueueEntryEntity(
        queuePosition: 4,
        driverName: 'يوسف سالم',
        vehicleNumber: '6 2181-40',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:30 ص',
        exitTime: '7:45 ص',
        registrationNumber: 4,
        loadingValidityDate: now.add(const Duration(days: 2)),
      ),
      // السائق الحالي — رقم 5 (خارج خانات التحميل لخط 01 = 3)
      QueueEntryEntity(
        queuePosition: 5,
        driverName: 'عبدالرحمن أبو سيف',
        vehicleNumber: '6 2181-50',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:35 ص',
        exitTime: '7:50 ص',
        registrationNumber: 5,
        loadingValidityDate: now.add(const Duration(hours: 18)),
      ),
      QueueEntryEntity(
        queuePosition: 6,
        driverName: 'سامي ناصر',
        vehicleNumber: '6 2181-60',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:40 ص',
        exitTime: '7:55 ص',
        registrationNumber: 6,
        loadingValidityDate: now.add(const Duration(days: 4)),
      ),
      QueueEntryEntity(
        queuePosition: 7,
        driverName: 'فارس عودة',
        vehicleNumber: '6 2181-70',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        lineId: '01',
        entryTime: '7:45 ص',
        exitTime: '8:00 ص',
        registrationNumber: 7,
        loadingValidityDate: now.add(const Duration(days: 6)),
      ),
    ];
  }

  @override
  Future<QueueEntryEntity?> getMyQueueEntry(String idNumber) async {
    // API: GET /api/driver/queue/me/$idNumber
    final list = await getQueueList();
    return list.firstWhere(
      (e) => e.queuePosition == 5,
      orElse: () => list.first,
    );
  }

  /// عدد الخانات المسموح بالتحميل للخط المرتبط بهذا السائق
  /// API: GET /api/driver/queue/allowed-slots?lineId=$lineId
  @override
  Future<int> getAllowedSlots() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: السائق الحالي على خط 01 → 3 خانات
    return _lineSlots['01'] ?? 3;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // أمر الحركة — المنطق الكامل
  //
  // يُصدر أمر الحركة في 3 حالات فقط:
  //  1. الدور ضمن خانات التحميل المسموحة للخط  (slot)
  //  2. إذن موافق عليه من المشرف               (permission)
  //  3. استثناء من المشرف                       (exception)
  //
  // في أي حالة أخرى → null (لا أمر حركة)
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Future<MovementOrderEntity?> getMovementOrder(String idNumber) async {
    // API: GET /api/driver/movement-order/$idNumber
    await Future.delayed(const Duration(milliseconds: 400));

    // ── الحالة 1: تحقق من المتجر المشترك (استثناء أو إذن موافق عليه) ───────
    final storeRecord = SharedMovementOrderStore.getActive(idNumber);
    if (storeRecord != null) {
      return MovementOrderEntity(
        id: storeRecord.id,
        vehicleNumber: storeRecord.vehiclePlate,
        lineNumber: storeRecord.lineNumber,
        lineFrom: storeRecord.lineFrom,
        lineTo: storeRecord.lineTo,
        departureDate: storeRecord.departureDate,
        departureTime: storeRecord.departureTime,
        isException: storeRecord.isException,
      );
    }

    // ── الحالة 2: دور السائق ضمن خانات التحميل المسموحة للخط ───────────────
    final myEntry = await getMyQueueEntry(idNumber);
    if (myEntry == null) return null;

    final lineId = myEntry.lineId.isEmpty ? '01' : myEntry.lineId;
    final allowedSlots = _lineSlots[lineId] ?? 3;
    final isInSlot = myEntry.queuePosition <= allowedSlots;

    if (isInSlot) {
      final now = DateTime.now();
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'م' : 'ص';
      final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      final timeStr = '$h12:$m $period';
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      return MovementOrderEntity(
        id: 'mo-slot-$idNumber',
        vehicleNumber: myEntry.vehicleNumber,
        lineNumber: lineId,
        lineFrom: myEntry.lineFrom,
        lineTo: myEntry.lineTo,
        departureDate: dateStr,
        departureTime: timeStr,
        isException: false,
      );
    }

    // ── الحالة 3: إذن موافق عليه في SharedPermissionStore ───────────────────
    final permissions = SharedPermissionStore.getDriverPermissions(idNumber);
    final hasApprovedPermission = permissions.any(
      (p) => p.status == 'approved',
    );

    if (hasApprovedPermission) {
      final now = DateTime.now();
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'م' : 'ص';
      final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      final timeStr = '$h12:$m $period';
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      return MovementOrderEntity(
        id: 'mo-perm-$idNumber',
        vehicleNumber: myEntry.vehicleNumber,
        lineNumber: lineId,
        lineFrom: myEntry.lineFrom,
        lineTo: myEntry.lineTo,
        departureDate: dateStr,
        departureTime: timeStr,
        isException: false,
      );
    }

    // لا يوجد سبب لإصدار أمر حركة
    return null;
  }

  @override
  Future<void> clearMovementOrder(String idNumber) async {
    // API: DELETE /api/driver/movement-order/$idNumber
    await Future.delayed(const Duration(milliseconds: 300));
    SharedMovementOrderStore.clear(idNumber);
  }
}
